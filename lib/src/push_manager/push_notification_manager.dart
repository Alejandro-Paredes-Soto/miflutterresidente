import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dostop_v2/src/models/aviso_model.dart';
import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/push_manager/mensajes_stream.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../providers/login_provider.dart';

class PushNotificationsManager {
  final _prefs = PreferenciasUsuario();
  final _loginProvider = LoginProvider();

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
      if (token != null) {
        _prefs.token = token;
      }
    });

    FirebaseMessaging.onMessage.listen((event) async {
      log('message');
      if (event.notification != null) _evaluaMensaje(event);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      log("message ${event.notification}");
      if (event.notification != null) _evaluaMensaje(event);
    });
  }

  Future<void> initNotificationsOS() async {
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
        if (_prefs.usuarioLogged.isNotEmpty && _prefs.playerID.isNotEmpty) {
          _loginProvider.registrarTokenOS();
        }
      }
    });
  }

  _evaluaMensaje(RemoteMessage info) async {
    String title = '';
    String message = '';
    String img = '';

    title = info.notification!.title.toString().toLowerCase();
    message = info.notification!.body ?? '';
    img = title == 'aviso' ? json.decode(info.data['data'])['img'] : '';
    _messageStream(title, message, img);
  }

  _evaluaPayload(OSNotification payload) {
    String title = payload.title!.toLowerCase();
    String message = payload.body ?? 'Nueva notificación en áreas comunes';
    String img = payload.additionalData?['img'] ?? "";
    _messageStream(title, message, img);
    if (title == 'visita' ||
        title == 'visita frecuente' ||
        title == 'visita rechazada')
      OneSignal.shared.completeNotification(payload.notificationId, false);
  }

  _messageStream(String title, String message, String? img) {
    switch (title) {
      case 'encuesta':
        mensajeStream.addMessage({'encuesta': 'encuesta'});
        break;
      case 'aviso':
        mensajeStream.addMessage({
          'aviso': new AvisoModel(
              descripcion: message,
              fecha: DateTime.now().toString(),
              imgAviso: img!)
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
        mensajeStream.addMessage({'areas': message});
        break;
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
        if (visita.codigo != '' || visita.noMolestar == '1')
          visita.tipoVisita = 2;

        mensajeStream.addMessage({'visita': visita});
      }
    }
  }
}
