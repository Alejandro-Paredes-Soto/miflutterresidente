import 'dart:convert';

export 'package:dostop_v2/src/models/area_comun_model.dart';

export 'package:dostop_v2/src/models/area_reservada_model.dart';

import 'package:http/http.dart' as http;

class ConfigUsuarioProvider {
  final String url = 'https://dostop.mx/dostop/WebService';

  Future<Map<String, dynamic>> configurarOpc(
    String idUsuario,
    int tipoConfig,
    bool valor,
  ) async {
    try {
      final resp = await http.post('$url/modificar_configuraciones_usuario.php', body: {
        'id': idUsuario,
        'tipoConfig': tipoConfig.toString(),
        'valorConfig': valor ? '1' : '0'
      });
      Map<String, dynamic> mapResp = json.decode(resp.body);
      if(!mapResp.containsKey('estatus')) return {'OK': 2, 'message':'No se pudo activar'};
      if (mapResp['estatus'].toString().contains('1')) {
        return {'OK': 1, 'message': valor?'Activado':'Desactivado'};
      } else {
        return {'OK': 2, 'message': mapResp['message']};
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de CONFIGURACINES USUARIO - NO MOLESTAR:\n $e');
      return {'OK': 2, 'message':'No se pudo activar'};
    }
  }

   Future<Map<String, dynamic>> obtenerEstadoConfig(
    String idUsuario,
    int tipoConfig,
  ) async {
    try {
      final resp = await http.post('$url/obtener_configuraciones_usuario.php', body: {
        'id': idUsuario,
        'tipoConfig': tipoConfig.toString(),
      });
      Map<String, dynamic> mapResp = json.decode(resp.body);
      if(!mapResp.containsKey('estatus')) return {'OK': 2};
      if (mapResp['estatus'].toString().contains('1')) {
        return {'valor':mapResp['valorConfig']};
      } else {
        return {'OK': 2};
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de CONFIGURACINES USUARIO - NO MOLESTAR:\n $e');
      return {'OK': 2};
    }
  }
}
