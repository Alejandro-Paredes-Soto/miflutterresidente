import 'dart:io';

import 'package:dostop_v2/src/pages/agora_page.dart';
import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:dostop_v2/src/push_manager/push_notification_manager.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/widgets/countdown_timer.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart' as toast;

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

class VisitaNofificacionPage extends StatefulWidget {
  @override
  _VisitaNofificacionPageState createState() => _VisitaNofificacionPageState();
}

class _VisitaNofificacionPageState extends State<VisitaNofificacionPage> {
  final _notifProvider = NotificacionesProvider();
  final _pushManager = PushNotificationsManager();

  final _serviceCall = VisitasProvider();
  bool _respuestaEnviada = false,
      _tiempoVencido = false,
      _conectandoLlamada = false;
  final _prefs = PreferenciasUsuario();
  late double availableHeight;
  String id = '';
  List<Map<String, dynamic>> imagenes = [];
  bool loadImg = false;

  @override
  void initState() {
    // _pushManager.notificacionForeground = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final VisitaModel visita =
        ModalRoute.of(context)!.settings.arguments as VisitaModel;
    id = visita.idVisitas;
    if (visita.tipoVisita == 3) {
      _tiempoVencido = true;
    }

    availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    if (Platform.isIOS) {
      availableHeight =
          availableHeight == 492 ? (availableHeight - 15) : availableHeight;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: _appBar(visita),
          body: Platform.isIOS
              ? _creaBody(visita)
              : LayoutBuilder(
                  builder: (context, constraints) {
                    availableHeight = constraints.maxHeight - 20;
                    return _creaBody(visita);
                  },
                ),
          floatingActionButton: visita.tipoVisita == 1 && !_tiempoVencido
              ? _creaFABAprobar(context, visita.idVisitas, visita.fechaCompleta,
                  servicioLlamada: visita.servicioLlamada,
                  appIdAgora: visita.appIdAgora,
                  channelCall: visita.channelCall)
              : _creaFABOK(context),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat),
    );
  }

  AppBar _appBar(VisitaModel visita) {
    return utils.appBarLogo(
        titulo:
            visita.tipoVisita != 3 ? 'Tienes una visita' : 'V. sin respuesta',
        backbtn: null);
  }

  Widget _creaBody(VisitaModel visita) {
    DateTime fecha = visita.fechaCompleta == null
        ? DateTime.now()
        : visita.fechaCompleta!.add(Duration(minutes: 1));
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Stack(
        children: [
          imagenes.length == 0
              ? FutureBuilder(
                  future: utils.validaImagenesOrientacion(
                      [visita.imgRostro, visita.imgId, visita.imgPlaca]),
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.hasData) {
                      imagenes = snapshot.data as List<Map<String, dynamic>>;
                      return _imagenesVisitante(imagenes, visita, fecha);
                    } else {
                      return Stack(children: [
                        Image.asset(utils.rutaGifLoadRed,
                            alignment: Alignment.center),
                        _datosVisita(visita, fecha)
                      ]);
                    }
                  })
              : _imagenesVisitante(imagenes, visita, fecha),
        ],
      ),
    );
  }

  Widget _fechaVisita(DateTime fecha, VisitaModel visita) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 40),
        Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Visibility(
            visible: visita.tipoVisita == 1 || visita.tipoVisita == 3,
            child: AnimatedCrossFade(
              duration: Duration(milliseconds: 200),
              crossFadeState: !_tiempoVencido
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Tiempo para responder ',
                      style:
                          utils.estiloTextoSombreado(16, dobleSombra: false)),
                  CountdownTimer(
                    showZeroNumbers: false,
                    endTime: fecha.millisecondsSinceEpoch,
                    secSymbol: '',
                    textStyle:
                        utils.estiloTextoSombreado(18, dobleSombra: false),
                    onEnd: () => setState(() => _tiempoVencido = true),
                  ),
                  Text(' seg',
                      style:
                          utils.estiloTextoSombreado(16, dobleSombra: false)),
                ],
              ),
              secondChild: Text(
                'El tiempo para responder esta visita ha expirado',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: utils.colorToastRechazada,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagenesVisitante(
      List<Map> imagenes, VisitaModel visita, DateTime fecha) {
    if (imagenes.length == 0)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            child: Center(child: Text('No hay imagenes para mostrar')),
          ),
          _datosVisitante(visita)
        ],
      );
    else
      return Column(children: [
        Container(
          height: availableHeight,
          child: Swiper(
              loop: false,
              itemCount: imagenes.length,
              pagination: imagenes.length > 1
                  ? SwiperPagination(
                      alignment: Alignment.topCenter,
                      builder: DotSwiperPaginationBuilder(
                          color: Colors.white60,
                          activeColor: Colors.white60,
                          activeSize: 20.0))
                  : null,
              scale: 0.8,
              itemBuilder: (BuildContext context, int index) {
                bool isVertical = imagenes[index]['isVertical'];

                return isVertical
                    ? Stack(
                        children: [
                          _imgOrientacion(
                              context, availableHeight, imagenes[index]['img']),
                          _datosVisita(visita, fecha),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: _fechaVisita(fecha, visita),
                              ),
                              _imgOrientacion(
                                  context, 240, imagenes[index]['img']),
                              const SizedBox(height: 20),
                              _datosVisitante(visita)
                            ]),
                      );
              }),
        ),
      ]);
  }

  Widget _imgOrientacion(
      BuildContext context, double availableHeight, String img) {
    return Column(
      children: [
        GestureDetector(
          child: PinchZoomImage(
            image: Container(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: availableHeight,
                  alignment: Alignment.topCenter,
                  placeholder: (context, url) => Image.asset(
                      utils.rutaGifLoadRed,
                      alignment: Alignment.topCenter),
                  errorWidget: (context, url, error) => Container(
                      height: 240,
                      child: Center(child: Icon(Icons.broken_image))),
                  imageUrl: img,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 0),
                  placeholderFadeInDuration: Duration(milliseconds: 0),
                ),
              ),
            ),
          ),
          onLongPress: () {
            HapticFeedback.vibrate();
            utils.descargaImagen(context, img);
          },
        ),
      ],
    );
  }

  Widget _datosVisita(VisitaModel visita, DateTime fecha) {
    return Column(
      children: [
        Container(
          height: availableHeight,
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fechaVisita(fecha, visita),
              Expanded(child: _datosVisitante(visita)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _datosVisitante(VisitaModel visita) {
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text('Nombre', style: utils.estiloTituloInfoVisita(12)),
          Text(visita.visitante,
              style: utils.estiloTextoSombreado(16, dobleSombra: false)),
          SizedBox(height: 10),
          Text('Placas', style: utils.estiloTituloInfoVisita(12)),
          Text(visita.placa,
              style: utils.estiloTextoSombreado(16, dobleSombra: false)),
          SizedBox(height: 10),
          Text('Vehículo', style: utils.estiloTituloInfoVisita(12)),
          Text(visita.modelo,
              style: utils.estiloTextoSombreado(16, dobleSombra: false)),
          SizedBox(height: 10),
          Text('Marca', style: utils.estiloTituloInfoVisita(12)),
          Text(visita.marca,
              style: utils.estiloTextoSombreado(16, dobleSombra: false)),
          SizedBox(height: 10),
          Text('Tipo', style: utils.estiloTituloInfoVisita(12)),
          SizedBox(height: 10),
          Text(visita.tipoVisitante == '' ? 'Visita' : visita.tipoVisitante,
              style: utils.estiloTextoSombreado(16, dobleSombra: false)),
          Visibility(
              visible: visita.tipoVisita == 1, child: SizedBox(height: 10)),
          Text(visita.tipoVisita == 1 ? 'Motivo' : '',
              style: utils.estiloTituloInfoVisita(12)),
          Text(visita.tipoVisita == 1 ? visita.motivoVisita : '',
              style: utils.estiloTextoSombreado(16, dobleSombra: false)),
          SizedBox(height: _tiempoVencido ? 70 : 140)
        ],
      ),
    );
  }

  Widget _creaFABAprobar(BuildContext context, String idVisita, DateTime? fecha,
      {String servicioLlamada = '0',
      required String appIdAgora,
      required String channelCall}) {
    return AnimatedCrossFade(
      sizeCurve: Curves.bounceInOut,
      duration: Duration(milliseconds: 200),
      crossFadeState: _respuestaEnviada
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Padding(
        padding: EdgeInsets.all(8.0),
        child: LinearProgressIndicator(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(utils.colorPrincipal)),
      ),
      secondChild: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Visibility(
              visible: servicioLlamada == '1',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 120,
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                    width: 120,
                    child: _crearBtnLlamada(
                        idVisita: idVisita,
                        channelCall: channelCall,
                        appIdAgora: appIdAgora,
                        fecha: fecha),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _crearBtnRespuesta(
                    titulo: 'Aceptar', idRespuesta: 1, idVisita: idVisita),
                _crearBtnRespuesta(
                    titulo: 'Rechazar', idRespuesta: 2, idVisita: idVisita),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearBtnLlamada(
      {required String idVisita, channelCall, appIdAgora, fecha}) {
    return RawMaterialButton(
      onPressed: _respuestaEnviada || _conectandoLlamada
          ? null
          : () async {
              setState(() {
                _conectandoLlamada = true;
              });
              final resp = await _serviceCall.serviceCall(idVisita);

              setState(() {
                _conectandoLlamada = false;
              });

              if (resp['status'] == 'OK') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => AgoraPage(
                            channelCall: channelCall,
                            appIdAgora: appIdAgora,
                            fecha: fecha,
                            idVisita: idVisita)));
              } else {
                toast.showToast(
                  resp['message'],
                  textStyle: TextStyle(fontSize: 24, color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                );
              }
            },
      child: new Icon(Icons.call, color: Colors.white, size: 35.0),
      shape: new CircleBorder(),
      elevation: 8.0,
      fillColor: utils.colorPrincipal,
      padding: const EdgeInsets.all(15.0),
    );
  }

  Widget _crearBtnRespuesta({
    required String titulo,
    required int idRespuesta,
    required String idVisita,
  }) {
    return ElevatedContainer(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              primary: idRespuesta == 1
                  ? utils.colorAcentuado
                  : utils.colorToastRechazada),
          child: Container(
              alignment: Alignment.center,
              width: 100,
              height: 100,
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: utils.estiloTextoSombreado(22,
                    blurRadius: 6, offsetY: 3, dobleSombra: false),
              )),
          onPressed: _respuestaEnviada
              ? null
              : () {
                  setState(() {
                    _respuestaEnviada = true;
                  });
                  _notifProvider
                      .respuestaVisita(
                          _prefs.usuarioLogged, idVisita, idRespuesta)
                      .then((resp) {
                    toast.showToast(
                      resp['mensaje'],
                      backgroundColor: resp['id'] == '0'
                          ? idRespuesta == 1
                              ? utils.colorToastAceptada
                              : utils.colorToastRechazada
                          : null,
                      textStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    );
                    Navigator.pop(context);
                  });
                }),
    );
  }

  Widget _creaFABOK(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: utils.colorPrincipal,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Container(
            width: 100,
            height: 60,
            alignment: Alignment.center,
            child: Text('Cerrar', style: utils.estiloBotones(12))),
        onPressed: () => Navigator.pop(context));
  }

  @override
  void dispose() {
    _notifProvider.actualizarEstadoNotif(_prefs.usuarioLogged);
    _pushManager.idsVisitas.remove(id);
    super.dispose();
  }
}
