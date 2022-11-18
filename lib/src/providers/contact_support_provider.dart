import 'dart:convert';
import 'dart:developer';

import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class ContactSupport {

  Future<dynamic> getContactNumber() async {
    try {
      final resp =
          await http.get(Uri.parse('${constantes.ulrApiProd}/dostop/contact/info/'));
      Map<String, dynamic> mapResp = json.decode(resp.body);
      if (mapResp.containsKey('contactNumber')) {
        final number = mapResp['contactNumber'];
        return number;
      }
      return;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de CONTACTO-SOPORTE:\n $e');
      return {'OK': 2, 'message': 'No se pudo obtener'};
    }
  }
}