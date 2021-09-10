import 'dart:convert';

AvisoModel avisoModelFromJson(String str) => AvisoModel.fromJson(json.decode(str));

class AvisoModel {
    String descripcion;
    String fecha;
    String idAviso;
    AvisoModel({
        this.descripcion='',
        this.fecha='',
        this.idAviso='',
    });

    factory AvisoModel.fromJson(Map<String, dynamic> json) => AvisoModel(
        descripcion: json["descripcion"],
        fecha: json["fecha"],
        idAviso: json["idAvisos"]
    );
}
