import 'dart:convert';

import 'package:intl/intl.dart';

VisitanteFreqModel visitanteFreqModelFromJson(String str) => VisitanteFreqModel.fromJson(json.decode(str));

// String visitanteFreqModelToJson(VisitanteFreqModel data) => json.encode(data.toJson());

class VisitanteFreqModel {
    String nombre;
    String descripcion;
    String fechaAlta;
    String codigo;
    String tipo;
    String idFrecuente;
    DateTime vigencia;
    bool unico;
    String urlImg;
    String activo;
    String estatusDispositivo;


    VisitanteFreqModel({
        this.nombre,
        this.descripcion,
        this.fechaAlta,
        this.codigo,
        this.tipo,
        this.idFrecuente,
        this.vigencia,
        this.unico,
        this.urlImg,
        this.activo,
        this.estatusDispositivo
    });

    factory VisitanteFreqModel.fromJson(Map<String, dynamic> json) => VisitanteFreqModel(
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        fechaAlta: json["fecha_alta"],
        codigo: json["codigo"],
        tipo: json["tipo"],
        idFrecuente: json["id_frecuente"],
        vigencia: DateTime.tryParse(json["vigencia"]??""),
        unico: json["tipo"]=='unico'?true:false,
        urlImg: json["url_img"]??"",
        estatusDispositivo: json["estatus_dispositivo"]??"",
        activo: json["activo"]??""
    );
}
