import 'dart:convert';

import 'package:dostop_v2/src/models/reporte_model.dart';
export 'package:dostop_v2/src/models/reporte_model.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class ReportesProvider {
    Future<Map<String, dynamic>> enviaReporteIncidente(
      {String idUsuario,
      String reporte,
      String idVisita,
      }) async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();
    final reporteData = {
      'colono': idUsuario,
      'reporte': reporte,
      'visita': idVisita,
    };
    try {
      final resp =
          await http.post('${constantes.urlApp}/reportar_visita.php', body: reporteData);
      List decodeResp = json.decode(resp.body);
      decodeResp[0].forEach((k, v) => mapResp[k] = v);
      // print(decodeResp);
      if (mapResp['estatus'].toString().contains('1')) {
        return {'OK': 1, 'message':'Reporte enviado'};
      } else {
        return {'OK': 2, 'message': mapResp['message']};
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de REPORTE INCIDENTE:\n $e');
      return {'OK': 2};
    }
  }

   Future<Map<String, dynamic>> obtenerReporte({
    String idUsuario,
    String idVisita,
  }) async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();
    final reporteData = {
      'id': idUsuario,
      'id_visita': idVisita,
    };
    try {
      final resp =
          await http.post('${constantes.urlApp}/obtener_reporte.php', body: reporteData);
      Map decodeResp = json.decode(resp.body);
      if (decodeResp['estatus'].toString().contains('1')) {
        return {'OK': 1, 'datos': ReporteModel.fromJson(decodeResp)};
      } else {
        return {'OK': 2, 'message': mapResp['message']};
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de REPORTE INCIDENTE - OBTENER REPORTE:\n $e');
      return {'OK': 3};
    }
  }
}