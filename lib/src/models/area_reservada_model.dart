import 'dart:convert';

import 'package:intl/intl.dart';

AreaReservadaModel areaReservadaModelFromJson(String str) => AreaReservadaModel.fromJson(json.decode(str));

String areaReservadaModelToJson(AreaReservadaModel data) => json.encode(data.toJson());

class AreaReservadaModel {
    String nombre;
    String estatus;
    DateTime fecha;

    AreaReservadaModel({
        required this.nombre,
        required this.estatus,
        required this.fecha,
    });

    factory AreaReservadaModel.fromJson(Map<String, dynamic> json) => AreaReservadaModel(
        nombre: json["nombre"],
        estatus: json["estatus"],
        fecha: DateFormat('yyyy-MM-dd').parse(json["fecha"]),
    );

    Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "estatus": estatus,
        "fecha": fecha.toIso8601String(),
    };
}
