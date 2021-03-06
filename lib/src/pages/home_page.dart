import 'package:cached_network_image/cached_network_image.dart';
import 'package:dostop_v2/src/providers/config_usuario_provider.dart';
import 'package:fl_chart/fl_chart.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import 'package:dostop_v2/src/providers/avisos_provider.dart';
import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/utils/dialogs.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final PageController pageController;
  HomePage({this.pageController});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final avisosProvider = AvisosProvider();
  final visitasProvider = VisitasProvider();
  final configUsuarioProvider = ConfigUsuarioProvider();
  final _prefs = PreferenciasUsuario();
  Map _resultados;
  bool _nuevaEncuesta = false,
      _respuestaEnviada = false,
      _noMolestar = false,
      _accesos = false;
  Map _encuesta;

  @override
  void initState() {
    super.initState();
    avisosProvider.obtenerUltimaEncuesta(_prefs.usuarioLogged).then((encuesta) {
      ///previene la llamada del setState cuando el widget ya ha sido destruido. (if (!mounted) return;)
      if (!mounted) return;
      setState(() {
        if (encuesta.containsKey(1)) {
          _encuesta = encuesta[1];
          _nuevaEncuesta = true;
        }
      });
    });
    configUsuarioProvider
        .obtenerEstadoConfig(_prefs.usuarioLogged, 2)
        .then((estadoAccesos) {
      ///previene la llamada del setState cuando el widget ya ha sido destruido. (if (!mounted) return;)
      if (!mounted) return;
      setState(() {
        if (estadoAccesos.containsKey('valor')) {
          _accesos = estadoAccesos['valor'] == '1';
        }
      });
    });
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_nuevaEncuesta)
      avisosProvider
          .obtenerUltimaEncuesta(_prefs.usuarioLogged)
          .then((encuesta) {
        ///previene la llamada del setState cuando el widget ya ha sido destruido. (if (!mounted) return;)
        if (!mounted) return;
        setState(() {
          if (encuesta.containsKey(1)) {
            _encuesta = encuesta[1];
            _nuevaEncuesta = true;
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Inicio'),
      body: _creaBody(),
      floatingActionButton: _creaItemsFAB(),
    );
  }

  Widget _cargaEncuesta() {
    return AnimatedContainer(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: _nuevaEncuesta ? 130 : 0,
      duration: Duration(milliseconds: 500),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    !_respuestaEnviada
                        ? '¡Tienes una nueva encuesta disponible!'
                        : '¡Gracias!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )),
            ),
            Flexible(child: SizedBox(height: 10)),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: utils.colorPrincipal,
                    child: Text(
                      !_respuestaEnviada ? 'Responder' : 'Ver Resultados',
                      style: utils.estiloBotones(15),
                    ),
                    onPressed: !_respuestaEnviada
                        ? _responderEncuesta
                        : () => _mostrarResultados(
                            _encuesta['pregunta'], _resultados[1]),
                  ),
                  SizedBox(width: 20),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: utils.colorSecundarioSemi,
                    child: Text(
                      !_respuestaEnviada ? 'En otro momento' : 'Cerrar',
                      style: utils.estiloBotones(15),
                    ),
                    onPressed: () {
                      setState(() {
                        _nuevaEncuesta = false;
                      });
                    },
                  )
                ],
              ),
            ),
            Flexible(child: SizedBox(height: 10)),
          ],
        ),
      ),
    );
  }

  _responderEncuesta() {
    creaDialogEncuesta(context, _encuesta['pregunta'], 'Sí', 'No',
        () => _enviarRespuesta(true), () => _enviarRespuesta(false));
  }

  _enviarRespuesta(bool respuesta) {
    Navigator.pop(context);
    creaDialogProgress(context, 'Enviando respuesta');
    avisosProvider
        .enviarRespuestaEncuesta(
            _prefs.usuarioLogged, _encuesta['idPregunta'], respuesta)
        .then((resultados) {
      Navigator.pop(context);
      if (resultados.containsKey(1)) {
        Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
            Icon(Icons.assignment), 'Encuesta enviada', 10));
        setState(() {
          _respuestaEnviada = true;
          _resultados = resultados;
        });
      } else {
        Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
            Icon(Icons.error), 'No se pudo enviar tu respuesta', 10));
      }
    });
  }

  _mostrarResultados(String titulo, Map resultados) {
    creaDialogWidget(
        context,
        titulo,
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            charts.PieChart(
              charts.PieChartData(
                  borderData: charts.FlBorderData(show: false),
                  centerSpaceRadius: 50,
                  pieTouchData:
                      charts.PieTouchData(touchCallback: (pieTouchResponse) {}),
                  sections: [
                    charts.PieChartSectionData(
                        value: resultados['si'] + .0,
                        title: resultados['si'] > 0.0
                            ? '${resultados['si']}%'
                            : '',
                        color: Colors.green,
                        radius: 40),
                    charts.PieChartSectionData(
                        value: resultados['no'] + .0,
                        title: resultados['no'] > 0.0
                            ? '${resultados['no']}%'
                            : '',
                        radius: 40)
                  ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Sí',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 30),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'No',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
        'Aceptar',
        () => Navigator.pop(context));
  }

  _creaBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _cargaEncuesta(),
          Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              child:
                  Text('Últimas Visitas', style: utils.estiloTextoAppBar(18))),
          _cargaUltimasVisitas(),
          Container(
            height: 40,
            child: FlatButton(
              child: Text(
                'Ver todas las visitas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                widget.pageController.jumpToPage(1);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                flex: 2,
                child: _creaBtnTags(),
              ),
              Expanded(
                flex: 4,
                child: _creaSwitchNoMolestar(),
              )
            ],
          ),
          Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              child:
                  Text('Últimos Avisos', style: utils.estiloTextoAppBar(18))),
          _cargaUltimosAvisos(),
          Container(
            height: 40,
            child: FlatButton(
              child: Text(
                'Ver todos los avisos',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                widget.pageController.jumpToPage(3);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _creaBtnTags() {
    return AnimatedContainer(
      width: _accesos ? MediaQuery.of(context).size.width / 3 : 0,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
      margin: EdgeInsets.only(left: 15),
      child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SvgPicture.asset(utils.rutaIconoEntradasTags,
              color: Colors.white, height: 55),
          onPressed: () => Navigator.of(context).pushNamed('MisAccesos'),
          color: utils.colorPrincipal),
    );
  }

  Widget _creaSwitchNoMolestar() {
    return FutureBuilder(
        future: configUsuarioProvider.obtenerEstadoConfig(
            _prefs.usuarioLogged, 1), //VALOR 1 MODO NO MOLESTAR
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.containsKey('valor')) {
              _noMolestar = snapshot.data['valor'] == '1' ? true : false;
              return Container(
                // padding: EdgeInsets.only(right:15),
                // child: Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: <Widget>[
                //     Text('No molestar'),
                //     CupertinoSwitch(
                //   value: true, onChanged: (value){}),
                //   ],
                // )
                child: SwitchListTile(
                  value: _noMolestar,
                  selected: _noMolestar,
                  title: Text('Modo no molestar',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_noMolestar ? 'Activado' : 'Desactivado',
                      textAlign: TextAlign.right),
                  activeColor: utils.colorPrincipal,
                  inactiveThumbColor: utils.colorContenedorSaldo,
                  onChanged: (valor) {
                    if (valor)
                      creaDialogYesNo(
                          context,
                          'Activar modo no molestar',
                          '¿Seguro que deseas activar el modo no molestar?'
                              '\n\nTodas tus visitas serán rechazadas automaticamente.'
                              '\nNota: Los códigos de visitantes frecuentes seguirán teniendo acceso',
                          'Sí',
                          'No', () {
                        Navigator.pop(context);
                        _cambiaModoNoMolestar(valor);
                      }, () {
                        setState(
                          () {
                            _noMolestar = false;
                          },
                        );
                        Navigator.pop(context);
                      });
                    else
                      _cambiaModoNoMolestar(valor);
                  },
                ),
              );
            } else {
              return Container(
                height: 30,
              );
            }
          } else {
            return SwitchListTile(
                value: false,
                title: Text(
                  'Modo no molestar',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Cargando...', textAlign: TextAlign.right),
                onChanged: null);
          }
        });
  }

  _cambiaModoNoMolestar(bool valor) async {
    creaDialogProgress(context, 'Cambiando modo');
    Map resultado = await configUsuarioProvider.configurarOpc(
        _prefs.usuarioLogged, 1, valor);
    Navigator.pop(context);
    setState(() {
      _noMolestar = valor;
      Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
          Icon(resultado['OK'] == 1 ? Icons.notifications_active : Icons.error),
          resultado['message'],
          5));
    });
  }

  _cargaUltimasVisitas() {
    return FutureBuilder(
      future: visitasProvider.obtenerUltimasVisitas(_prefs.usuarioLogged),
      builder:
          (BuildContext context, AsyncSnapshot<List<VisitaModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Container(
                height: 240, child: _crearItemVisita(context, snapshot.data));
          } else {
            return Container(
              height: 240,
              child: Center(
                child: Text('No tienes visitas por ahora',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center),
              ),
            );
          }
        } else {
          return Container(
            height: 240,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }

  _crearItemVisita(BuildContext context, List<VisitaModel> visitas) {
    return Swiper(
      containerHeight: 240,
      loop: false,
      itemCount: visitas.length,
      viewportFraction: 1,
      scale: 0.95,
      control: SwiperControl(
          iconPrevious: Icons.arrow_back_ios,
          iconNext: Icons.arrow_forward_ios,
          color: utils.colorIndicadorSwiper,
          disableColor: Colors.transparent),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: <Widget>[
                          _cargaImagenesVisita(utils.validaImagenes([
                            visitas[index].imgRostro,
                            visitas[index].imgId,
                            visitas[index].imgPlaca
                          ])),
                          Container(
                              padding: EdgeInsets.only(left: 10, bottom: 10),
                              child: Text(
                                '${visitas[index].visitante}',
                                style: utils.estiloTextoBlancoSombreado(18),
                                overflow: TextOverflow.fade,
                              )),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            color: utils.colorPrincipal),
                        width: double.infinity,
                        height: 25,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${utils.fechaCompleta(DateTime.tryParse(visitas[index].fechaEntrada))} ${visitas[index].horaEntrada}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.fade,
                              )
                            ]),
                      )
                    ],
                  ),
                ),
                onTap: () => _abrirVisitaDetalle(visitas[index], context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cargaImagenesVisita(List<String> imagenes) {
    if (imagenes.length == 0) {
      return Container(
        height: 200,
        child: Center(child: Icon(Icons.broken_image)),
      );
    } else {
      return Container(
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Swiper(
              loop: imagenes.length > 1 ? true : false,
              scrollDirection: Axis.vertical,
              containerHeight: 130,
              pagination: SwiperPagination(
                  margin: EdgeInsets.only(right: 10, top: 10),
                  alignment: Alignment.topRight),
              itemCount: imagenes.length,
              itemBuilder: (BuildContext context, int index) {
                return CachedNetworkImage(
                  placeholder: (context, url) =>
                      Image.asset(utils.rutaGifLoadRed),
                  errorWidget: (context, url, error) => Container(
                      height: 200,
                      child: Center(child: Icon(Icons.broken_image))),
                  imageUrl: imagenes[index],
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 300),
                );
              },
            ),
          ));
    }
  }

  _abrirVisitaDetalle(VisitaModel visita, BuildContext context) {
    Navigator.of(context).pushNamed('VisitaDetalle', arguments: visita);
  }

  _cargaUltimosAvisos() {
    return FutureBuilder(
      future: avisosProvider.obtenerUltimosAvisos(_prefs.usuarioLogged),
      builder:
          (BuildContext context, AsyncSnapshot<List<AvisoModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Container(
                height: 240, child: _crearItemAviso(context, snapshot.data));
          } else {
            return Container(
              height: 240,
              child: Center(
                child: Text('No tienes avisos por ahora',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center),
              ),
            );
          }
        } else {
          return Container(
            height: 240,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  _crearItemAviso(BuildContext context, List<AvisoModel> avisos) {
    return Swiper(
      containerHeight: 200,
      loop: false,
      itemCount: avisos.length,
      control: SwiperControl(
          iconPrevious: Icons.arrow_back_ios,
          iconNext: Icons.arrow_forward_ios,
          color: utils.colorIndicadorSwiper,
          disableColor: Colors.transparent),
      scale: 0.9,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          height: 200,
                          child: Text(
                            '${avisos[index].descripcion}',
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 15),
                          )),
                      onPressed: () =>
                          _abrirAvisoDetalle(avisos[index], context),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                          color: utils.colorPrincipal),
                      width: double.infinity,
                      height: 25,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${utils.fechaCompleta(DateTime.tryParse(avisos[index].fecha))}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.fade,
                            )
                          ]),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _abrirAvisoDetalle(AvisoModel aviso, BuildContext context) {
    Navigator.of(context).pushNamed('AvisoDetalle', arguments: aviso);
  }

  _creaItemsFAB() {
    return FutureBuilder(
      future: avisosProvider.obtenerNumeroCaseta(_prefs.usuarioLogged),
      builder:
          (BuildContext context, AsyncSnapshot<Map<int, dynamic>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.containsKey(1)) {
            return _creaFABAyuda(numero: snapshot.data[1]);
          } else {
            return _creaFABSoporte();
          }
        } else
          return FloatingActionButton(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(utils.colorPrincipal)),
              onPressed: null);
      },
    );
  }

  Widget _creaFABSoporte() {
    return FloatingActionButton(
      tooltip: 'Contactar a soporte',
      backgroundColor: Colors.white,
      child: Container(
          padding: EdgeInsets.all(10),
          child: SvgPicture.asset(
            utils.rutaIconoWhastApp,
            color: Color.fromRGBO(37, 211, 102, 1.0),
          )),
      onPressed: () {
        creaDialogYesNo(
            context,
            'Chat de WhatsApp',
            'Este canal de comunicación es únicamente para el soporte de la aplicación. NO es un canal directo con caseta. ¿Quieres continuar?',
            'Sí',
            'No', () async {
          await _launchWhatsApp(
              '524779205753', 'Hola. Necesito ayuda con la aplicación Dostop.');
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }, () => Navigator.of(context, rootNavigator: true).pop('dialog'));
      },
    );
  }

  Widget _creaFABAyuda({String numero}) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      overlayColor: Theme.of(context).scaffoldBackgroundColor,
      overlayOpacity: 0.5,
      backgroundColor: utils.colorPrincipal,
      children: [
        SpeedDialChild(
          child: Container(
              padding: EdgeInsets.all(10),
              child: SvgPicture.asset(
                utils.rutaIconoWhastApp,
                color: Color.fromRGBO(37, 211, 102, 1.0),
              )),
          backgroundColor: Colors.white,
          labelBackgroundColor: Theme.of(context).cardColor,
          label: 'Contacto con soporte',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () async {
            await _launchWhatsApp('524779205753',
                'Hola. Necesito ayuda con la aplicación Dostop.');
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.security),
          backgroundColor: Colors.grey,
          labelBackgroundColor: Theme.of(context).cardColor,
          label: 'Contacto a caseta',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () async {
            await _launchWhatsApp(numero, '');
          },
        ),
      ],
    );
  }

  _launchWhatsApp(String numero, String mensaje) async {
    final link = WhatsAppUnilink(phoneNumber: numero, text: mensaje);
    // Convert the WhatsAppUnilink instance to a string.
    // Use either Dart's string interpolation or the toString() method.
    // The "launch" method is part of "url_launcher".
    await launch('$link');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
