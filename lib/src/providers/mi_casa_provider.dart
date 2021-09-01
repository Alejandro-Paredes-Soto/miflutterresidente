import 'dart:convert';

import 'package:dostop_v2/src/models/pagos_usuario_model.dart';
export 'package:dostop_v2/src/models/pagos_usuario_model.dart';
import 'login_validator.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class MiCasaProvider {
  final validaSesion = LoginValidator();

  Future<Map<int, dynamic>> obtenerDatosPago(String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http
          .post('${constantes.urlApp}/obtener_datos_pago.php', body: {'id': idUsuario});
      Map decodeResp = json.decode(resp.body);
      if (decodeResp.containsKey('saldo')) {
        return {1: PagosUsuarioModel.fromJson(decodeResp)};
      } else if (decodeResp.containsKey('estatus')) {
        return {2: 'No hay información'};
      }
      return {2: 'No hay información'};
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de MI CASA - DATOS PAGO:\n $e');
      return {2: 'No hay información'};
    }
  }
}
