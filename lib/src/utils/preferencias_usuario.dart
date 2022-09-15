import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static final PreferenciasUsuario _instancia =
      new PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  late SharedPreferences _prefs;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  bool get qrResidente {
    return _prefs.getBool('qrResidente') ?? false;
  }

  set qrResidente(bool value) {
    _prefs.setBool('qrResidente', value);
  }

  // GET y SET del token
  String get token {
    return _prefs.getString('token') ?? '';
  }

  set token(String value) {
    _prefs.setString('token', value);
  }

  // GET y SET del player ID
  String get playerID {
    return _prefs.getString('playerID') ?? '';
  }

  set playerID(String value) {
    _prefs.setString('playerID', value);
  }

  bool get registeredPlayerID {
    return _prefs.getBool('registeredPlayerID') ?? false;
  }

  set registeredPlayerID(bool value){
    _prefs.setBool('registeredPlayerID', value);
  }
  // GET y SET del idUsuario
  String get usuarioLogged {
    return _prefs.getString('usuario') ?? '';
  }

  set usuarioLogged(String value) {
    _prefs.setString('usuario', value);
  }

  String get themeMode {
    return _prefs.getString('tema') ?? 'Dark';
  }

  set themeMode(String value) {
    _prefs.setString('tema', value);
  }

  String get versionApp {
    return _prefs.getString('versionApp') ?? '';
  }

  set versionApp(String value) {
    _prefs.setString('versionApp', value);
  }

  borraPrefs() async {
    await _prefs.remove('usuario');
  }
}
