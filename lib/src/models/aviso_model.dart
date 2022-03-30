import 'dart:convert';

AvisoModel avisoModelFromJson(String str) => AvisoModel.fromJson(json.decode(str));

class AvisoModel {
    String descripcion;
    String fecha;
    String idAviso;
    String imgAviso;
    AvisoModel({
        this.descripcion='',
        this.fecha='',
        this.idAviso='',
        this.imgAviso=''
    });

    factory AvisoModel.fromJson(Map<String, dynamic> json) => AvisoModel(
        descripcion: json["descripcion"],
        fecha: json["fecha"],
        idAviso: json["idAvisos"],
        imgAviso: json["img"]
    );
}
