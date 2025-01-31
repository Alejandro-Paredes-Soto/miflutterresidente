import 'dart:convert';

List<CuentaModel> cuentaEgresosModelFromJson(String str) =>
    List<CuentaModel>.from(
        json.decode(str).map((x) => CuentaModel.fromJson(x)));

class CuentaModel {
  String mes;
  String anio;
  String tipoCuentaMes;
  List<ListElement> list;

  CuentaModel({
    required this.mes,
    required this.anio,
    required this.tipoCuentaMes,
    required this.list,
  });

  factory CuentaModel.fromJson(Map<String, dynamic> json) => CuentaModel(
        mes: json["mes"],
        anio: json["anio"],
        tipoCuentaMes: json.containsKey("egresos_mes")
            ? json["egresos_mes"]
            : json['ingresos_mes'],
        list: List<ListElement>.from(
            json["list"].map((x) => ListElement.fromJson(x))),
      );
}

class ListElement {
  String concepto;
  String monto;
  String nombreProv;

  ListElement({
    required this.concepto,
    required this.monto,
    required this.nombreProv,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
      concepto: json["concepto"],
      monto: json["monto"],
      nombreProv:
          json.containsKey('nombreProveedor') ? json["nombreProveedor"] : '');
}
