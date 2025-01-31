import 'dart:convert';

import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class RestablecerUsuarioProvider {

  Future<Map<String, dynamic>> restablecerXEmail(String email) async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();

    try {
      final resp = await http.post(Uri.parse('${constantes.urlApp}/recuperarpass.php'), body: {'usuario': email});
      List decodeResp = json.decode(resp.body);
      decodeResp[0].forEach((String k, dynamic v) => mapResp[k] = v);
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de RECUPERAR USER PASS:\n $e');
    }
    print(mapResp);
    if (mapResp['estatus']=='1') {
      return {'OK': true};
    } else {
      return {'OK': false};
    }
  }
}