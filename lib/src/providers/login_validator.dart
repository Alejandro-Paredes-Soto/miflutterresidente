import 'dart:async';
import 'dart:convert';

import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
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
    final authData = {
      'id': _prefs.usuarioLogged,
      'token': _prefs.token,
      'playerID':_prefs.playerID,
      'fecha':
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString()
    };
    try {
      final resp = await http.post(Uri.parse('${constantes.urlApp}/validar_sesion2.php'), body: authData);
      mapResp = json.decode(resp.body);
      //decodeResp[0].forEach((String k, dynamic v) => mapResp[k] = v);
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
      //print(e);
      sesion.drain();
      addIntStatusSesion(1);
    }
    //print(mapResp);
  }
}
