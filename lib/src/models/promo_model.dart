import 'dart:convert';

PromocionModel promocionModelFromJson(String str) => PromocionModel.fromJson(json.decode(str));

String promocionModelToJson(PromocionModel data) => json.encode(data.toJson());

class PromocionModel {
    String titulo;
    String ruta1;
    String ruta2;

    PromocionModel({
        required this.titulo,
        required this.ruta1,
        required this.ruta2,
    });

    factory PromocionModel.fromJson(Map<String, dynamic> json) => PromocionModel(
        titulo: json["titulo"],
        ruta1: json["ruta1"],
        ruta2: json["ruta2"],
    );

    Map<String, dynamic> toJson() => {
        "titulo": titulo,
        "ruta1": ruta1,
        "ruta2": ruta2,
    };
}
