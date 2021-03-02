import 'dart:convert';

import 'package:intl/intl.dart';

ReporteModel reporteModelFromJson(String str) => ReporteModel.fromJson(json.decode(str));

class ReporteModel {
    String estatus;
    Datos datos;

    ReporteModel({
        this.estatus,
        this.datos,
    });

    factory ReporteModel.fromJson(Map<String, dynamic> json) => ReporteModel(
        estatus: json["estatus"],
        datos: Datos.fromJson(json["datos"]),
    );
}

class Datos {
    String mensaje;
    String fechaMensaje;
    String respuesta;
    String fechaRespuesta;

    Datos({
        this.mensaje,
        this.fechaMensaje,
        this.respuesta,
        this.fechaRespuesta,
    });

    factory Datos.fromJson(Map<String, dynamic> json) => Datos(
        mensaje: json["mensaje"],
        fechaMensaje: json["fecha_mensaje"]!=''?DateFormat('dd-MM-yyyy')
        .format(DateFormat('yyyy-MM-dd').parse(json["fecha_mensaje"])).toString():'',
        respuesta: json["respuesta"],
        fechaRespuesta:  json["fecha_respuesta"]!=''?DateFormat('dd-MM-yyyy')
        .format(DateFormat('yyyy-MM-dd').parse(json["fecha_respuesta"])).toString():'',
    );
}