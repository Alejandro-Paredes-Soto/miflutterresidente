import 'dart:convert';

import 'package:dostop_v2/src/models/promo_model.dart';
import 'package:dostop_v2/src/providers/login_validator.dart';
import 'package:http/http.dart' as http;

class PromocionesProvider {
  
  final String url =
      'https://dostop.mx/dostop/WebService/obtener_promociones.php';
  final validaSesion = LoginValidator();

  Future<List<PromocionModel>> cargaPromociones(String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http.post(url, body: {'id': idUsuario});
      List decodeResp = json.decode(resp.body);
      final List<PromocionModel> promociones = new List();
      if (decodeResp == null) return [];
      decodeResp.forEach((promo) {
        //print('$promo');
        final tempPromo = PromocionModel.fromJson(promo);
        promociones.add(tempPromo);
      });
        return promociones;
      
    } catch (e) {
      print('Ocurrió un error en la llamada al Servicio de PROMOCIONES:\n $e');
      return [];
    }
  }
}
