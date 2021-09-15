import 'package:dostop_v2/src/models/aviso_model.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';

class AvisoDetallePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final aviso = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Aviso'),
      body: _creaBody(context, aviso),
      //floatingActionButton: _creaFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _creaBody(BuildContext context, AvisoModel aviso) {
    return Container(
      margin: EdgeInsets.all(15.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: aviso.idAviso,
                child: Material(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                  elevation: 0,
                  child: Scrollbar(
                    child: ElevatedContainer(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                              utils.fechaCompleta(DateTime.tryParse(aviso.fecha)),
                              style: utils.estiloFechaAviso(12)),
                          SizedBox(height: 5),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Text(
                                aviso.descripcion,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                    width: 100,
                    alignment: Alignment.center,
                    height: 57,
                    child: Text(
                      'Cerrar',
                      style: utils.estiloBotones(12),
                    )),
                onPressed: () => Navigator.pop(context))
          ],
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
