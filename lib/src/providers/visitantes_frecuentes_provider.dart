import 'dart:convert';

import 'package:dostop_v2/src/models/visitante_freq_model.dart';
import 'package:dostop_v2/src/providers/login_validator.dart';
import 'package:http/http.dart' as http;

class VisitantesFreqProvider {
  
  final String url = 'https://dostop.mx/dostop/WebService';
  final validaSesion = LoginValidator();

  Future<List<VisitanteFreqModel>> cargaVisitantesFrecuentes(
      String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http
          .post('$url/obtener_visitantes_frecuentes.php', body: {'id': idUsuario});
      List decodeResp = json.decode(resp.body);
      final List<VisitanteFreqModel> visitantes = new List();
      if (decodeResp == null) return [];
      decodeResp.forEach((visitante) {
        // print('$visitante');
        final tempAviso = VisitanteFreqModel.fromJson(visitante);
        visitantes.add(tempAviso);
      });

      return visitantes;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - CARGAR VISITANTES:\n $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> eliminaVisitanteFrecuente(
      String idFrecuente) async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();
    try {
      final resp = await http.post('$url/eliminar_visitante_frecuente.php',
          body: {'id_frecuente': idFrecuente});
      List decodeResp = json.decode(resp.body);
      decodeResp[0].forEach((k, v) {
        mapResp[k] = v;
      });
      // print(decodeResp);
      if (mapResp['estatus'].toString().contains('1')) {
        return {'OK': 1};
      } else {
        return {'OK': 2, 'message': mapResp['estatus']};
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - ELIMINAR VISITANTE:\n $e');
      return {'OK': 2};
    }
  }

  Future<Map<String, dynamic>> nuevoVisitanteFrecuente(
      {String idUsuario,
      String nombre,
      String apPaterno,
      String apMaterno,
      String vigencia, bool esUnico}) async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();
    final visitanteData = {
      'colono': idUsuario,
      'nombre': nombre,
      'ape_paterno': apPaterno,
      'ape_materno': apMaterno,
      'tipo': esUnico?'unico':'',
      'vigencia': vigencia,
    };
    try {
      final resp =
          await http.post('$url/registrar_frecuente2.php', body: visitanteData);
      List decodeResp = json.decode(resp.body);
      decodeResp[0].forEach((k, v) => mapResp[k] = v);
      // print(decodeResp);
      if (mapResp['estatus'].toString().contains('1')) {
        return {'OK': 1, 'message':'Visitante frecuente creado', 'codigo':mapResp['codigo']};
      } else {
        return {'OK': 2, 'message': mapResp['message']};
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - NUEVO VISITANTE:\n $e');
      return {'OK': 2};
    }
  }
}
