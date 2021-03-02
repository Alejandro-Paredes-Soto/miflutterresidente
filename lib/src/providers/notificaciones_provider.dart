import 'dart:convert';

import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:http/http.dart' as http;

class NotificacionesProvider {
  final String url = 'https://dostop.mx/dostop/WebService';

  Future<VisitaModel> obtenerUltimaNotificacion(String idUsuario) async {
    try {
      final resp = await http
          .post('$url/revisa_notificacion_visita.php', body: {'id': idUsuario});
      Map decodeResp = json.decode(resp.body);
      // print(decodeResp);
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

  Future<bool> respuestaVisita(
      String idUsuario, String idVisita, int respuesta) async {
    try {
      final resp = await http.post('$url/actualizar_visita2.php', body: {
        'id': idUsuario,
        'idVisita': idVisita,
        'respuesta_visita': respuesta.toString()
      });
      Map decodeResp = json.decode(resp.body);
      // print(decodeResp);
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
          'Ocurrió un error en la llamada al Servicio de NOTIFICACIONES - ENVIAR RESPUESTA VISITA:\n $e');
      return false;
    }
  }

  Future<bool> actualizarEstadoNotif(
      String idUsuario) async {
    try {
      final resp = await http.post('$url/actualizar_notificacion2.php', body: {
        'id': idUsuario,
      });
      Map decodeResp = json.decode(resp.body);
      // print(decodeResp);
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
}
