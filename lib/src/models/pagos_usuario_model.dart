import 'dart:convert';

PagosUsuarioModel pagosUsuarioModelFromJson(String str) =>
    PagosUsuarioModel.fromJson(json.decode(str));

class PagosUsuarioModel {
  String titulo;
  String saldo;
  String estado;
  List<Pago> pagos;

  PagosUsuarioModel({
    this.titulo,
    this.saldo,
    this.estado,
    this.pagos,
  });

  factory PagosUsuarioModel.fromJson(Map<String, dynamic> json) =>
      PagosUsuarioModel(
        saldo: json["saldo"],
        pagos: List<Pago>.from(json["pagos"].map((x) => Pago.fromJson(x))),
      );
}

class Pago {
  DateTime fechaPago;
  String monto;

  Pago({
    this.fechaPago,
    this.monto,
  });

  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
        fechaPago: DateTime.parse(json["fecha_pago"]),
        monto: json["monto"],
      );
}
