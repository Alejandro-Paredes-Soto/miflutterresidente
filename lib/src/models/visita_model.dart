import 'dart:convert';

VisitaModel visitaModelFromJson(String str) =>
    VisitaModel.fromJson(json.decode(str));

class VisitaModel {
  String idVisitas;
  String fechaEntrada;
  String horaEntrada;
  String? fechaSalida;
  String? horaSalida;
  String placa;
  String color;
  String marca;
  String modelo;
  String visitante;
  String motivoVisita;
  String imgPlaca;
  String imgId;
  String imgRostro;
  int tipoVisita = 1;
  String codigo;
  String? estatus;
  String? reporte;
  String? noMolestar;
  DateTime? fechaCompleta;
  String servicioLlamada;
  String appIdAgora;
  String channelCall;
  String tipoVisitante;

  VisitaModel(
      {
      required this.idVisitas,
      required this.fechaEntrada,
      required this.horaEntrada,
      this.fechaSalida,
      this.horaSalida,
      required this.placa,
      required this.color,
      required this.marca,
      required this.modelo,
      required this.visitante,
      required this.motivoVisita,
      required this.imgPlaca,
      required this.imgId,
      required this.imgRostro,
      this.tipoVisita = 1,
      required this.codigo,
      this.estatus,
      this.reporte,
      this.noMolestar,
      required this.fechaCompleta,
      required this.servicioLlamada,
      required this.appIdAgora,
      required this.channelCall,
      required this.tipoVisitante});

  factory VisitaModel.fromJson(Map<String, dynamic> json) => VisitaModel(
      idVisitas: json["idVisitas"],
      fechaEntrada: json["fecha_entrada"],
      horaEntrada: json["hora_entrada"],
      fechaSalida: json['fecha_salida'],
      horaSalida: json["hora_salida"],
      placa: json["placa"] ?? '',
      color: json["color"] ?? '',
      marca: json["marca"] ?? '',
      modelo: json["modelo"] ?? '',
      visitante: json["visitante"],
      motivoVisita: json["motivo_visita"] ?? '',
      imgPlaca: json["img_placa"] ?? '',
      imgId: json["img_id"] ?? '',
      imgRostro: json["img_rostro"] ?? '',
      codigo: json["codigo"] ?? '',
      estatus: json["estatus"],
      reporte: json["reporte"],
      noMolestar: json["no_molestar"],
      fechaCompleta: DateTime.tryParse(json["fecha_completa"] ?? ""),
      servicioLlamada: json["servicio_llamada"] ?? '0',
      appIdAgora: json['appIdAgora'] ?? '',
      channelCall: json['channelCall'] ?? '',
      tipoVisitante: json['tipoVisitante'] ?? '');
}
