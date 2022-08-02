import 'dart:convert';

AreaComunModel areaComunModelFromJson(String str) => AreaComunModel.fromJson(json.decode(str));

String areaComunModelToJson(AreaComunModel data) => json.encode(data.toJson());

class AreaComunModel {
    String nombre;
    String idAreasComunes;

    AreaComunModel({
        required this.nombre,
        required this.idAreasComunes,
    });

    factory AreaComunModel.fromJson(Map<String, dynamic> json) => AreaComunModel(
        nombre: json["nombre"],
        idAreasComunes: json["idAreas_Comunes"],
    );

    Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "idAreas_Comunes": idAreasComunes,
    };
}
