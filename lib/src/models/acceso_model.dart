
import 'dart:convert';

AccesoModel accesoModelFromJson(String str) => AccesoModel.fromJson(json.decode(str));

String accesoModelToJson(AccesoModel data) => json.encode(data.toJson());

class AccesoModel {
    AccesoModel({
        this.idEntradaSalida,
        this.placas,
        this.marca,
        this.modelo,
        this.color,
        this.accion,
        this.accionNombre,
        this.fechaAcceso,
        this.horaAcceso,
    });

    String idEntradaSalida;
    String placas;
    String marca;
    String modelo;
    String color;
    String accion;
    String accionNombre;
    DateTime fechaAcceso;
    String horaAcceso;

    factory AccesoModel.fromJson(Map<String, dynamic> json) => AccesoModel(
        idEntradaSalida: json["idEntradaSalida"],
        placas: json["placas"],
        marca: json["marca"],
        modelo: json["modelo"],
        color: json["color"],
        accion: json["accion"],
        accionNombre: json["accion_nombre"],
        fechaAcceso: DateTime.parse(json["fecha_acceso"]),
        horaAcceso: json["hora_acceso"],
    );

    Map<String, dynamic> toJson() => {
        "idEntradaSalida": idEntradaSalida,
        "placas": placas,
        "marca": marca,
        "modelo": modelo,
        "color": color,
        "accion": accion,
        "accion_nombre": accionNombre,
        "fecha_acceso": "${fechaAcceso.year.toString().padLeft(4, '0')}-${fechaAcceso.month.toString().padLeft(2, '0')}-${fechaAcceso.day.toString().padLeft(2, '0')}",
        "hora_acceso": horaAcceso,
    };
}
