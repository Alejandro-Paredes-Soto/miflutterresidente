import 'dart:async';
import 'dart:developer';

import 'package:dostop_v2/src/models/aviso_model.dart';
import 'package:dostop_v2/src/providers/login_provider.dart';
import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/push_manager/mensajes_stream.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushNotificationsManagerOneSignal {
  final _prefs = PreferenciasUsuario();
  final _loginProvider = LoginProvider();

  static final PushNotificationsManagerOneSignal _instancia =
      new PushNotificationsManagerOneSignal._internal();

  factory PushNotificationsManagerOneSignal() => _instancia;

  PushNotificationsManagerOneSignal._internal();

  MensajeStream mensajeStream = MensajeStream.instancia;
  final notifProvider = NotificacionesProvider();

  List<String> idsVisitas = [];

  Future<void> initNotifications() async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared.setAppId("42665aa6-8bda-4596-b0fb-9ca0b5569b8d");
   
    OneSignal.shared.setNotificationWillShowInForegroundHandler((event) {
      log("Aqui2");
      _evaluaPayload(event.notification);
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
          log("aqui1");
      _evaluaPayload(result.notification);
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
        if (!changes.from.isSubscribed && changes.to.isSubscribed) {
          _prefs.playerID = changes.to.userId!;
          log(_prefs.playerID.toString());
          if(_prefs.usuarioLogged.isNotEmpty && _prefs.playerID.isNotEmpty){
            _loginProvider.registrarTokenOS();
          }
        }
    });
  }

  _evaluaPayload(OSNotification payload) {
    String titulo = payload.title!.toLowerCase();
    String mensaje = payload.body ?? 'Nueva notificación en áreas comunes';
    switch (titulo) {
      case 'encuesta':
        mensajeStream.addMessage({'encuesta': 'encuesta'});
        break;
      case 'aviso':
        String imgAviso = payload.additionalData?['img'] ?? "";
        mensajeStream.addMessage({
          'aviso': new AvisoModel(
              descripcion: mensaje, fecha: DateTime.now().toString(), imgAviso: imgAviso)
        });
        break;
      case 'visita':
        log('Aqui6');
        notifProvider
            .obtenerUltimaNotificacion(_prefs.usuarioLogged)
            .then((visita) {
          if (visita != null) {
            if (!idsVisitas.contains(visita.idVisitas)) {
              log("aqui4");
              idsVisitas.add(visita.idVisitas);
              mensajeStream.addMessage({'visita': visita});
            }
          }
        });
        OneSignal.shared.completeNotification(payload.notificationId, false);
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
    }
  }

  mostrarUltimaVisita() async {
    log("Aqui3");
    final visita = await notifProvider
        .obtenerUltimaNotificacion(_prefs.usuarioLogged)
        .timeout(Duration(milliseconds: 1300), onTimeout: () {
      return null;
    });
    if (visita != null) {
      if (!idsVisitas.contains(visita.idVisitas)) {
        idsVisitas.add(visita.idVisitas);
        if (visita.codigo != '' || visita.noMolestar == '1')
          visita.tipoVisita = 2;

        mensajeStream.addMessage({'visita': visita});
      }
    }
  }
}
