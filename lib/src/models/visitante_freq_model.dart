import 'dart:convert';

VisitanteFreqModel visitanteFreqModelFromJson(String str) =>
    VisitanteFreqModel.fromJson(json.decode(str));

// String visitanteFreqModelToJson(VisitanteFreqModel data) => json.encode(data.toJson());

class VisitanteFreqModel {
  String nombre;
  String descripcion;
  String fechaAlta;
  String codigo;
  String tipo;
  String tipoAcceso;
  String idFrecuente;
  DateTime vigencia;
  bool unico;
  String urlImg;
  String activo;
  String estatusDispositivo;
  bool expiroTolerancia;
  String tipoVisitante;
  String telefono;

  VisitanteFreqModel(
      {this.nombre,
      this.descripcion,
      this.fechaAlta,
      this.codigo,
      this.tipo,
      this.tipoAcceso,
      this.idFrecuente,
      this.vigencia,
      this.unico,
      this.urlImg,
      this.activo,
      this.estatusDispositivo,
      this.expiroTolerancia,
      this.tipoVisitante,
      this.telefono});

  factory VisitanteFreqModel.fromJson(Map<String, dynamic> json) =>
      VisitanteFreqModel(
        nombre: json["nombre"],
        telefono: json["tel"] ?? "",
        descripcion: json["descripcion"],
        fechaAlta: json["fecha_alta"],
        codigo: json["codigo"],
        tipo: json["tipo"],
        tipoAcceso: json["tipo_acceso"] ?? "",
        idFrecuente: json["id_frecuente"],
        vigencia: DateTime.tryParse(json["vigencia"] ?? ""),
        unico: json["tipo"] == 'unico' ? true : false,
        urlImg: json["url_img"] ?? "",
        estatusDispositivo: json["estatus_dispositivo"] ?? "",
        activo: json["activo"] ?? "",
        expiroTolerancia: json["expiro_tolerancia"] == "true" ? true : false,
        tipoVisitante: json["tipo_visitante"] ?? ""
      );
}
