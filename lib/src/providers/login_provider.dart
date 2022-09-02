import 'dart:convert';
import 'dart:io';

import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/utils.dart';
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
      final resp = await http.post(Uri.parse('${constantes.urlApp}/login.php'), body: authData);
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

  Future<Map<String, dynamic>> registrarTokenOS(
      {String? idUsuario, String? playerID}) async {
    if (_prefs.playerID == '')
      return {
        'statusCode': 0,
        'message':
            'No se ha podido obtener el token desde One Signal, revisar que los servicios esten funcionando '
                'y que los servicios internos de la aplicación se pueden conectar a One Signal'
      };
    try {
      final deviceData = await getDeviceData();
      final infoApp = await PackageInfo.fromPlatform();
      final authData = {
        'id': _prefs.usuarioLogged,
        'token': _prefs.token,
        'playerID': _prefs.playerID,
        'deviceID': Platform.isIOS ? '1' : '2',
        'dateAccess':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString(),
        'versionApp': infoApp.version,
        'SODevice': deviceData['os'],
        'brand': deviceData['brand'],
        'model': deviceData['nameModel'],
      };
      // final resp =
          // await http.post(Uri.parse('${constantes.urlApp}/registrar_token_disp_os.php'), body: authData);
      final resp =
          await http.post(Uri.parse('http://192.168.100.14/WebServiceApp/register_playerID.php'), body: authData);
      Map<String, dynamic> decodeResp = json.decode(resp.body);

      if(resp.statusCode == 200){
        _prefs.token = '';
        _prefs.registeredPlayerID = true;
      }

      return decodeResp;
    } catch (e) {
      return {
        'statusCode': 0,
        'message':
            'Ha ocurrido un error, favor verificar conexión a internet. Es posible que no se reciban notificaciones'
      };
    }

  }

  Future<bool> logout() async {
    try {
      final resp = await http.post(Uri.parse('${constantes.urlApp}/elimina_token_os.php'),
          body: {'playerID': _prefs.playerID});
      Map? decodeResp = json.decode(resp.body);
      print(decodeResp);
      if (decodeResp == null) return false;
      if (decodeResp.containsKey('estatus')) {
        if (decodeResp['estatus'] !='3') {
          _prefs.token = '';
          _prefs.registeredPlayerID = false;
          return true;
        }
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
