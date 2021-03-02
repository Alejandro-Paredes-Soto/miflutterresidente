import 'dart:async';
import 'dart:convert';

import 'package:dostop_v2/src/models/visita_model.dart';
import 'package:dostop_v2/src/providers/login_validator.dart';
export 'package:dostop_v2/src/models/visita_model.dart';
import 'package:http/http.dart' as http;

class VisitasProvider {
  
  final String url = 'https://dostop.mx/dostop';
  final validaSesion  = LoginValidator();

  Future<List<VisitaModel>> buscarVisitasXFecha(
      String idUsuario, String fechaInicio, String fechaFin, int pagina,
      {bool vaciarLista = false} ) async {
      validaSesion.verificaSesion();
    try {
      final resp =
          await http.post('$url/WebService/buscador_visitas2.php', body: {
        'id': idUsuario,
        'fecha_ini': fechaInicio,
        'fecha_fin': fechaFin,
        'page_no': pagina.toString()
      });
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      final List<VisitaModel> visitas = new List();
      if (decodeResp == null) return [];
      if (!decodeResp.containsKey('message')) {
        for (Map<String, dynamic> visita in decodeResp['busqueda']) {
          // print('$visita');
          final tempVisita = VisitaModel.fromJson(visita);
          visitas.add(tempVisita);
        }
        // visitasFull.addAll(visitas);
        // visitasSink(visitasFull);
        return visitas;
      } else {
        print(
            "Mensaje desde Servicio de VISITAS - BUSCADOR: ${decodeResp['message']}");
        return visitas;
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITAS - BUSCADOR:\n $e');
      return [];
    }
  }

  Future<List<VisitaModel>> obtenerUltimasVisitas(String idUsuario) async {
    try {
      final resp = await http.post('$url/WebService/ultimas_visitas3.php',
          body: {'id': idUsuario});
      List decodeResp = json.decode(resp.body);
      final List<VisitaModel> visitas = new List();
      if (decodeResp == null) return [];
      decodeResp.forEach((visita) {
        final tempVisita = VisitaModel.fromJson(visita);
        visitas.add(tempVisita);
      });
      return visitas;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITAS - ULTIMAS VISITAS:\n $e');
      return [];
    }
  }
}
