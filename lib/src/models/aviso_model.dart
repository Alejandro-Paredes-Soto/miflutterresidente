import 'dart:convert';

AvisoModel avisoModelFromJson(String str) => AvisoModel.fromJson(json.decode(str));

String avisoModelToJson(AvisoModel data) => json.encode(data.toJson());

class AvisoModel {
    String descripcion;
    String fecha;
    String tag;
    AvisoModel({
        this.descripcion='',
        this.fecha='',
        this.tag='',
    });

    factory AvisoModel.fromJson(Map<String, dynamic> json) => AvisoModel(
        descripcion: json["descripcion"],
        fecha: json["fecha"],
    );

    Map<String, dynamic> toJson() => {
        "descripcion": descripcion,
        "fecha": fecha,
    };
}
