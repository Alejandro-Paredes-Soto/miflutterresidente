import 'package:dostop_v2/src/providers/mis_accesos_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/widgets/dinamic_list_view.dart';
import 'package:flutter/material.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

class MisAccesosPage extends StatefulWidget {
  @override
  _MisAccesosPageState createState() => _MisAccesosPageState();
}

class _MisAccesosPageState extends State<MisAccesosPage> {
  final _accesosProvider = MisAccesosProvider();
  final _prefs = PreferenciasUsuario();
  final _key = GlobalKey();
  Future<List<AccesoModel>> _accesosProviderFuture;
  int _pag = 1;

  @override
  void initState() {
    super.initState();
    _accesosProviderFuture =
        _accesosProvider.obtenerAccesos(_prefs.usuarioLogged, _pag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Mis accesos'),
      body: _creaBody(),
    );
  }

  Widget _creaBody() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          _creaListaVehiculos(),
          Expanded(child: _cargaListadoAccesos()),
          _creaBannerIconos()
        ],
      ),
    );
  }

  Widget _creaListaVehiculos() {
    return Container();
  }

  Widget _cargaListadoAccesos() {
    return DynamicListView.build(
        key: _key,
        dataRequester: _dataRequester,
        initRequester: _initRequester,
        itemBuilder: (List dataList, BuildContext context, int index) {
          if (dataList.length > 0)
            return _crearItem(context, dataList[index], index);
          else
            return Center(
              child: Text('No se encontraron accesos'),
            );
        });
  }

  Future<List> _dataRequester() async {
    _pag++;
    return await _accesosProvider.obtenerAccesos(_prefs.usuarioLogged, _pag);
  }

  Future<List> _initRequester() async {
    return Future.value(_accesosProviderFuture);
  }

  Widget _crearItem(BuildContext context, AccesoModel acceso, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Icon(
                acceso.accion == '1'
                    ? Icons.arrow_circle_up
                    : Icons.arrow_circle_down,
                color: acceso.accion == '1'
                    ? utils.colorContenedorSaldo
                    : utils.colorPrincipal,
                size: 40,
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Vehiculo', style: utils.estiloTituloTarjeta(14)),
                  Text('${acceso.marca} ${acceso.modelo} ${acceso.color}',
                      style: utils.estiloSubtituloTarjeta(17)),
                  Text('Placas', style: utils.estiloTituloTarjeta(14)),
                  Text('${acceso.placas}',
                     style: utils.estiloSubtituloTarjeta(17)),
                  Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Text(
                      '${utils.fechaCompleta(acceso.fechaAcceso)} ${acceso.horaAcceso}',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _creaBannerIconos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(children: [
          SizedBox(height: 5),
          Icon(
            Icons.arrow_circle_up,
            color: utils.colorContenedorSaldo,
          ),
          Text('Entrada')
        ]),
        Column(children: [
          SizedBox(height: 5),
          Icon(
            Icons.arrow_circle_down,
            color: utils.colorPrincipal,
          ),
          Text('Salida')
        ])
      ],
    );
  }
}
