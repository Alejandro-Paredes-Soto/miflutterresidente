import 'dart:convert';
import 'dart:developer';

import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class ContactSupport {

  Future<dynamic> getContact() async {
    try {
      final resp =
          await http.get(Uri.parse('http://192.168.100.2/integracionpd/public/api/v1/dostop/contact/info/'));
      Map<String, dynamic> mapResp = json.decode(resp.body);
      log(mapResp.toString());
      return mapResp;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de CONTACTO-SOPORTE:\n $e');
      return {'OK': 2, 'message': 'No se pudo obtener'};
    }
  }

  
}