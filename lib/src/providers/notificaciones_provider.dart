import 'dart:convert';
import 'dart:developer';

import 'package:dostop_v2/src/utils/preferencias_usuario.dart';

import 'visitas_provider.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class NotificacionesProvider {
  final _prefs = PreferenciasUsuario();

  Future<dynamic> obtenerUltimaNotificacion(String idUsuario) async {
    try {
      final resp = await http.post(
          Uri.parse('${constantes.urlApp}/revisa_notificacion_visita.php'),
          body: {'id': idUsuario});
      Map? decodeResp = json.decode(resp.body);
      if (decodeResp == null) return null;
      if (decodeResp.containsKey('visita')) {
        final visita = VisitaModel.fromJson(decodeResp['visita']);
        switch (decodeResp['idNotificacion']) {
          case '1':
            visita.tipoVisita = 1;
            return visita;
          case '3':
            visita.tipoVisita = 3;
            return visita;
        }
      }
      return null;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de NOTIFICACIONES - OBTENER ÚLTIMA NOTIFICACIÓN:\n $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> respuestaVisita(
      String idUsuario, String idVisita, int respuesta) async {
    try {
      final resp = await http.post(
          Uri.parse('${constantes.urlApp}/actualizar_visita_notificacion.php'),
          body: {
            'id': idUsuario,
            'id_visita': idVisita,
            'respuesta_visita': respuesta.toString()
          });
      Map? decodeResp = json.decode(resp.body);
      if (decodeResp == null)
        return {'OK': 2, 'mensaje': 'No se pudo enviar la respuesta'};
      if (decodeResp.containsKey('estatus')) {
        switch (decodeResp['estatus']) {
          case '1':
            return {
              'OK': 1,
              'id': decodeResp['id_respuesta'],
              'mensaje': decodeResp['message']
            };
          default:
            return {'OK': 2, 'mensaje': 'No se pudo enviar la respuesta'};
        }
      }
      return {'OK': 2, 'mensaje': 'No se pudo enviar la respuesta'};
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de NOTIFICACIONES - ENVIAR RESPUESTA VISITA:\n $e');
      return {'OK': 2, 'mensaje': 'No se pudo enviar la respuesta'};
    }
  }

  Future<bool> actualizarEstadoNotif(String idUsuario) async {
    try {
      final resp = await http.post(
          Uri.parse('${constantes.urlApp}/actualizar_notificacion2.php'),
          body: {
            'id': idUsuario,
          });
      Map? decodeResp = json.decode(resp.body);
      if (decodeResp == null) return false;
      if (decodeResp.containsKey('estatus')) {
        switch (decodeResp['estatus']) {
          case '1':
            return true;
          case '2':
            return false;
        }
      }
      return false;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de NOTIFICACIONES:\n $e');
      return false;
    }
  }

  Future<Map> notificationChannel() async {
    try {
       final resp = await http.post(
        Uri.parse('${constantes.ulrApiProd}/device/chanel/'),
           body: {
             'playerID': _prefs.playerID,
           });
       Map? decodeResp = json.decode(resp.body);
       if (decodeResp != null && decodeResp.containsKey('canal'))
         return decodeResp;
         log(decodeResp.toString());

    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de NOTIFICACIONES:\n $e');
    }

    return {'statusCode': 0, 'message': '¡Ups! algo salió mal'};
  }
}
