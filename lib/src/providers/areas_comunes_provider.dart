import 'dart:convert';

import 'package:dostop_v2/src/models/area_comun_model.dart';
export 'package:dostop_v2/src/models/area_comun_model.dart';
import 'package:dostop_v2/src/models/area_reservada_model.dart';
import 'login_validator.dart';
import 'constantes_provider.dart' as constantes;

export 'package:dostop_v2/src/models/area_reservada_model.dart';

import 'package:http/http.dart' as http;

class AreasComunesProvider {
  final validaSesion = LoginValidator();

  Future<List<AreaComunModel>> obtenerListadoAreas(String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http
          .post(Uri.parse('${constantes.urlApp}/obtener_areas_comunes.php'), body: {'id': idUsuario});
      List? decodeResp = json.decode(resp.body);
      final List<AreaComunModel> areas = [];
      if (decodeResp == null) return [];
      decodeResp.forEach((area) {
        //  print('$area');
        final tempArea = AreaComunModel.fromJson(area);
        areas.add(tempArea);
      });
      return areas;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de AREAS COMUNES - OBTENER LISTADO:\n $e');
      return [];
    }
  }

  Future<List<AreaReservadaModel>> obtenerMisReservas(String idUsuario) async {
    validaSesion.verificaSesion();
    try {
      final resp = await http
          .post(Uri.parse('${constantes.urlApp}/obtener_mis_reservas.php'), body: {'id': idUsuario});
      List? decodeResp = json.decode(resp.body);
      final List<AreaReservadaModel> reservas = [];
      if (decodeResp == null) return [];
      decodeResp.forEach((reserva) {
        final tempreserva = AreaReservadaModel.fromJson(reserva);
        reservas.add(tempreserva);
      });
      return reservas;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de AREAS COMUNES - OBTENER RESERVAS USUARIO:\n $e');
      return [];
    }
  }

  Future<List<String>> obtenerReservasCalendario(
      String idUsuario, String idAreaComun) async {
      validaSesion.verificaSesion();
    try {
      final resp = await http.post(Uri.parse('${constantes.urlApp}/obtener_areas_reservadas.php'),
          body: {'id': idUsuario, 'idArea': idAreaComun});
      List? decodeResp = json.decode(resp.body);
      final List<String> reservasCalendario = [];
      if (decodeResp == null) return [];
      decodeResp.forEach((reserva) {
        final tempreserva = reserva['fecha'];
        reservasCalendario.add(tempreserva);
      });
      return reservasCalendario;
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de AREAS COMUNES - OBTENER RESERVAS CALENDARIO:\n $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> reservarAreaComun(
      String idUsuario, String fecha, String idArea) async {
    Map<String, dynamic> mapResp = Map<String, dynamic>();
    try {
      final resp = await http.post(Uri.parse('${constantes.urlApp}/confirmar_reserva_area.php'),
          body: {'id': idUsuario, 'fecha': fecha, 'idArea': idArea});
      List decodeResp = json.decode(resp.body);
      decodeResp[0].forEach((k, v) {
        mapResp[k] = v;
      });
      // print(decodeResp);
      if (mapResp['estatus'].toString().contains('1')) {
        return {'OK': true, 'message':'Solicitud de reserva enviada'};
      } else {
        return {'OK': false, 'message':'Ya existe una solicitud para la fecha seleccionada'};
      }
    } catch (e) {
      print(
          'Ocurrió un error en la llamada al Servicio de VISITANTES FRECUENTES - ELIMINAR VISITANTE:\n $e');
      return {'OK': false, 'message':'No se pudo enviar la solicitud'};
    }
  }

}
