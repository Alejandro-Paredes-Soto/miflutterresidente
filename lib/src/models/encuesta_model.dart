
import 'dart:convert';

EncuestaModel encuestaModelFromJson(String str) => EncuestaModel.fromJson(json.decode(str));


class EncuestaModel {
    EncuestaModel({
        this.idEncuesta,
        this.pregunta,
        this.respuestas,
    });

    String idEncuesta;
    String pregunta;
    List<Respuesta> respuestas;

    factory EncuestaModel.fromJson(Map<String, dynamic> json) => EncuestaModel(
        idEncuesta: json["id_encuesta"],
        pregunta: json["pregunta"],
        respuestas: List<Respuesta>.from(json["respuestas"].map((x) => Respuesta.fromJson(x))),
    );
}

class Respuesta {
    Respuesta({
        this.idRespuestaEncuesta,
        this.respuestaEncuesta,
    });

    String idRespuestaEncuesta;
    String respuestaEncuesta;

    factory Respuesta.fromJson(Map<String, dynamic> json) => Respuesta(
        idRespuestaEncuesta: json["id_respuesta_encuesta"],
        respuestaEncuesta: json["respuesta_encuesta"],
    );
}
