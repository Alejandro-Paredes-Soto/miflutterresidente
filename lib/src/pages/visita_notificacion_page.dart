import 'dart:io';
import 'dart:typed_data';

import 'package:dostop_v2/src/models/visita_model.dart';
import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:dostop_v2/src/push_manager/push_notification_manager.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/widgets/countdown_timer.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart' as toast;
import 'package:http/http.dart' as http;

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

class VisitaNofificacionPage extends StatefulWidget {
  @override
  _VisitaNofificacionPageState createState() => _VisitaNofificacionPageState();
}

class _VisitaNofificacionPageState extends State<VisitaNofificacionPage> {
  final _notifProvider = NotificacionesProvider();
  final _pushManager = PushNotificationsManager();
  final _serviceCall = VisitasProvider();
  bool _respuestaEnviada = false, _tiempoVencido = false;
  final _prefs = PreferenciasUsuario();
  String id = '';

  @override
  void initState() {
    // _pushManager.notificacionForeground = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final VisitaModel visita = ModalRoute.of(context).settings.arguments;
    id = visita.idVisitas;
    if (visita.tipoVisita == 3) {
      _tiempoVencido = true;
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: utils.appBarLogo(
              titulo: visita.tipoVisita != 3
                  ? 'Tienes una visita'
                  : 'V. sin respuesta',
              backbtn: null),
          body: _creaBody(visita),
          floatingActionButton: visita.tipoVisita == 1 && !_tiempoVencido
              ? _creaFABAprobar(context, visita.idVisitas, visita.fechaCompleta)
              : _creaFABOK(context),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat),
    );
  }

  Widget _creaBody(VisitaModel visita) {
    DateTime fecha = visita.fechaCompleta == null
        ? DateTime.now()
        : visita.fechaCompleta.add(Duration(minutes: 1));
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
                    Text('Tiempo para responder '),
                    CountdownTimer(
                      showZeroNumbers: false,
                      endTime: fecha.millisecondsSinceEpoch,
                      secSymbol: '',
                      textStyle: utils.estiloBotones(18,
                          color: Theme.of(context).textTheme.bodyText2.color),
                      onEnd: () => setState(() => _tiempoVencido = true),
                    ),
                    Text(' seg'),
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
          _imagenesVisitante(utils.validaImagenes(
              [visita.imgRostro, visita.imgId, visita.imgPlaca])),
          SizedBox(height: 20),
          _datosVisitante(visita),
        ],
      ),
    );
  }

  Widget _imagenesVisitante(List<String> imagenes) {
    if (imagenes.length == 0)
      return Container(
        height: 200,
        child: Center(child: Text('No hay imagenes para mostrar')),
      );
    else
      return Column(
        children: <Widget>[
          Container(
            height: 200,
            child: Swiper(
                loop: false,
                itemCount: imagenes.length,
                pagination: imagenes.length > 1
                    ? SwiperPagination(
                        alignment: Alignment.bottomCenter,
                        builder: DotSwiperPaginationBuilder(
                            color: Colors.white60,
                            activeColor: Colors.white60,
                            activeSize: 20.0))
                    : null,
                scale: 0.8,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    child: PinchZoomImage(
                      image: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          child: CachedNetworkImage(
                            placeholder: (context, url) =>
                                Image.asset(utils.rutaGifLoadRed),
                            errorWidget: (context, url, error) => Container(
                                height: 200,
                                child: Center(child: Icon(Icons.broken_image))),
                            imageUrl: imagenes[index],
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(milliseconds: 300),
                          ),
                        ),
                      ),
                    ),
                    onLongPress: () {
                      HapticFeedback.vibrate();
                      utils.descargaImagen(context, imagenes[index]);
                    },
                  );
                }),
          ),
        ],
      );
  }

  Widget _datosVisitante(VisitaModel visita) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Nombre', style: utils.estiloTituloInfoVisita(12)),
        Text(visita.visitante,
            style: utils.estiloBotones(18,
                color: Theme.of(context).textTheme.bodyText2.color)),
        SizedBox(
          height: 10,
        ),
        Text('Placas', style: utils.estiloTituloInfoVisita(12)),
        Text(visita.placa,
            style: utils.estiloBotones(18,
                color: Theme.of(context).textTheme.bodyText2.color)),
        SizedBox(height: 10),
        Text('Vehículo', style: utils.estiloTituloInfoVisita(12)),
        Text(visita.modelo,
            style: utils.estiloBotones(18,
                color: Theme.of(context).textTheme.bodyText2.color)),
        SizedBox(height: 10),
        Text('Marca', style: utils.estiloTituloInfoVisita(12)),
        Text(visita.marca,
            style: utils.estiloBotones(18,
                color: Theme.of(context).textTheme.bodyText2.color)),
        SizedBox(height: 10),
        Text(visita.tipoVisita == 1 ? 'Motivo' : '',
            style: utils.estiloTituloInfoVisita(12)),
        Text(visita.tipoVisita == 1 ? visita.motivoVisita : '',
            style: utils.estiloBotones(18,
                color: Theme.of(context).textTheme.bodyText2.color)),
        SizedBox(height: 120)
      ],
    );
  }

  Widget _creaFABAprobar(
      BuildContext context, String idVisita, DateTime fecha) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RawMaterialButton(
                  onPressed: _respuestaEnviada
                      ? null
                      : () {
                        _serviceCall.serviceCall(idVisita);
                        Navigator.pushNamed(context, 'agora', arguments: [fecha, idVisita]);
                      
                      } ,
                  child: new Icon(
                    Icons.call,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  shape: new CircleBorder(),
                  elevation: 8.0,
                  fillColor: utils.colorPrincipal,
                  padding: const EdgeInsets.all(15.0),
                ),
              ],
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
            // const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     _crearBtnLlamada(),
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  Widget _crearBtnRespuesta({
    String titulo,
    int idRespuesta,
    String idVisita,
  }) {
    return ElevatedContainer(
      child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: idRespuesta == 1
              ? utils.colorAcentuado
              : utils.colorToastRechazada,
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
    return RaisedButton(
        color: utils.colorPrincipal,
        child: Container(
            width: 100,
            height: 60,
            alignment: Alignment.center,
            child: Text('Cerrar', style: utils.estiloBotones(12))),
        onPressed: () => Navigator.pop(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)));
  }

  @override
  void dispose() {
    _notifProvider.actualizarEstadoNotif(_prefs.usuarioLogged);
    // _pushManager.notificacionForeground = false;
    _pushManager.idsVisitas.remove(id);
    super.dispose();
  }
}
