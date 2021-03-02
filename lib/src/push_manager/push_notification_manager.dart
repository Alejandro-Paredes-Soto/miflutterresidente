import 'dart:async';
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // bool notificacionForeground = false;
  List<String> idsVisitas = List();

  Future<void> initNotifications() async {
    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.getToken().then((token) {
      _prefs.token = token;
      // print('==== FCM TOKEN =====\n${_prefs.token}');
    });

    _firebaseMessaging.configure(
      onMessage: (info) async {
      // print('==== ON MESSAGE ====');
      // print(info);
      _evaluaMensaje(info);
    }, onLaunch: (info) async {
      // print('==== ON LAUNCH ====');
      // print(info);
      _evaluaMensaje(info);
    }, onResume: (info) async {
      // print('==== ON RESUME ====');
      // print(info);
      _evaluaMensaje(info);
    });
  }

  _evaluaMensaje(Map info) async {
    // detenerTimer();
    String titulo = '';
    String mensaje = '';
    if (Platform.isAndroid) {
      titulo = info['data']['title'].toString().toLowerCase();
      mensaje = info['data']['message'];
    } else {
      titulo = info['title'].toString().toLowerCase();
      mensaje = info['message'];
    }
    switch (titulo) {
      case 'encuesta':
        mensajeStream.addMessage({'encuesta': 'encuesta'});
        break;
      case 'aviso':
        mensajeStream.addMessage({
          'aviso': new AvisoModel(
              descripcion: mensaje, fecha: DateTime.now().toString())
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
            {'areas': mensaje ?? 'Nueva notificación en áreas comunes'});
        break;
      //IMPLEMENTACIÓN A FUTURO, EN RESPUESTA DE LUIS PARA APLICARLO Y DE FERNANDO PARA VALIDARLO
      //   case 'respuesta incidente':
      //     mensajeStream.addMessage({'incidente': 'El guardia respondió tu reporte: $mensaje'??'Nueva notificación'});
      //     break;
    }
    // iniciarTimer();
  }
  /*OPCIÓN DE ULTIMO RECURSO!!! USAR UN TIMER PARECE SER INEFICIENTE Y PUEDE TRAER CONSIGO PROBLEMAS DE MEMORIA (MEMORY LEAK)
   *SI LA PETICIÓN DE LUIS PERMANECE PARA REALIZAR LA ACTUALIZACIÓN DE VISITAS AUNQUE EL USUARIO NO DE CLICK A LA NOTIFICACIÓN
   *DESCOMENTAR TODOS LOS EVENTOS CON iniciaTimer() y detenerTimer(). SE PROBÓ Y FUNCIONA, PERO EN ALGUNOS ESCENARIOS EL TIMER
   *SIGUE CORRIENDO AUNQUE LO HAYAMOS DETENIDO. 
   *
   * USAR SOLAMENTE COMO ÚLTIMO RECURSO!!!!
   */
  // iniciarTimer() {
  //   _timerVisitas =
  //       Timer.periodic(Duration(seconds: 2), (_) => mostrarUltimaVisita());
  // }

  // detenerTimer() {
  //   if (_timerVisitas.isActive) _timerVisitas.cancel();
  // }

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

