import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/providers/reporte_incidente_provider.dart';

import 'package:flutter/material.dart';

class SeguimientoIncidentePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final ReporteModel _reporte = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Seguimiento'),
      body: _creaBody(context, _reporte),
    );
  }

  _creaBody(BuildContext context, ReporteModel reporte) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
                alignment: Alignment.centerRight,
                height: 20,
                child: Text('Tu mensaje')),
            _creaTextReporte(context, reporte.datos.mensaje,
                reporte.datos.fechaMensaje.toString()),
            SizedBox(
              height: 10,
            ),
            Visibility(
              visible: reporte.datos.respuesta == '' ? false : true,
              child: Container(
                  alignment: Alignment.centerLeft,
                  height: 20,
                  child: Text('Respuesta de caseta')),
            ),
            _creaTextRespuesta(
                context, reporte.datos.respuesta, reporte.datos.fechaRespuesta),
            SizedBox(height: 20),
          ],
        ));
  }

  Widget _creaTextReporte(BuildContext context, String texto, String fecha) {
    return Container(
      decoration: BoxDecoration(
          color: utils.colorPrincipal, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: EdgeInsets.only(left: 100),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              texto,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 5),
          Container(
            alignment: Alignment.topRight,
            child: Text(
              fecha,
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _creaTextRespuesta(BuildContext context, String texto, String fecha) {
    return Visibility(
      visible: texto == '' ? false : true,
      child: Container(
        decoration: BoxDecoration(
            color: utils.colorAcentuado,
            borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: EdgeInsets.only(right: 100),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                texto,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 5),
            Container(
              alignment: Alignment.topRight,
              child: Text(
                fecha,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
