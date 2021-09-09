import 'package:dostop_v2/src/providers/config_usuario_provider.dart';
import 'package:dostop_v2/src/providers/login_provider.dart';
import 'package:dostop_v2/src/widgets/gradient_button.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import 'package:dostop_v2/src/providers/avisos_provider.dart';
import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/utils/dialogs.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
  final _loginProvider = LoginProvider();
  final _prefs = PreferenciasUsuario();
  Map _resultados;
  bool _nuevaEncuesta = false,
      _respuestaEnviada = false,
      _noMolestar = false,
      _accesos = false;
  EncuestaModel _datosEncuesta;

  @override
  void initState() {
    super.initState();
    avisosProvider.obtenerUltimaEncuesta(_prefs.usuarioLogged).then((encuesta) {
      ///previene la llamada del setState cuando el widget ya ha sido destruido. (if (!mounted) return;)
      if (!mounted) return;
      setState(() {
        if (encuesta.containsKey(1)) {
          _datosEncuesta = encuesta[1];
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
            _datosEncuesta = encuesta[1];
            _nuevaEncuesta = true;
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        centerTitle: false,
        title: Image.asset(
          utils.rutaLogoDostopDPng,
          height: 38,
        ),
        actions: [
          FlatButton(
            onPressed: _cerrarSesion,
            child: Column(
              children: [
                Icon(
                  Icons.info,
                  size: 35,
                  semanticLabel: 'Ayuda',
                ),
                Text('Ayuda')
              ],
            ),
          ),
        ],
      ),
      body: _creaBody(),
    );
  }

  Widget _creaBody() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _creaPrimerFila(),
            _creaBtnFrecuentes(),
            _creaTerceraFila(),
            _creaCuartaFila(),
          ],
        ),
      ),
    );
  }

  Widget _creaPrimerFila() {
    return Container(
        height: 250,
        child: Row(
          children: [
            Flexible(child: _creaBtnVisitas()),
            SizedBox(width: 20),
            Flexible(
                child: Column(
              children: [
                Expanded(
                  child: _creaBtnIcono(
                      rutaIcono: utils.rutaIconoAvisos,
                      titulo: 'Avisos',
                      ruta: 'avisos',
                      iconoIzquierda: true),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: _creaBtnIcono(
                      rutaIcono: utils.rutaIconoEmergencia,
                      titulo: 'SOS',
                      subtitulo: 'Emergencias',
                      ruta: 'emergencias',
                      iconoIzquierda: true),
                ),
              ],
            ))
          ],
        ));
  }

  Widget _creaBtnVisitas() {
    return RaisedGradientButton(
      padding: EdgeInsets.all(15.0),
      gradient: utils.colorGradientePrincipal,
      borderRadius: BorderRadius.circular(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Historial de visitas',
              textAlign: TextAlign.center, style: utils.estiloBotones(28)),
          SizedBox(height: 10),
          SvgPicture.asset(
            utils.rutaIconoVisitas,
            height: 38,
            color: Colors.white,
          )
        ],
      ),
      onPressed: () => Navigator.pushNamed(context, 'visitas'),
    );
  }

  Widget _creaTerceraFila() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Row(
        children: [
          Expanded(
              child: _creaBtnIconoMini(
                  rutaIcono: utils.rutaIconoEstadoDeCuenta,
                  titulo: 'Estados de cuenta',
                  ruta: 'estadosCuenta')),
          SizedBox(width: 20),
          Expanded(
              child: _creaBtnIconoMini(
                  rutaIcono: utils.rutaIconoAreasComunes,
                  titulo: 'Áreas comunes',
                  ruta: 'areasComunes')),
          SizedBox(width: 20),
          Expanded(
              child: _creaBtnIconoMini(
                  rutaIcono: utils.rutaIconoMiCasa,
                  titulo: 'Mi casa',
                  ruta: 'miCasa'))
        ],
      ),
    );
  }

  Widget _creaCuartaFila() {
    return Container(
      height: 120,
      padding: EdgeInsets.only(top: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(right:8.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0),
              color: Theme.of(context).cardColor),
              child: _creaSwitchNoMolestar())),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left:14.0),
              child: _creaBtnIconoMini(
                rutaIcono: utils.rutaIconoPromociones,
                titulo: 'Promos',
                ruta: 'promociones',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _creaBtnIcono(
      {String rutaIcono,
      String titulo,
      String subtitulo,
      String ruta,
      bool iconoIzquierda = false}) {
    return RaisedButton(
        elevation: 8,
        color: Theme.of(context).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconoIzquierda
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        SvgPicture.asset(
                          rutaIcono,
                          height: 25,
                          color: Colors.white,
                        ),
                        Flexible(
                          child: Text(
                            titulo,
                            style: utils.estiloBotones(30),
                          ),
                        ),
                      ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset(
                        rutaIcono,
                        height: 25,
                        color: Colors.white,
                      ),
                      Text(
                        titulo,
                        style: utils.estiloBotones(30),
                      ),
                    ],
                  ),
            Visibility(visible: subtitulo != null, child: Text(subtitulo ?? ''))
          ],
        ),
        onPressed: () => Navigator.pushNamed(context, ruta));
  }

  Widget _creaBtnIconoMini({
    String rutaIcono,
    String titulo,
    String ruta,
  }) {
    return Container(
      height: 100,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                rutaIcono,
                height: 25,
                color: Colors.white,
              ),
              SizedBox(height: 5),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: utils.estiloBotones(16),
              ),
            ],
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, ruta),
      ),
    );
  }

  Widget _creaBtnFrecuentes() {
    return Container(
      height: 130,
      padding: EdgeInsets.only(top: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: FlatButton(
            padding: EdgeInsets.all(0.0),
            color: utils.colorAcentuado,
            child: ListTile(
              tileColor: Colors.transparent,
              title: Text('Visitas frecuentes',
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w900)),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: Text('Envía códigos de acceso',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ),
              trailing: SvgPicture.asset(utils.rutaIconoVisitantesFrecuentes,
                  height: 40, color: Colors.black),
            ),
            onPressed: () => Navigator.pushNamed(context, 'visitantesFreq')),
      ),
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
                        ? () => _responderEncuesta(
                              pregunta: _datosEncuesta.pregunta,
                              respuestas: _datosEncuesta.respuestas,
                            )
                        : () => _mostrarResultados(
                            _datosEncuesta.pregunta, _resultados[1]),
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

  _responderEncuesta({String pregunta, List<Respuesta> respuestas}) {
    List<CupertinoActionSheetAction> actions = respuestas
        .map((element) => CupertinoActionSheetAction(
            child: Text(
              element.respuestaEncuesta,
              style: TextStyle(
                  fontSize: 20.0, color: Theme.of(context).iconTheme.color),
              textScaleFactor: 1.0,
            ),
            onPressed: () => _enviarRespuesta(
                  int.tryParse(element.idRespuestaEncuesta),
                )))
        .toList();

    showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoActionSheet(
              title: Text(
                pregunta,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyText2.color,
                ),
                textScaleFactor: 0.9,
              ),
              actions: actions,
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textScaleFactor: 1.0,
                ),
              ),
            ));
  }

  _enviarRespuesta(int respuesta) {
    Navigator.pop(context);
    creaDialogProgress(context, 'Enviando respuesta');
    avisosProvider
        .enviarRespuestaEncuesta(_prefs.usuarioLogged, respuesta)
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
        setState(() {
          _nuevaEncuesta = false;
        });
        Scaffold.of(context).showSnackBar(
            utils.creaSnackBarIcon(Icon(Icons.error), resultados[2], 10));
      }
    });
  }

  _mostrarResultados(String titulo, List<ResultadosEncuestaModel> resultados) {
    Map<String, double> dataMap = {};
    resultados.forEach((element) {
      dataMap[element.respuestaEncuesta] = double.tryParse(element.porcentaje);
    });
    //Map<String,double> dataMap={"Test":1,"Test2":1};
    creaDialogWidget(
        context,
        titulo,
        PieChart(
          dataMap: dataMap,
          legendOptions: LegendOptions(
            showLegends: true,
            legendPosition: LegendPosition.top,
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
            decimalPlaces: 1,
          ),
        ),
        'Aceptar',
        () => Navigator.pop(context));
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
                child: ListTile(
                  title: Text('Modo no molestar',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_noMolestar ? 'Activado' : 'Desactivado',
                      textAlign: TextAlign.right),
                  trailing: CupertinoSwitch(
                      activeColor: utils.colorPrincipal,
                      trackColor: utils.colorContenedorSaldo,
                      value: _noMolestar,
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
                      }),
                ),
              );
            } else {
              return Container(
              );
            }
          } else {
            return ListTile(
              title: Text(
                'Modo no molestar',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Cargando...', textAlign: TextAlign.right),
              trailing: CupertinoSwitch(value: false, onChanged: null),
            );
          }
        });
  }

  _cambiaModoNoMolestar(bool valor) async {
    creaDialogProgress(context, 'Cambiando...');
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

  _cerrarSesion() {
    creaDialogYesNoAlt(
        context,
        'Confirmar',
        '¿Estás seguro de que deseas cerrar sesión?\n\nDejarás de recibir notificaciones de tus visitas.',
        'Cerrar sesión',
        'Cancelar', () {
      Navigator.pop(context);
      creaDialogProgress(context, 'Cerrando Sesión...');
      _loginProvider.logout().then((logout) {
        Navigator.pop(context);
        if (logout) {
          _prefs.borraPrefs();
          print('${_prefs.usuarioLogged}');
          Navigator.of(context).pushNamedAndRemoveUntil(
              'login', (Route<dynamic> route) => false);
        } else {
          creaDialogSimple(
              context,
              '¡Ups! algo salió mal',
              'No se pudo cerrar tu sesión, verifica tu conexión a internet',
              'Aceptar',
              () => Navigator.pop(context));
        }
      });
    }, () => Navigator.pop(context));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
