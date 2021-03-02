import 'dart:convert';

import 'package:dostop_v2/src/models/aviso_model.dart';
import 'package:dostop_v2/src/providers/login_validator.dart';
export 'package:dostop_v2/src/models/aviso_model.dart';
import 'package:http/http.dart' as http;

class AvisosProvider {
  final String url = 'https://dostop.mx/dostop/WebService';
  final validaSesion = LoginValidator();

  Future<List<AvisoModel>> cargaAvisos(String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http
          .post('$url/obtener_notificaciones.php', body: {'id': idUsuario});
      List decodeResp = json.decode(resp.body);
      final List<AvisoModel> avisos = new List();
      if (decodeResp == null) return [];
      decodeResp.forEach((aviso) {
        //  print('$aviso');
        final tempAviso = AvisoModel.fromJson(aviso);
        avisos.add(tempAviso);
      });
      return avisos;
    } catch (e) {
      print('Ocurrió un error en la llamada al Servicio de AVISOS:\n $e');
      return [];
    }
    //return[];
  }

  Future<List<AvisoModel>> obtenerUltimosAvisos(String idUsuario) async {
    try {
      final resp = await http
          .post('$url/obtener_ultimos_avisos.php', body: {'id': idUsuario});
      List decodeResp = json.decode(resp.body);
      final List<AvisoModel> avisos = new List();
      if (decodeResp == null) return [];
      decodeResp.forEach((aviso) {
        //  print('$aviso');
        final tempAviso = AvisoModel.fromJson(aviso);
        avisos.add(tempAviso);
      });
      return avisos;
    } catch (e) {
      print('Ocurrió un error en la llamada al Servicio de AVISOS:\n $e');
      return [];
    }
    //return[];
  }

  Future<Map<int, dynamic>> obtenerUltimaEncuesta(String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http
          .post('$url/obtener_ultima_encuesta2.php', body: {'id': idUsuario});
      Map decodeResp = json.decode(resp.body);
      // print(decodeResp);
      if (decodeResp == null) return {};
      if (decodeResp.containsKey('pregunta')) {
        return {1: decodeResp};
      }
      return {2: 'No hay ninguna encuesta disponible'};
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de AVISOS - OBTENER ÚLTIMA ENCUESTA:\n $e');
      return {3: 'No se pudo obtener la última encuesta'};
    }
  }

  Future<Map<int, dynamic>> enviarRespuestaEncuesta(
      String idUsuario, String idPregunta, bool respuesta) async {
    try {
      final resp =
          await http.post('$url/enviar_respuesta_encuesta2.php', body: {
        'idColono': idUsuario,
        'idPregunta': idPregunta,
        'respuesta': respuesta.toString()
      });
      Map decodeResp = json.decode(resp.body);
      print(decodeResp);
      if (decodeResp == null) return {};
      if (decodeResp.containsKey('resultados')) {
        return {1: decodeResp['resultados']};
      }
      return {2: 'No se pueden obtener los resultados'};
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de AVISOS - ENVIAR RESPUESTAS:\n $e');
      return {3: 'No se pudo obtener la última encuesta'};
    }
  }

  Future<Map<int, dynamic>> obtenerNumeroCaseta(String idUsuario) async {
    try {
      final resp = await http
          .post('$url/obtener_numero_caseta.php', body: {'id': idUsuario});
      Map decodeResp = json.decode(resp.body);
      // print(decodeResp);
      if (decodeResp == null) return {};
      if (decodeResp.containsKey('numero')) {
        return {1: decodeResp['numero']};
      }
      return {2: 'No hay ningún número disponible'};
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de AVISOS - OBTENER NUMERO CASETA:\n $e');
      return {3: 'No se pudo obtener el número'};
    }
  }
}
