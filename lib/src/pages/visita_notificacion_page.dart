import 'dart:io';
import 'dart:typed_data';

import 'package:dostop_v2/src/models/visita_model.dart';
import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/push_manager/push_notification_manager.dart';
// import 'package:dostop_v2/src/push_manager/push_notification_manager.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
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
  bool _respuestaEnviada = false;
  final _prefs = PreferenciasUsuario();
  String id ='';

  @override
  void initState() {
    // _pushManager.notificacionForeground = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final VisitaModel visita = ModalRoute.of(context).settings.arguments;
    id=visita.idVisitas;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: utils.appBarLogoD(
            titulo: visita.tipoVisita != 3 ? 'Visita' : 'V. Sin Respuesta',
            backbtn: null),
        body: _creaBody(visita),
        floatingActionButton: visita.tipoVisita == 1
            ? _creaFABAprobar(context, visita.idVisitas)
            : _creaFABOK(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _creaBody(VisitaModel visita) {
    // HapticFeedback.vibrate();
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Visibility(visible: visita.tipoVisita==3, child: Text('El tiempo para responder esta visita ha expirado', textAlign: TextAlign.center, style: TextStyle(color: utils.colorPrincipal, fontSize: 16, fontWeight: FontWeight.bold),)),
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
                        margin: EdgeInsets.all(2),
                        alignment: Alignment.topCenter)
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
                                  child:
                                      Center(child: Icon(Icons.broken_image))),
                              imageUrl: imagenes[index],
                              fit: BoxFit.cover,
                              fadeInDuration: Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                      ),
                      onLongPress: () {
                        HapticFeedback.vibrate();
                        _descargaImagen(context, imagenes[index]);
                      },
                    );
                }),
          ),
          SizedBox(height: 10),
          Text(
              'Mantén presionada cualquier imagen para guardarla en tu galería'),
        ],
      );
  }

  Widget _datosVisitante(VisitaModel visita) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Nombre',
            style: TextStyle(
                color: utils.colorPrincipal,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        Text(visita.visitante,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 30,
        ),
        Text('Placas',
            style: TextStyle(
                color: utils.colorPrincipal,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        Text(visita.placa,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('Vehículo',
            style: TextStyle(
                color: utils.colorPrincipal,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        Text(visita.modelo,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('Marca',
            style: TextStyle(
                color: utils.colorPrincipal,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        Text(visita.marca,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(visita.tipoVisita == 1 ? 'Motivo' : '',
            style: TextStyle(
                color: utils.colorPrincipal,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        Text(visita.tipoVisita == 1 ? visita.motivoVisita : '',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 100)
      ],
    );
  }

  Widget _creaFABAprobar(BuildContext context, String idVisita) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          child: MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: utils.colorContenedorSaldo,
            height: 90,
            child: Container(
              width: 90,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.transfer_within_a_station,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Aceptar',
                    textAlign: TextAlign.center,
                    style: utils.estiloBotones(16),
                  ),
                ],
              ),
            ),
            onPressed: _respuestaEnviada
                ? null
                : () {
                    setState(() {
                      _respuestaEnviada = true;
                    });
                    _notifProvider
                        .respuestaVisita(_prefs.usuarioLogged, idVisita, 1)
                        .then((respEnviada) {
                      if (respEnviada)
                        print('Respuesta enviada');
                      else
                        print('No se pudo enviar la respuesta');
                    });
                    toast.showToast('Tu visita está en camino...',
                      backgroundColor: Color.fromRGBO(25, 163, 14, 1.0), 
                      textStyle: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'Poppins'), 
                      borderRadius: BorderRadius.circular(20),);
                    Navigator.pop(context);
                  },
          ),
        ),
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: utils.colorPrincipal,
          height: 90,
          child: Container(
            width: 90,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.pan_tool,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 5),
                Text(
                  'Rechazar',
                  textAlign: TextAlign.center,
                  style: utils.estiloBotones(16),
                ),
              ],
            ),
          ),
          onPressed: _respuestaEnviada
              ? null
              : () {
                  setState(() {
                    _respuestaEnviada = true;
                  });
                  _notifProvider
                      .respuestaVisita(_prefs.usuarioLogged, idVisita, 2)
                      .then((respEnviada) {
                    if (respEnviada)
                      print('Respuesta enviada');
                    else
                      print('No se pudo enviar la respuesta');
                  });
                  toast.showToast('¡Haz rechazado la visita!',
                    backgroundColor: Color.fromRGBO(233, 55, 54, 1.0), 
                    textStyle: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'Poppins'), 
                    borderRadius: BorderRadius.circular(20),);
                  Navigator.pop(context);
                },
        ),
      ],
    );
  }

  void _descargaImagen(BuildContext context, String url) async {
    Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
        Icon(Icons.cloud_download), 'Descargando...', 1));
    try {
      if (Platform.isAndroid) {
        if (!await utils.obtenerPermisosAndroid())
          throw 'No tienes permisos de almacenamiento';
      }
      var res = await http.get(url);
      await ImageGallerySaver.saveImage(Uint8List.fromList(res.bodyBytes));
      // print(result);
      Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
          Icon(Icons.file_download), 'Imagen guardada', 2));
    } catch (e) {
      Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
          Icon(Icons.error), 'La imagen no pudo ser guardada', 2));
    }
  }

  Widget _creaFABOK(BuildContext context) {
    return FloatingActionButton.extended(
        backgroundColor: utils.colorPrincipal,
        icon: Icon(Icons.close),
        label: Text('Cerrar'),
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
