import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:dynamic_list_view/dynamic_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dostop_v2/src/providers/config_usuario_provider.dart';
import 'package:dostop_v2/src/providers/mis_accesos_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

class MisAccesosPage extends StatefulWidget {
  @override
  _MisAccesosPageState createState() => _MisAccesosPageState();
}

class _MisAccesosPageState extends State<MisAccesosPage> {
  final _accesosProvider = MisAccesosProvider();
  final _configUsuarioProvider = ConfigUsuarioProvider();
  final _prefs = PreferenciasUsuario();
  final _key = GlobalKey();
  bool _notificarAccesos = false, _obteniendoConfig = true;
  Future<List<AccesoModel>> _accesosProviderFuture;
  int _pag = 1;

  @override
  void initState() {
    super.initState();
    _accesosProviderFuture =
        _accesosProvider.obtenerAccesos(_prefs.usuarioLogged, _pag);
    _configUsuarioProvider
        .obtenerEstadoConfig(_prefs.usuarioLogged, 3)
        .then((resultado) {
      ///previene la llamada del setState cuando el widget ya ha sido destruido. (if (!mounted) return;)
      if (!mounted) return;
      setState(() {
        _obteniendoConfig = resultado['OK'] != 1;
        _notificarAccesos = resultado['valor'] == '1';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Mis accesos'),
      body: _creaBody(),
    );
  }

  Widget _creaBody() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            _creaSwitchNotifAccesos(),
            _creaListaVehiculos(),
            Expanded(child: _cargaListadoAccesos()),
            _creaBannerIconos()
          ],
        ),
      ),
    );
  }

  Widget _creaSwitchNotifAccesos() {
    return ListTile(
      title: Text(
        'Notificar mis accesos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(_obteniendoConfig
          ? ''
          : _notificarAccesos
              ? 'Activado'
              : 'Desactivado'),
      trailing: CupertinoSwitch(
          value: _notificarAccesos,
          onChanged: _obteniendoConfig
              ? null
              : (valor) => _cambiarNotifAccesos(valor)),
    );
  }

  _cambiarNotifAccesos(valor) async {
    creaDialogProgress(context, 'Configurando...');
    Map resultado = await _configUsuarioProvider.configurarOpc(
        _prefs.usuarioLogged, 3, valor);
    Navigator.of(context).pop('dialog');
    setState(() {
      _notificarAccesos = resultado['OK'] == 1 ? valor : _notificarAccesos;
      //   Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
      //       Icon(resultado['OK'] == 1 ? Icons.notifications_active : Icons.error),
      //       resultado['message'],
      //       5));
    });
  }

  Widget _creaListaVehiculos() {
    return Container();
  }

  Widget _cargaListadoAccesos() {
    return DynamicList.build(
        key: _key,
        dataRequester: _dataRequester,
        initRequester: _initRequester,
        itemBuilder: (List dataList, BuildContext context, int index) {
          if (dataList.length > 0)
            return Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: _crearItem(context, dataList[index], index));
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
    return ElevatedContainer(
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
                  : utils.colorToastRechazada,
              size: 40,
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(acceso.tipoAcceso == '2' ? 'Persona' : 'Vehiculo',
                    style: utils.estiloTituloTarjeta(14)),
                Text(
                    acceso.tipoAcceso == '2'
                        ? acceso.nombreAcceso
                        : '${acceso.marca} ${acceso.modelo} ${acceso.color}',
                    style: utils.estiloSubtituloTarjeta(17)),
                Visibility(
                    visible: acceso.tipoAcceso != '2',
                    child:
                        Text('Placas', style: utils.estiloTituloTarjeta(14))),
                Visibility(
                    visible: acceso.tipoAcceso != '2',
                    child: Text('${acceso.placas}',
                        style: utils.estiloSubtituloTarjeta(17))),
                SizedBox(height: 5),
                Text(
                    acceso.tipoAcceso == '2'
                        ? 'Acceso con rostro'
                        : 'Acceso con tag',
                    style: utils.estiloTituloTarjeta(14)),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    '${utils.fechaCompleta(acceso.fechaAcceso)} ${acceso.horaAcceso}',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            color: utils.colorToastRechazada,
          ),
          Text('Salida')
        ])
      ],
    );
  }
}
