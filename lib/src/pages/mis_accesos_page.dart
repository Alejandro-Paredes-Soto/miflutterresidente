import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dostop_v2/src/providers/config_usuario_provider.dart';
import 'package:dostop_v2/src/providers/mis_accesos_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:pagination_view/pagination_view.dart';

import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

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
  late int page;
  late PaginationViewType paginationViewType;
  late GlobalKey<PaginationViewState> key;

  @override
  void initState() {
    super.initState();
    paginationViewType = PaginationViewType.listView;
    key = GlobalKey<PaginationViewState>();
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
    });
  }

  Widget _creaListaVehiculos() {
    return Container();
  }

  Future<List<AccesoModel>> _dataRequester(int offset) async {
    page = (offset / 10).ceil() + 1;
    List<AccesoModel> list =
        await _accesosProvider.obtenerAccesos(_prefs.usuarioLogged, page);
    return list;
  }

  Widget _cargaListadoAccesos() {
    return PaginationView(
        key: _key,
        itemBuilder: (BuildContext context, AccesoModel acceso, int index) {
          return Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: _crearItem(context, acceso, index));
        },
        pullToRefresh: true,
        pageFetch: _dataRequester,
        onEmpty: const Center(
          child: Text('No se encontraron accesos'),
        ),
        onError: (dynamic error) => const Center(
              child: Text('Some error occured'),
            ));
  }

  Widget _crearItem(BuildContext context, AccesoModel acceso, int index) {
    return ElevatedContainer(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
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
          Visibility(
            visible: acceso.rutaImg != "",
            child: PinchZoomImage(
              image: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                    height: 130,
                    width: 75,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Image.asset(utils.rutaGifLoadRed),
                    imageUrl: acceso.rutaImg,
                    errorWidget: (context, url, error) =>
                        Icon(Icons.broken_image)),
              ),
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
