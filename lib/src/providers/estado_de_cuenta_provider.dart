import 'dart:convert';

import 'package:dostop_v2/src/models/cuenta_model.dart';
export 'package:dostop_v2/src/models/cuenta_model.dart';
import 'login_validator.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class EstadoDeCuentaProvider {
  
    final validaSesion = LoginValidator();

  Future<String> obtenerSaldoTotal(String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http.post(Uri.parse('${constantes.urlApp}/obtener_saldo.php'), body: {'id': idUsuario});
      List? decodeResp = json.decode(resp.body);
      if (decodeResp == null) return '\$0.00';
      if(decodeResp.length>0)
        if(decodeResp[0].containsKey('saldo'))
          return '\$${decodeResp[0]["saldo"]}';
      return '\$0.00';
    } catch (e) {
      print('Ocurrió un error en la llamada al Servicio de ESTADOS DE CUENTA - SALDO:\n $e');
      return '';
    }
  }

  Future<List<CuentaModel>> obtenerEgresos(String idUsuario) async {
    try {
      final resp = await http
          .post(Uri.parse('${constantes.urlApp}/obtener_egresos.php'), body: {'id': idUsuario});
      List? decodeResp = json.decode(resp.body);
      final List<CuentaModel> egresos = [];
      if (decodeResp == null) return [];
      decodeResp.forEach((egreso) {
        //  print('$egreso');
        final tempEgreso = CuentaModel.fromJson(egreso);
        egresos.add(tempEgreso);
      });
      return egresos;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de ESTADOS DE CUENTA - EGRESOS:\n $e');
      return [];
    }
  }

    Future<List<CuentaModel>> obtenerIngresos(String idUsuario) async {
    try {
      final resp = await http
          .post(Uri.parse('${constantes.urlApp}/obtener_ingresos.php'), body: {'id': idUsuario});
      List? decodeResp = json.decode(resp.body);
      final List<CuentaModel> ingresos = [];
      if (decodeResp == null) return [];
      decodeResp.forEach((ingreso) {
        //  print('$ingreso');
        final tempIngreso = CuentaModel.fromJson(ingreso);
        ingresos.add(tempIngreso);
      });
      return ingresos;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de ESTADOS DE CUENTA - INGRESOS:\n $e');
      return [];
    }
  }
}