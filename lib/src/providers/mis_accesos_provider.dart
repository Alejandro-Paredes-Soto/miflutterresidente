import 'dart:convert';
import 'package:dostop_v2/src/models/acceso_model.dart';
export 'package:dostop_v2/src/models/acceso_model.dart';
import 'constantes_provider.dart' as constantes;
import 'login_validator.dart';

import 'package:http/http.dart' as http;


class MisAccesosProvider {
  final _validaSesion = LoginValidator();

  Future<List<AccesoModel>> obtenerAccesos(String idUsuario, int pagina,
      {bool vaciarLista = false}) async {
    _validaSesion.verificaSesion();
    try {
      final resp = await http.post('${constantes.urlApp}/test_img.php',
          body: {'id': idUsuario, 'page_no': pagina.toString()});
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      if (decodeResp == null) return [];
      if (decodeResp.containsKey('datos')) {
        final List<AccesoModel> accesos = new List();
        for (Map<String, dynamic> acceso in decodeResp['datos']) {
          // print('$acceso');
          final tempAcceso = AccesoModel.fromJson(acceso);
          accesos.add(tempAcceso);
        }
        return accesos;
      } else {
        print(
            "Mensaje desde Servicio de ACCESOS - BUSCADOR: ${decodeResp['message']}");
        return [];
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de ACCESOS - BUSCADOR:\n $e');
      return [];
    }
  }
}
