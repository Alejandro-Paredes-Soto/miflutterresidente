import 'package:auto_size_text/auto_size_text.dart';
import 'package:dostop_v2/src/providers/config_usuario_provider.dart';
import 'package:dostop_v2/src/providers/login_provider.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:dostop_v2/src/widgets/gradient_button.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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

import '../../main.dart';

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
  bool _nuevaEncuesta = false, _respuestaEnviada = false, _accesos = false;
  EncuestaModel _datosEncuesta;
  int _noMolestar = 2;
  String _numeroCaseta = '';

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
    avisosProvider.obtenerNumeroCaseta(_prefs.usuarioLogged).then((respuesta) {
      if (respuesta.containsKey(1)) {
        if (!mounted) return;
        setState(() {
          _numeroCaseta = respuesta[1];
        });
      }
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
    configUsuarioProvider
        .obtenerEstadoConfig(_prefs.usuarioLogged, 1)
        .then((estadoNoMolestar) {
      setState(() {
        if (estadoNoMolestar.containsKey('valor')) {
          _noMolestar = estadoNoMolestar['valor'] == '1' ? 1 : 0;
        } else {
          _noMolestar = 3;
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
        centerTitle: false,
        title: Image.asset(
          utils.rutaLogoDostopDPng,
          height: 40,
        ),
        actions: [
          IconButton(
              padding: EdgeInsets.all(0),
              icon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round,
                    size: 30,
                  ),
                  Text('Tema', style: TextStyle(fontSize: 10)),
                ],
              ),
              onPressed: MyApp.of(context).changeTheme),
          SizedBox(width: 10),
          IconButton(
            padding: EdgeInsets.all(0),
            onPressed: _abrirSoporte,
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  utils.rutaIconoWhastApp,
                  height: 30,
                  color: Theme.of(context).iconTheme.color,
                ),
                Text('Soporte', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: _creaBody(),
    );
  }

  Widget _creaBody() {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 100.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                _creaPrimerFila(),
                _creaBtnFrecuentes(),
                _creaTerceraFila(),
                _creaCuartaFila(),
                _creaQuintaFila(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _creaPrimerFila() {
    return Container(
        height: 220,
        child: Row(
          children: [
            Expanded(child: _creaBtnVisitas()),
            SizedBox(width: 20),
            Flexible(
                child: Column(
              children: [
                Expanded(
                  child: _creaBtnIcono(
                      rutaIcono: utils.rutaIconoAvisos,
                      titulo: 'Avisos',
                      ruta: 'avisos'),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: _creaBtnIcono(
                      rutaIcono: utils.rutaIconoEmergencia,
                      titulo: 'SOS',
                      subtitulo: 'Emergencias',
                      ruta: 'emergencias'),
                ),
              ],
            ))
          ],
        ));
  }

  Widget _creaBtnVisitas() {
    return RaisedGradientButton(
      elevation: 8,
      padding: EdgeInsets.all(10.0),
      gradient: utils.colorGradientePrincipal,
      borderRadius: BorderRadius.circular(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText('Historial\nde visitas',
              maxLines: 2,
              wrapWords: false,
              textAlign: TextAlign.center,
              style: utils.estiloBotones(30)),
          SizedBox(height: 20),
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
    return Container(
      height: 120,
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
                margin: EdgeInsets.only(right: 8.0),
                child: ElevatedContainer(
                  child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15.0)),
                      alignment: Alignment.center,
                      child: _creaSwitchNoMolestar()),
                ),
              )),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 12),
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

  Widget _creaQuintaFila() {
    return Container(
      height: 120,
      padding: EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Visibility(
              visible: _accesos,
              child: Flexible(
                  child: _creaBtnIconoMini(
                      rutaIcono: utils.rutaIconoAccesos,
                      titulo: 'Mis accesos',
                      ruta: 'misAccesos'))),
          Visibility(visible: _accesos, child: SizedBox(width: 20)),
          Visibility(
              visible: _numeroCaseta != '',
              child: Expanded(
                  child: _creaBtnIconoMini(
                      rutaIcono: utils.rutaIconoCaseta,
                      titulo: 'Contacto\na caseta',
                      onPressed: () => _launchWhatsApp(_numeroCaseta, '')))),
          Visibility(visible: _numeroCaseta != '', child: SizedBox(width: 20)),
          Flexible(
              child: _creaBtnIconoMini(
                  rutaIcono: utils.rutaIconoCerrarSesion,
                  titulo: 'Cerrar sesión',
                  onPressed: _cerrarSesion)),
          Visibility(visible: _numeroCaseta == '', child: SizedBox(width: 20)),
          Visibility(
              visible: _numeroCaseta == '',
              child: Expanded(child: Container())),
          Visibility(visible: !_accesos, child: SizedBox(width: 20)),
          Visibility(visible: !_accesos, child: Expanded(child: Container())),
        ],
      ),
    );
  }

  Widget _creaBtnIcono(
      {String rutaIcono, String titulo, String subtitulo, String ruta}) {
    return ElevatedContainer(
      child: RaisedButton(
          padding: EdgeInsets.symmetric(horizontal: 10),
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(
                  rutaIcono,
                  height: 25,
                  color: Theme.of(context).iconTheme.color,
                ),
                SizedBox(width: 10),
                Flexible(
                  child: AutoSizeText(
                    titulo,
                    wrapWords: false,
                    style: utils.estiloBotones(30,
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ),
              ]),
              Visibility(
                  visible: subtitulo != null, child: Text(subtitulo ?? ''))
            ],
          ),
          onPressed: () => Navigator.pushNamed(context, ruta)),
    );
  }

  Widget _creaBtnIconoMini({
    String rutaIcono,
    String titulo,
    String ruta,
    Function onPressed,
  }) {
    return ElevatedContainer(
      child: RaisedButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        color: Theme.of(context).cardColor,
        elevation: 0,
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                rutaIcono,
                height: 25,
                color: Theme.of(context).iconTheme.color,
              ),
              SizedBox(height: 10),
              Flexible(
                child: AutoSizeText(
                  titulo,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  maxLines: 2,
                  wrapWords: false,
                  style: utils.estiloBotones(16,
                      color: Theme.of(context).textTheme.bodyText2.color),
                ),
              ),
            ],
          ),
        ),
        onPressed:
            ruta == null ? onPressed : () => Navigator.pushNamed(context, ruta),
      ),
    );
  }

  Widget _creaBtnFrecuentes() {
    return Container(
      height: 120,
      padding: EdgeInsets.only(top: 20.0),
      child: ElevatedContainer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: FlatButton(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              color: utils.colorAcentuado,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText('Visitas frecuentes',
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                letterSpacing: -0.5,
                                fontWeight: FontWeight.w900)),
                        Text('Envía códigos de acceso',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: SvgPicture.asset(utils.rutaIconoVisitantesFrecuentes,
                        height: 35, width: 20, color: Colors.black),
                  ),
                ],
              ),
              onPressed: () => Navigator.pushNamed(context, 'visitantesFreq')),
        ),
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

  Widget _creaSwitchNoMolestar() {
    Map<String, dynamic> _dataNoMolestar = _obtenerMensajeSwitch(_noMolestar);
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText('No molestar',
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  AutoSizeText(_dataNoMolestar['estado'],
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _dataNoMolestar['color'])),
                ]),
          ),
          CupertinoSwitch(
              activeColor: utils.colorToastRechazada,
              trackColor: utils.colorAcentuado,
              value: _noMolestar == 1,
              onChanged: _noMolestar == 3
                  ? null
                  : (valor) {
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
                          _cambiaModoNoMolestar(1);
                        }, () {
                          setState(
                            () {
                              _noMolestar = 0;
                            },
                          );
                          Navigator.pop(context);
                        });
                      else
                        _cambiaModoNoMolestar(0);
                    }),
        ],
      ),
    );
  }

  Map<String, dynamic> _obtenerMensajeSwitch(int valor) {
    switch (valor) {
      case 0:
        return {'estado': 'Desactivado', 'color': utils.colorAcentuado};
      case 1:
        return {'estado': 'Activado', 'color': utils.colorToastRechazada};
      case 2:
        return {'estado': 'Cargando...', 'color': utils.colorSecundario};
      default:
        return {'estado': 'No disponible', 'color': utils.colorSecundario};
    }
  }

  _cambiaModoNoMolestar(int valor) async {
    creaDialogProgress(context, 'Cambiando...');
    Map resultado = await configUsuarioProvider.configurarOpc(
        _prefs.usuarioLogged, 1, valor == 1);
    Navigator.pop(context);
    setState(() {
      _noMolestar = valor;
      Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
          Icon(resultado['OK'] == 1 ? Icons.notifications_active : Icons.error),
          resultado['message'],
          5));
    });
  }

  _launchWhatsApp(String numero, String mensaje) async {
    final link = WhatsAppUnilink(phoneNumber: numero, text: mensaje);
    // Convert the WhatsAppUnilink instance to a string.
    // Use either Dart's string interpolation or the toString() method.
    // The "launch" method is part of "url_launcher".
    await launch('$link');
  }

  _abrirSoporte() {
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
