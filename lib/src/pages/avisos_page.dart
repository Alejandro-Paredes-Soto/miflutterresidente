import 'package:auto_size_text/auto_size_text.dart';
import 'package:dostop_v2/src/providers/avisos_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';
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
          if (snapshot.data!.length > 0) {
            return Container(
              child: RefreshIndicator(
                onRefresh: _obtenerUltimosAvisos,
                child: ListView.separated(
                  padding: EdgeInsets.all(15),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) =>
                      _crearItem(context, snapshot.data![index]),
                  separatorBuilder: (context, index) => SizedBox(height: 15.0),
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
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 0,
        child: ElevatedContainer(
          padding: EdgeInsets.all(15.0),
          child: Container(
              height: 100.0,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                        Visibility(
                          visible: aviso.imgAviso.isNotEmpty,
                            child: Flexible(
                              flex: 1,
                              child: Text(
                                'Imagen adjunta',
                                style: utils.estiloFechaAviso(12, color: utils.colorAcentuado),
                              )),
                        ),
                        SizedBox(height: 5),
                        Flexible(
                            flex: 4,
                            child: Text( (aviso.descripcion.isEmpty && aviso.imgAviso.isNotEmpty) ?
                              'Este aviso contiene una imagen, seleccione ver más para visualizarla.'
                              :'${aviso.descripcion}',
                              overflow: TextOverflow.fade,
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ))
                      ],
                    )),
                SizedBox(width: 15),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.all(10.0)
                    ),
                    child: AutoSizeText('Ver más',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: utils.estiloBotones(12)),
                    onPressed: () => _abrirAvisoDetalle(aviso, context),
                  ),
                )
              ])),
        ),
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
