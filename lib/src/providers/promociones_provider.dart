import 'dart:convert';

import 'package:dostop_v2/src/models/promo_model.dart';
import 'login_validator.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class PromocionesProvider {
  
  final validaSesion = LoginValidator();

  Future<List<PromocionModel>> cargaPromociones(String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http.post(Uri.parse('${constantes.urlApp}/obtener_promociones.php'), body: {'id': idUsuario});
      List? decodeResp = json.decode(resp.body);
      final List<PromocionModel> promociones = [];
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
