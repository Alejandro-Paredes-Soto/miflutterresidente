import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/utils.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LoginValidator {
  static final LoginValidator _instancia = new LoginValidator._internal();

  factory LoginValidator() => _instancia;

  LoginValidator._internal();

  final _prefs = new PreferenciasUsuario();

  final _sesionStreamController = StreamController<int>.broadcast();
  Stream<int> get sesion => _sesionStreamController.stream;

  void addIntStatusSesion(int sesionValida) {
    _sesionStreamController.sink.add(sesionValida);
    return;
  }

  dispose() {
    _sesionStreamController.close();
  }

 Future<Null> verificaSesion() async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();
    try {
      final deviceData = await getDeviceData();
      final infoApp = await PackageInfo.fromPlatform();
      final authData = {
        'id': _prefs.usuarioLogged,
        'token': _prefs.token,
        'playerID':_prefs.playerID,
        'fecha':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString(),
        'versionApp': infoApp.version,
        'SODevice': deviceData['os'],
        'brand': deviceData['brand'],
        'model': deviceData['nameModel'],
      };
      
      final endpoint = _prefs.playerID.isNotEmpty ? 'validar_sesion_os.php' : 'validar_sesion2.php';
      final resp = await http.post(Uri.parse('${constantes.urlApp}/$endpoint'), body: authData);
      mapResp = json.decode(resp.body);
      if (resp.statusCode != 404 || resp.statusCode != 500) {
        if (mapResp.containsKey('estatus')) {
          sesion.drain();
          switch (mapResp['estatus']) {
            case '0':
              addIntStatusSesion(0);
              break;
            case '1':
              addIntStatusSesion(1);
              break;
            case '2':
              addIntStatusSesion(2);
              break;
          }
        } else {
          sesion.drain();
          addIntStatusSesion(0);
        }
      } else {
        sesion.drain();
        addIntStatusSesion(0);
      }
    } catch (e) {
      sesion.drain();
      addIntStatusSesion(1);
    }
  }

  Future<dynamic> checkVersion() async {
    try {
      final infoApp = await PackageInfo.fromPlatform();
      final resp = await http.get(Uri.parse('${constantes.urlApp}/versionApp.php?versionApp=${infoApp.version}'));
      Map decodeResp = json.decode(resp.body);
      if (decodeResp.containsKey('data')) {
        final importance = decodeResp['data']['importance'];
        return importance;
      }
    } catch (e) {
      log('Ocurrió un error en la llamada chekVersion :\n $e');
      return null;
    }
  }
}