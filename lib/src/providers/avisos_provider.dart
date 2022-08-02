import 'dart:convert';

import 'package:dostop_v2/src/models/aviso_model.dart';
import 'package:dostop_v2/src/models/encuesta_model.dart';
import 'package:dostop_v2/src/models/resultados_encuesta_model.dart';
export 'package:dostop_v2/src/models/aviso_model.dart';
export 'package:dostop_v2/src/models/encuesta_model.dart';
export 'package:dostop_v2/src/models/resultados_encuesta_model.dart';
import 'login_validator.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class AvisosProvider {
  
  final validaSesion = LoginValidator();

  Future<List<AvisoModel>> cargaAvisos(String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http
          .post(Uri.parse('${constantes.urlApp}/obtener_notificaciones.php'), body: {'id': idUsuario});
      List? decodeResp = json.decode(resp.body);
      final List<AvisoModel> avisos = [];
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
  }

  Future<List<AvisoModel>> obtenerUltimosAvisos(String idUsuario) async {
    try {
      final resp = await http
          .post(Uri.parse('${constantes.urlApp}/obtener_ultimos_avisos.php'), body: {'id': idUsuario});
      List? decodeResp = json.decode(resp.body);
      final List<AvisoModel> avisos = [];
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
      final resp = await http.post(Uri.parse('${constantes.urlApp}/obtener_ultima_encuesta_disp.php'),
          body: {'id': idUsuario});
      Map? encuesta = json.decode(resp.body);
      if (encuesta == null) return {};
      if (encuesta.containsKey('datos_encuesta')) {
        return {
          1: encuestaModelFromJson(json.encode(encuesta['datos_encuesta']))
        };
      }
      return {2: 'No hay ninguna encuesta disponible'};
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de AVISOS - OBTENER ÚLTIMA ENCUESTA:\n $e');
      return {3: 'No se pudo obtener la última encuesta'};
    }
  }

  Future<Map<int, dynamic>> enviarRespuestaEncuesta(
      String idUsuario, int? idRespuesta) async {
    try {
      final resp = await http
          .post(Uri.parse('${constantes.urlApp}/enviar_respuesta_encuesta_resultados.php'), body: {
        'id': idUsuario,
        'id_respuesta': idRespuesta.toString(),
      });
      Map? decodeResp = json.decode(resp.body);
      print(decodeResp);
      if (decodeResp == null) return {};
      if (decodeResp.containsKey('resultados')) {
        return {
          1: resultadosEncuestaModelFromJson(
              json.encode(decodeResp['resultados']))
        };
      }
      return {
        2: decodeResp.containsKey('message')
            ? decodeResp['message']
            : 'No se pueden obtener los resultados'
      };
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de AVISOS - ENVIAR RESPUESTAS:\n $e');
      return {3: 'No se pudo obtener la última encuesta'};
    }
  }

  Future<Map<int, dynamic>> obtenerNumeroCaseta(String idUsuario) async {
    try {
      final resp = await http
          .post(Uri.parse('${constantes.urlApp}/obtener_numero_caseta.php'), body: {'id': idUsuario});
      Map? decodeResp = json.decode(resp.body);
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
