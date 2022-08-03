import 'dart:convert';
import 'login_validator.dart';
import 'package:http/http.dart' as http;
import 'constantes_provider.dart' as constantes;

class CodigosResidenteProvider {
  final validaSesion = LoginValidator();

  Future<Map<String, dynamic>> newCodigoResidente(String idUsuario) async {
    try {
      final resp = await http.post(Uri.parse('${constantes.ulrApiProd}/visita/extraordinaria/'),
          body: json.encode({'idColonos': idUsuario}), headers: {'Content-Type': 'application/json'});

      if (resp.statusCode == 201) {
        Map<String, dynamic> decodeResp = json.decode(resp.body);
        return decodeResp;
      }

      return {'statusCode': resp.statusCode, 'status': resp.reasonPhrase};
    } catch (e) {
      var message = e.runtimeType.toString() == 'SocketException'
          ? 'Ha ocurrido un error, favor verificar conexión a internet.'
          : 'Ha ocurrido un error ${e.toString()}';
      return {'statusCode': 0, 'status': e.runtimeType, 'codigo': message};
    }
  }
}