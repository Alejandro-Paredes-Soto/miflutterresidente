import 'dart:convert';

import 'package:dostop_v2/src/models/visitante_freq_model.dart';
import 'package:flutter/material.dart';
import 'login_validator.dart';
import 'constantes_provider.dart' as constantes;

import 'package:http/http.dart' as http;

class VisitantesFreqProvider {
  final validaSesion = LoginValidator();

  Future<ValueNotifier<List<VisitanteFreqModel>>> cargaVisitantesFrecuentes(
      String idUsuario, int tipo) async {
    validaSesion.verificaSesion();
    ValueNotifier<List<VisitanteFreqModel>> listFreq = ValueNotifier([]);
    try {
      final resp = await http.post(
          Uri.parse('${constantes.urlApp}/obtener_frecuentes.php'),
          body: {'id_colono': idUsuario, 'tipo_frecuente': '$tipo'});
      Map? decodeResp = json.decode(resp.body);
      final List<VisitanteFreqModel> visitantes = [];
      if (decodeResp == null) return listFreq;
      if (decodeResp.containsKey('lista_frecuente'))
        decodeResp['lista_frecuente'].forEach((visitante) {
          final tempFrecuente = VisitanteFreqModel.fromJson(visitante);
          visitantes.add(tempFrecuente);
          listFreq.value.add(tempFrecuente);
        });

      return listFreq;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - CARGAR VISITANTES:\n $e');
      return listFreq;
    }
  }

  Future<Map<String, dynamic>> archivarQR(String idFrecuente) async {
    try {
      final url = Uri.parse('${constantes.ulrApiProd}/visita/');

      var request = http.Request('DELETE', url);
      request.body = json.encode({'idVisitante': idFrecuente});
      request.headers.addAll({'Content-Type': 'application/json'});
      final resp = await request.send();

      if (resp.statusCode != 404) {
        Map mapResp = json.decode(await resp.stream.bytesToString());

        if (mapResp['statusCode'] == 200) {
          return {'OK': 1};
        } else {
          return {'OK': 2, 'message': mapResp['message']};
        }
      }

      return {'OK': 2};
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - ELIMINAR VISITANTE:\n $e');

      return {'OK': 2};
    }
  }

  Future<Map<String, dynamic>> eliminaVisitanteFrecuente(
      String idFrecuente, String idUsuario, int tipo) async {
    try {
      final resp = await http.post(
          Uri.parse('${constantes.urlApp}/eliminar_frecuente.php'),
          body: {
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
      {required String idUsuario,
      required String nombre,
      required String apPaterno,
      required String apMaterno,
      required String vigencia,
      required bool esUnico,
      required String tipoVisitante}) async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();
    final visitanteData = {
      'colono': idUsuario,
      'nombre': nombre,
      'ape_paterno': apPaterno,
      'ape_materno': apMaterno,
      'tipo': esUnico ? 'unico' : '',
      'vigencia': vigencia,
      'tipo_visitante': tipoVisitante
    };
    try {
      final resp = await http.post(
          Uri.parse('${constantes.urlApp}/registrar_frecuente2.php'),
          body: visitanteData);
      List decodeResp = json.decode(resp.body);
      decodeResp[0].forEach((k, v) => mapResp[k] = v);
      // print(decodeResp);
      if (mapResp['estatus'].toString().contains('1')) {
        return {
          'OK': 1,
          'message': 'Visitante frecuente creado',
          'codigo': mapResp['codigo']
        };
      } else {
        return {'OK': 2, 'message': mapResp['message']};
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - NUEVO VISITANTE:\n $e');
      return {'OK': 2};
    }
  }

  Future<Map<String, dynamic>> nuevoAccesoRostro(
      {required String idUsuario,
      required String nombre,
      required String apPaterno,
      required String apMaterno,
      required String imgRostroB64,
      String? tipoAcceso,
      required int tipo,
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
      final resp = await http.post(
          Uri.parse('${constantes.urlApp}/registrar_rostro.php'),
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

  Future<Map<String, dynamic>> changeImage(
      {required String idUsuario,
      required String idFrecuente,
      required String image,
      required String tipo}) async {
    final visitanteData = {
      'idColono': idUsuario,
      'idFrecuente': idFrecuente,
      'image': image,
      'tipoFrecuente': tipo.toString(),
    };

    try {
      final resp = await http.post(
          Uri.parse('${constantes.urlApp}/changeFaceImage.php'),
          body: json.encode(visitanteData),
          headers: {'Content-Type': 'application/json'});

      if (resp.statusCode == 404) {
        return {
          'status': 'NOT FOUND',
          'statusCode': 400,
          'message': 'Servicio no encontrado'
        };
      }

      Map<String, dynamic> mapResp = json.decode(resp.body);

      return mapResp;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - NUEVO VISITANTE:\n $e');

      return {
        'status': e.runtimeType.toString(),
        'statusCode': 0,
        'message': 'Ocurrio un error inesperado.'
      };
    }
  }
}
