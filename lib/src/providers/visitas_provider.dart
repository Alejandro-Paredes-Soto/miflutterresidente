import 'dart:async';
import 'dart:convert';

import 'package:dostop_v2/src/models/visita_model.dart';
import 'login_validator.dart';
export 'package:dostop_v2/src/models/visita_model.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class VisitasProvider {
  final validaSesion = LoginValidator();

  Future<List<VisitaModel>> buscarVisitasXFecha(
      String idUsuario, String fechaInicio, String fechaFin, int pagina,
      {bool vaciarLista = false}) async {
    validaSesion.verificaSesion();
    try {
      final resp =
          await http.post(Uri.parse('${constantes.urlApp}/buscador_visitas2.php'), body: {
        'id': idUsuario,
        'fecha_ini': fechaInicio,
        'fecha_fin': fechaFin,
        'page_no': pagina.toString()
      });
      final Map<String, dynamic>? decodeResp = json.decode(resp.body);
      final List<VisitaModel> visitas = [];
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
      final resp = await http.post(Uri.parse('${constantes.urlApp}/ultimas_visitas3.php'),
          body: {'id': idUsuario});
      List? decodeResp = json.decode(resp.body);
      final List<VisitaModel> visitas = [];
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

  Future<Map<String, dynamic>> serviceCall(String idVisit, {int status = 1}) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final resp = await http.post(Uri.parse('${constantes.urlApp}/serviceCall.php'),
          headers: headers, body: json.encode({'idVisit': idVisit, 'status': status}));
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      return decodeResp;

    } catch (e) {
      print('Ocurrió un error en la llamada al servicio:\n $e');
      return {
        'status': 'ERROR',
        'statusCode': 0,
        'message': 'Ocurrió un error al intentar realizar la llamada.'
      };
    }
  }
}
