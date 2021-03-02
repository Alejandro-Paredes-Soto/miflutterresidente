import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/*
  Recordar instalar el paquete de:
    shared_preferences:
  Inicializar en el main
    final prefs = new PreferenciasUsuario();
    await prefs.initPrefs();
    
    Recordar que el main() debe de ser async {...
*/

class PreferenciasUsuario {
  static final PreferenciasUsuario _instancia =
      new PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  SharedPreferences _prefs;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  // GET y SET del token
  get token {
    return _prefs.getString('token') ?? '';
  }

  set token(String value) {
    _prefs.setString('token', value);
  }

  // GET y SET del player ID
  get playerID {
    return _prefs.getString('playerID') ?? '';
  }

  set playerID(String value) {
    _prefs.setString('playerID', value);
  }

  // GET y SET del idUsuario
  get usuarioLogged {
    return _prefs.getString('usuario') ?? '';
  }

  set usuarioLogged(String value) {
    _prefs.setString('usuario', value);
  }

  borraPrefs() async {
    await _prefs.remove('usuario');
  }
}
