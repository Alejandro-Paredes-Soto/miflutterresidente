import 'dart:convert';

List<ResultadosEncuestaModel> resultadosEncuestaModelFromJson(String str) => List<ResultadosEncuestaModel>.from(json.decode(str).map((x) => ResultadosEncuestaModel.fromJson(x)));

class ResultadosEncuestaModel {
    ResultadosEncuestaModel({
        required this.respuestaEncuesta,
        required this.porcentaje,
    });

    String respuestaEncuesta;
    String porcentaje;

    factory ResultadosEncuestaModel.fromJson(Map<String, dynamic> json) => ResultadosEncuestaModel(
        respuestaEncuesta: json["respuesta_encuesta"],
        porcentaje: json["porcentaje"],
    );
}