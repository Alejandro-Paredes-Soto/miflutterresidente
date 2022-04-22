import 'dart:convert';

import 'package:dostop_v2/src/models/visitante_freq_model.dart';
import 'login_validator.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class VisitantesFreqProvider {
  final validaSesion = LoginValidator();

  Future<List<VisitanteFreqModel>> cargaVisitantesFrecuentes(
      String idUsuario, int tipo) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http.post(
          '${constantes.urlApp}/obtener_frecuentes.php',
          body: {'id_colono': idUsuario, 'tipo_frecuente': '$tipo'});
      Map decodeResp = json.decode(resp.body);
      final List<VisitanteFreqModel> visitantes = [];
      if (decodeResp == null) return [];
      if (decodeResp.containsKey('lista_frecuente'))
        decodeResp['lista_frecuente'].forEach((visitante) {
          // print('$visitante');
          final tempFrecuente = VisitanteFreqModel.fromJson(visitante);
          visitantes.add(tempFrecuente);
        });

      return visitantes;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - CARGAR VISITANTES:\n $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> eliminaVisitanteFrecuente(
      String idFrecuente, String idUsuario, int tipo) async {
    try {
      final resp = await http
          .post('${constantes.urlApp}/eliminar_frecuente.php', body: {
        'id_frecuente': idFrecuente,
        'id_colono': idUsuario,
        'tipo_frecuente': '$tipo'
      });
      Map mapResp = json.decode(resp.body);
      // print(decodeResp);
      if (mapResp['estatus'].toString().contains('1')) {
        return {'OK': 1};
      } else {
        return {'OK': 2, 'message': mapResp['estatus']};
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - ELIMINAR VISITANTE:\n $e');
      return {'OK': 2};
    }
  }

  Future<Map<String, dynamic>> nuevoVisitanteFrecuente(
      {String idUsuario,
      String nombre,
      String apPaterno,
      String apMaterno,
      String vigencia,
      String tipoVisitante,
      String flagOrigen,
      String telefono}) async {
    final visitanteData = {
      'idColonos': 3756,
      'nombre': nombre,
      'ape_paterno': apPaterno,
      'ape_materno': apMaterno,
      'idTipoVisitante': tipoVisitante,
      'tipo': flagOrigen == 'dostop' ? 'unico' : '',
      'vigencia': vigencia == 'indefinido' ? '' : (flagOrigen == 'parco' ? '24 hours' : vigencia),
      'flagPerpetual': vigencia == 'indefinido' ? true : false,
      'flagOrigen': flagOrigen,
      'telefono': flagOrigen == 'parco' ? telefono : '',
      'usosParco': -1
    };
    try {
      final resp = await http.post('${constantes.ulrApiProd}/visita/nueva/',
      headers: {'Content-Type': 'application/json'},
          body: json.encode(visitanteData));
      
      if(resp.statusCode == 404){
        return {'statusCode': resp.statusCode, 'status': resp.reasonPhrase};
      }

      Map<String, dynamic> decodeResp = json.decode(resp.body);

      if(decodeResp.containsKey('message') && resp.statusCode != 200){
        return {'statusCode': resp.statusCode, 'status': decodeResp['message']};
      }

      return decodeResp;

    } catch (e) {
      var message = e.runtimeType == 'SocketException'
          ? 'Ha ocurrido un error, favor verificar conexión a internet.'
          : e.message;
      return {'statusCode': 0, 'status': e.runtimeType, 'codigo': message};
    }
  }

  Future<Map<String, dynamic>> nuevoAccesoRostro(
      {String idUsuario,
      String nombre,
      String apPaterno,
      String apMaterno,
      String imgRostroB64,
      String tipoAcceso,
      int tipo,
      String tipoVisitante = ""}) async {
    final visitanteData = {
      'id_colono': idUsuario,
      'nombre': nombre,
      'ape_paterno': apPaterno,
      'ape_materno': apMaterno,
      'img_rostro': imgRostroB64,
      'tipo_frecuente': tipo.toString(),
      'tipo_acceso': tipoAcceso.toString(),
      'tipo_visitante': tipoVisitante.toString()
    };
    try {
      final resp = await http.post('${constantes.urlApp}/registrar_rostro.php',
          body: visitanteData);
      Map mapResp = json.decode(resp.body);
      if (mapResp['estatus'].toString().contains('1')) {
        return {
          'OK': 1,
          'message': 'Visitante frecuente creado',
          'codigo': mapResp['codigo']
        };
      } else {
        return {
          'OK': 2,
          'message': mapResp['message'] ?? 'Ocurrio un error al registrar'
        };
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - NUEVO VISITANTE:\n $e');
      return {'OK': 2};
    }
  }
}
