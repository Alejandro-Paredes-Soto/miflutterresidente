import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dostop_v2/src/models/aviso_model.dart';
import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/push_manager/mensajes_stream.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {
  final _prefs = PreferenciasUsuario();

  static final PushNotificationsManager _instancia =
      new PushNotificationsManager._internal();

  factory PushNotificationsManager() => _instancia;

  PushNotificationsManager._internal();

  MensajeStream mensajeStream = MensajeStream.instancia;
  final notifProvider = NotificacionesProvider();
  List<String> idsVisitas = [];

  Future<void> initNotifications() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.requestPermission();

    messaging.getToken().then((token) {
      log("token $token");
      if(token != null){
        _prefs.token = token;
      }
    });

    FirebaseMessaging.onMessage.listen((event) async {
      log('message');
      if(event.notification != null)
        _evaluaMensaje(event);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      log("message ${event.notification}");
      if(event.notification != null)
        _evaluaMensaje(event);
    });
  }

  _evaluaMensaje(RemoteMessage info) async {
    String titulo = '';
    String mensaje = '';
    String imgAviso = '';
  
    if (Platform.isAndroid) {
      titulo = info.notification!.title.toString().toLowerCase();
      mensaje = info.notification!.body ?? '';
      imgAviso = titulo == 'aviso' ? json.decode(info.data['data'])['img'] : '';
    } else {
      titulo = info.notification!.title.toString().toLowerCase();
      mensaje = info.notification!.body ?? '';
      imgAviso = titulo == 'aviso' ? json.decode(info.data['data'])['img'] : '';
    }
    switch (titulo) {
      case 'encuesta':
        mensajeStream.addMessage({'encuesta': 'encuesta'});
        break;
      case 'aviso':
        mensajeStream.addMessage({
          'aviso': new AvisoModel(
              descripcion: mensaje, fecha: DateTime.now().toString(), imgAviso: imgAviso)
        });
        break;
      case 'visita':
        notifProvider
            .obtenerUltimaNotificacion(_prefs.usuarioLogged)
            .then((visita) {
          if (visita != null) {
            if (!idsVisitas.contains(visita.idVisitas)) {
              idsVisitas.add(visita.idVisitas);
              mensajeStream.addMessage({'visita': visita});
            }
          }
        });
        break;
      case 'visita frecuente':
        notifProvider
            .obtenerUltimaNotificacion(_prefs.usuarioLogged)
            .then((visita) {
          if (visita != null) {
            if (!idsVisitas.contains(visita.idVisitas)) {
              idsVisitas.add(visita.idVisitas);
              visita.tipoVisita = 2;
              mensajeStream.addMessage({'visita': visita});
            }
          }
        });
        break;
        case 'visita rechazada':
        notifProvider
            .obtenerUltimaNotificacion(_prefs.usuarioLogged)
            .then((visita) {
          if (visita != null) {
            if (!idsVisitas.contains(visita.idVisitas)) {
              idsVisitas.add(visita.idVisitas);
              visita.tipoVisita = 2;
              mensajeStream.addMessage({'visita': visita});
            }
          }
        });
        break;
      case 'áreas comunes':
        mensajeStream.addMessage(
            {'areas': mensaje});
        break;
      //IMPLEMENTACIÓN A FUTURO, EN RESPUESTA DE LUIS PARA APLICARLO Y DE FERNANDO PARA VALIDARLO
      //   case 'respuesta incidente':
      //     mensajeStream.addMessage({'incidente': 'El guardia respondió tu reporte: $mensaje'??'Nueva notificación'});
      //     break;
    }
  }
  mostrarUltimaVisita() async {
    final visita = await notifProvider
        .obtenerUltimaNotificacion(_prefs.usuarioLogged)
        .timeout(Duration(milliseconds: 1300), onTimeout: () {
      return null;
    });
    if (visita != null) {
      if (!idsVisitas.contains(visita.idVisitas)) {
        idsVisitas.add(visita.idVisitas);
        if (visita.codigo != '' || visita.noMolestar=='1') visita.tipoVisita = 2;

        mensajeStream.addMessage({'visita': visita});
      }
    }
  }
}

