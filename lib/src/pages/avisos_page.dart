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
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) =>
                        _crearItem(context, snapshot.data[index], index)),
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

  Widget _crearItem(BuildContext context, AvisoModel aviso, int) {
    return Column(
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          child: Column(
            children: <Widget>[
              FlatButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                child: Container(
                  width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    height: 200,
                    child: Text(
                      '${aviso.descripcion}',
                      overflow: TextOverflow.fade,
                      style: TextStyle(fontSize: 15),
                    )),
                onPressed: () => _abrirAvisoDetalle(aviso, context),
              ),
              Container(
                  padding: EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                      color: utils.colorPrincipal),
                  width: double.infinity,
                  height: 25,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '${utils.fechaCompleta(DateTime.tryParse(aviso.fecha))}',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.fade,
                        )
                      ]))
            ],
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  _abrirAvisoDetalle(AvisoModel aviso, BuildContext context) {
    Navigator.of(context).pushNamed('AvisoDetalle', arguments: aviso);
  }

  Future<void> _obtenerUltimosAvisos() async {
    return Future.delayed(Duration(seconds: 1),(){
    setState(() {});
    });
  }
}
