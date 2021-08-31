import 'dart:convert';

import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LoginProvider {
  final _prefs = new PreferenciasUsuario();

  Future<Map<String, dynamic>> login(String email, String password) async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();
    final authData = {
      'usuario': email,
      'contrasena': password,
    };
    try {
      final resp = await http.post('${constantes.urlApp}/login.php', body: authData);
      List decodeResp = json.decode(resp.body);
      decodeResp[0].forEach((String k, dynamic v) => mapResp[k] = v);
    } catch (e) {
      print('Ocurrió un error en la llamada al Servicio de LOGIN:\n $e');
      return {
        'OK': 3,
        'message':
            'Ha ocurrido un error.\n\nPor favor verifica tu conexión a internet.'
      };
    }

    // print(mapResp);
    if (mapResp.containsKey('idUsuario')) {
      _prefs.usuarioLogged = mapResp['idUsuario'];
      return {'OK': 1, 'usuarioLogged': mapResp['idUsuario']};
    } else {
      return {'OK': 2, 'message': mapResp['estatus']};
    }
  }


  Future<Map<String, dynamic>> registrarTokenFCM(String dispositivo,
      {String idUsuario, String token}) async {
    if (_prefs.token == '')
      return {
        'OK': 0,
        'message':
            'No se ha podido obtener el token desde FCM, revisar que los servicios de Google esten funcionando '
                'y que los servicios internos de la aplicación se pueden conectar a FCM'
      };
    Map<String, dynamic> mapResp = Map<String, dynamic>();
    final authData = {
      'id': idUsuario ?? _prefs.usuarioLogged,
      'token': token ?? _prefs.token,
      'dispositivo': dispositivo,
      'fecha':
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString()
    };
    try {
      final resp =
          await http.post('${constantes.urlApp}/registrar_token_disp.php', body: authData);
      List decodeResp = json.decode(resp.body);
      decodeResp[0].forEach((String k, dynamic v) => mapResp[k] = v);
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de LOGIN - REGISTRA TOKEN:\n $e');
      return {
        'OK': 3,
        'message':
            'Ha ocurrido un error, favor verificar conexión a internet. Es posible que no se reciban notificaciones'
      };
    }
    // print(mapResp);
    if (mapResp['estatus'] == '1') {
      return {'OK': 1, 'message': mapResp['estatus']};
    } else if (mapResp['estatus'] == '2') {
      return {'OK': 2, 'message': mapResp['message']};
    }
    return {'OK': 3, 'message': 'El servicio no respondió con algun mensaje'};
  }

  Future<bool> logout() async {
    try {
      final resp = await http.post('${constantes.urlApp}/elimina_token.php',
          body: {'token': _prefs.token});
      Map decodeResp = json.decode(resp.body);
      //print(decodeResp);
      if (decodeResp == null) return false;
      if (decodeResp.containsKey('estatus')) {
        if (decodeResp['estatus'] !='3')
          return true;
        else
          return false;
      }
      return false;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de LOGIN - LOGOUT:\n $e');
      return false;
    }
  }
}
