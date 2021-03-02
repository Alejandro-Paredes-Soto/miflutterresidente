import 'dart:convert';

import 'package:http/http.dart' as http;

class EmergenciaProvider {
  final String url =
      'https://dostop.mx/dostop/WebService/emergencias.php';

  Future<Map<String, dynamic>> pedirApoyoCaseta(String idUsuario) async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();

    try {
      final resp = await http.post('$url', body: {'id': idUsuario});
      List decodeResp = json.decode(resp.body);
      decodeResp[0].forEach((String k, dynamic v) => mapResp[k] = v);
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de EMERGENCIA:\n $e');
    }
    print(mapResp);
    if (mapResp['estatus']=='1') {
      return {'OK': true};
    } else {
      return {'OK': false};
    }
  }

}