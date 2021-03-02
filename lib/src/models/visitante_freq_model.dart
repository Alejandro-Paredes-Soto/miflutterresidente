import 'dart:convert';

VisitanteFreqModel visitanteFreqModelFromJson(String str) => VisitanteFreqModel.fromJson(json.decode(str));

// String visitanteFreqModelToJson(VisitanteFreqModel data) => json.encode(data.toJson());

class VisitanteFreqModel {
    String nombre;
    String descripcion;
    DateTime fechaAlta;
    String codigo;
    String tipo;
    String idFrecuente;
    DateTime vigencia;
    bool unico;

    VisitanteFreqModel({
        this.nombre,
        this.descripcion,
        this.fechaAlta,
        this.codigo,
        this.tipo,
        this.idFrecuente,
        this.vigencia,
        this.unico
    });

    factory VisitanteFreqModel.fromJson(Map<String, dynamic> json) => VisitanteFreqModel(
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        fechaAlta: DateTime.parse(json["fecha_alta"]),
        codigo: json["codigo"],
        tipo: json["tipo"],
        idFrecuente: json["id_frecuente"],
        vigencia: DateTime.parse(json["vigencia"]),
        unico: json["tipo"]=='unico'?true:false
    );

    // Map<String, dynamic> toJson() => {
    //     "nombre": nombre,
    //     "descripcion": descripcion,
    //     "fecha_alta": fechaAlta.toIso8601String(),
    //     "codigo": codigo,
    //     "tipo": tipo,
    //     "id_frecuente": idFrecuente,
    // };
}
