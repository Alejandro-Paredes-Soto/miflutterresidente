
import 'dart:convert';

AccesoModel accesoModelFromJson(String str) => AccesoModel.fromJson(json.decode(str));

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
        required this.tipoAcceso,
        required this.nombreAcceso,
        required this.rutaImg
    });

    String? idEntradaSalida;
    String? placas;
    String? marca;
    String? modelo;
    String? color;
    String? accion;
    String? accionNombre;
    DateTime? fechaAcceso;
    String? horaAcceso;
    String tipoAcceso;
    String nombreAcceso;
    String rutaImg;

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
        tipoAcceso: json["tipo_acceso"]??"",
        nombreAcceso: json["nombre_acceso"]??"",
        rutaImg: json["urlImg"]??""
    );
}
