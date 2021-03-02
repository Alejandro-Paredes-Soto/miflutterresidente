import 'package:dostop_v2/src/models/aviso_model.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';

class AvisoDetallePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final aviso = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: utils.appBarLogoD(titulo: 'Aviso'),
      body: _creaBody(aviso),
      floatingActionButton: _creaFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _creaBody(AvisoModel aviso) {
    return Container(
      margin: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                aviso.fecha != null
                    ? utils.fechaCompleta(DateTime.parse(aviso.fecha))
                    : '',
                style: utils.estiloTextoAppBar(26),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 0,
                color: Colors.transparent,
                child: Text(
                  aviso.descripcion,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _creaFAB(BuildContext context) {
    return FloatingActionButton.extended(
        backgroundColor: utils.colorPrincipal,
        icon: Icon(Icons.arrow_back_ios),
        label: Text('Regresar'),
        onPressed: () => Navigator.pop(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)));
  }
}
