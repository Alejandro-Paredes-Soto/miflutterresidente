import 'dart:convert';

TipoVisitanteModel tipoVisitanteModelFromJson(String str) =>
    TipoVisitanteModel.fromJson(json.decode(str));

class TipoVisitanteModel {
  String idTipoVisitante;
  String tipo;

  TipoVisitanteModel({
    required this.idTipoVisitante, 
    required this.tipo});

  factory TipoVisitanteModel.fromJson(Map<String, dynamic> json) =>
      TipoVisitanteModel(
          idTipoVisitante: json["idTipoVisitante"], tipo: json["tipo"]);
}
