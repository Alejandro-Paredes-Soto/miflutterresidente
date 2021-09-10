import 'package:auto_size_text/auto_size_text.dart';
import 'package:dostop_v2/src/providers/avisos_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';

class AvisosPage extends StatefulWidget {
  @override
  _AvisosPageState createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {
  final avisosProvider = AvisosProvider();

  final _prefs = PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Avisos'),
      body: _crearAvisos(context),
    );
  }

  Widget _crearAvisos(BuildContext context) {
    return FutureBuilder(
      future: avisosProvider.cargaAvisos(_prefs.usuarioLogged),
      builder:
          (BuildContext context, AsyncSnapshot<List<AvisoModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Container(
              child: RefreshIndicator(
                onRefresh: _obtenerUltimosAvisos,
                child: ListView.separated(
                  padding: EdgeInsets.all(15),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) =>
                      _crearItem(context, snapshot.data[index]),
                  separatorBuilder: (context, index) => SizedBox(height: 5.0),
                ),
              ),
            );
          } else {
            return Center(
              child: Text('No tienes avisos por ahora',
                  style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _crearItem(BuildContext context, AvisoModel aviso) {
    return Hero(
      tag: aviso.idAviso,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
            height: 120.0,
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                          flex: 1,
                          child: Text(
                            '${utils.fechaCompleta(DateTime.tryParse(aviso.fecha))}',
                            style: utils.estiloFechaAviso(12),
                          )),
                      SizedBox(height:5),
                      Flexible(
                          flex: 4,
                          child: Text(
                            '${aviso.descripcion}',
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ))
                    ],
                  )),
              Expanded(
                flex: 1,
                child: RaisedButton(
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: AutoSizeText('Ver más',
                      maxLines: 2, style: utils.estiloBotones(12)),
                  onPressed: () => _abrirAvisoDetalle(aviso, context),
                ),
              )
            ])),
      ),
    );
  }

  _abrirAvisoDetalle(AvisoModel aviso, BuildContext context) {
    Navigator.of(context).pushNamed('AvisoDetalle', arguments: aviso);
  }

  Future<void> _obtenerUltimosAvisos() async {
    return Future.delayed(Duration(seconds: 1), () {
      setState(() {});
    });
  }
}
