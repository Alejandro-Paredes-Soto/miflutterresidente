import 'dart:convert';
import 'login_validator.dart';
import 'package:http/http.dart' as http;

class CodigosResidenteProvider {
  final validaSesion = LoginValidator();
  final urlAPI = 'https://dostop.mx/dostop/api/v1';

  Future<Map<String, dynamic>> newCodigoResidente(String idUsuario) async {
    try {
      final resp = await http.post('$urlAPI/visita/extraordinaria/',
          body: json.encode({'idColonos': idUsuario}), headers: {'Content-Type': 'application/json'});

      if (resp.statusCode == 201) {
        Map<String, dynamic> decodeResp = json.decode(resp.body);
        return decodeResp;
      }

      return {'statusCode': resp.statusCode, 'status': resp.reasonPhrase};
    } catch (e) {
      var message = e.runtimeType == 'SocketException'
          ? 'Ha ocurrido un error, favor verificar conexión a internet.'
          : e.message;
      return {'statusCode': 0, 'status': e.runtimeType, 'codigo': message};
    }
  }
}
