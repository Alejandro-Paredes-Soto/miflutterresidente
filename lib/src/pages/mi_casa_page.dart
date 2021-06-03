import 'package:dostop_v2/src/providers/mi_casa_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

import 'package:flutter/material.dart';

class MiCasaPage extends StatefulWidget {
  @override
  _MiCasaPageState createState() => _MiCasaPageState();
}

class _MiCasaPageState extends State<MiCasaPage> {
  final miCasaProvider = MiCasaProvider();
  final _prefs = PreferenciasUsuario();
  Future<Map<int, dynamic>> _datosPagoFuture;
  @override
  void initState() {
    super.initState();
    _datosPagoFuture = miCasaProvider.obtenerDatosPago(_prefs.usuarioLogged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Mi Casa'),
      body: _creaBody(),
    );
  }

  Widget _creaBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: <Widget>[
          Expanded(child: _cargaDatosPago()),
        ],
      ),
    );
  }

  Widget _cargaDatosPago() {
    return FutureBuilder(
      future: _datosPagoFuture,
      builder:
          (BuildContext context, AsyncSnapshot<Map<int, dynamic>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.containsKey(1)) {
            final PagosUsuarioModel datosPago = snapshot.data[1];
            Map<String, dynamic> saldo = funcionSaldo(datosPago.saldo);
            return Container(
              child: Column(
                children: <Widget>[
                  Text(saldo['texto'],
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(
                    saldo['monto'],
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: saldo['color']),
                    margin: EdgeInsets.symmetric(horizontal: 90),
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Text(saldo['estado'],
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),
                  Text('Historial de pagos',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: datosPago.pagos.length,
                      itemExtent: 50,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.black12))),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 5),
                            title: Text(
                                '${utils.fechaCompleta(datosPago.pagos[index].fechaPago, showTime: true)}'),
                            trailing: Text(
                              '\$${datosPago.pagos[index].monto}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          }
          return Center(
              child: Text(snapshot.data[2], style: TextStyle(fontSize: 16)));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Map<String, dynamic> funcionSaldo(String saldo) {
    final saldoDouble = double.tryParse(saldo) ?? 0;
    if (saldoDouble > 0)
      return {
        'texto': 'Total a pagar:',
        'monto': '\$${saldoDouble.toStringAsFixed(2)}',
        'estado': 'Con adeudo',
        'color': utils.colorPrincipal
      };
    if (saldoDouble < 0)
      return {
        'texto': 'Saldo a favor:',
        'monto': '\$${(saldoDouble * -1).toStringAsFixed(2)}',
        'estado': 'Sin adeudo',
        'color': utils.colorContenedorSaldo
      };
    return {
      'texto': 'Saldo:',
      'monto': '\$0.00',
      'estado': 'Sin adeudo',
      'color': utils.colorContenedorSaldo
    };
  }

  @override
  void dispose() {
    super.dispose();
  }
}
