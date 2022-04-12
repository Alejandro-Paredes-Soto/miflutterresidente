import 'dart:convert';
import 'login_validator.dart';
import 'package:http/http.dart' as http;

class CodigosResidenteProvider {
  final validaSesion = LoginValidator();
  final urlAPI = 'https://dostop.mx/dostop/api/v1';

  Future<String> newCodigoResidente(String idUsuario) async {
    try{
      final resp = await http.post('$urlAPI/visita/extraordinaria/',
      body: json.encode({'idColonos' : idUsuario}));

      if(resp.statusCode == 201){
        Map<String, dynamic> decodeResp = json.decode(resp.body);
        return decodeResp['codigo'];
      }
      return '';
    }catch(e){
      return '';
    }
  }
}