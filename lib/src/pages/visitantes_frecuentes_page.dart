import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dostop_v2/src/providers/config_usuario_provider.dart';
import 'package:dostop_v2/src/widgets/custom_tabbar.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image/image.dart' as imageTools;
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_extend/share_extend.dart';

import 'package:dostop_v2/src/widgets/countdown_timer.dart';
import 'package:dostop_v2/src/models/visitante_freq_model.dart';
import 'package:dostop_v2/src/providers/visitantes_frecuentes_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class VisitantesFrecuentesPage extends StatefulWidget {
  @override
  _VisitantesFrecuentesPageState createState() =>
      _VisitantesFrecuentesPageState();
}

class _VisitantesFrecuentesPageState extends State<VisitantesFrecuentesPage> {
  final _prefs = PreferenciasUsuario();
  final visitanteProvider = VisitantesFreqProvider();
  final _configUsuarioProvider = ConfigUsuarioProvider();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tabIndex = 0;
  int _obteniendoConfig = 0;
  String _tipoServicio = '';
  Map<String, dynamic> _tipoAcceso;
  Timer timer;
  bool _dialogAbierto = false;

  @override
  void initState() {
    super.initState();
    _configUsuarioProvider
        .obtenerEstadoConfig(_prefs.usuarioLogged, 5)
        .then((resultado) {
      if (!mounted) return;
      setState(() {
        _tipoAcceso = resultado['valor'];
        print(resultado['valor']);
      });
    });

    _configUsuarioProvider
        .obtenerEstadoConfig(_prefs.usuarioLogged, 4)
        .then((resultado) {
      if (!mounted) return;
      setState(() {
        _obteniendoConfig = resultado['OK'];
        _tipoServicio = resultado['valor'];
      });
    });

    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      if (!_dialogAbierto && _tabIndex > 0) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: utils.appBarLogo(titulo: 'V. Frecuentes'),
      body: _creaBody(),
      floatingActionButton: _creaFABMultiple(context, _tipoServicio),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // bottomNavigationBar: _creaBoton(),
    );
  }

  Widget _creaTabs(String valor) {
    List<Widget> tabs = [
      Container(
          child: Text(
        'Visitantes\nQR',
        textAlign: TextAlign.center,
        style: utils.estiloBotones(15),
      )),
      Container(
          child: Text(
        'Visitantes\nRostros',
        textAlign: TextAlign.center,
        style: utils.estiloBotones(15),
      )),
      Container(
          child: Text(
        'Residentes\nRostros',
        textAlign: TextAlign.center,
        style: utils.estiloBotones(15),
      ))
    ];
    if (valor == '0') {
      tabs.removeLast();
      tabs.removeLast();
    }
    if (valor == '1') {
      tabs.removeAt(1);
    } else if (valor == '2') {
      tabs.removeAt(2);
    }
    return valor == '' || valor == '0'
        ? Container()
        : Container(
            height: 60,
            child: CustomTabBar(
              Theme.of(context).brightness == Brightness.dark
                  ? utils.colorFondoTabs
                  : utils.colorFondoPrincipalDark,
              utils.colorAcentuado,
              tabs,
              () => _tabIndex,
              (index) {
                setState(() {
                  _tabIndex = index;
                });
              },
              allowExpand: true,
              innerHorizontalPadding: 40,
              borderRadius: BorderRadius.circular(15.0),
            ),
          );
  }

  Widget _creaBody() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          _creaTabs(_tipoServicio),
          Expanded(
            child: _creaPagFrecuentes(),
            flex: 1,
          )
        ],
      ),
    );
  }

  Widget _creaPagFrecuentes() {
    return FutureBuilder(
      future: visitanteProvider.cargaVisitantesFrecuentes(
          _prefs.usuarioLogged, _tabIndex + 1),
      builder: (BuildContext context,
          AsyncSnapshot<List<VisitanteFreqModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return _creaListadoFrecuentes(snapshot.data);
        else
          return Center(
            child: CircularProgressIndicator(),
          );
      },
    );
  }

  Widget _creaListadoFrecuentes(List<VisitanteFreqModel> lista) {
    if (lista.length > 0) {
      return Container(
          child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 15),
        padding: EdgeInsets.only(top: 15.0),
        itemCount: lista.length,
        itemBuilder: (context, index) => _tabIndex == 0
            ? _crearItem(context, lista[index])
            : _crearItemRostro(context, lista[index]),
      ));
    } else {
      return Center(
        child: Text(
          'No hay registros por aqui',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget _crearItem(BuildContext context, VisitanteFreqModel visitante) {
    return ElevatedContainer(
      padding: EdgeInsets.all(15.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nombre', style: utils.estiloTituloTarjeta(12)),
                Text(
                  '${visitante.nombre}',
                  style: utils.estiloSubtituloTarjeta(15),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: visitante.tipoVisitante != '',
                  child: Text(
                    visitante.tipoVisitante == '1'
                        ? 'Visita'
                        : visitante.tipoVisitante == '2'
                            ? 'Proveedor'
                            : 'Empleado',
                  ),
                ),
                SizedBox(height: 10),
                Text(visitante.unico ? 'QR de única ocasión:' : 'Vence en:',
                    style: visitante.unico
                        ? TextStyle(
                            color: utils.colorAcentuado,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)
                        : utils.estiloTituloTarjeta(
                            12,
                          )),
                visitante.vigencia
                        .isBefore(DateTime.now().add(Duration(days: 31)))
                    ? CountdownTimer(
                        endTime: visitante.vigencia.millisecondsSinceEpoch,
                        defaultDays: '0',
                        defaultHours: '00',
                        defaultMin: '00',
                        defaultSec: '00',
                        daysSymbol: " dias ",
                        hoursSymbol: "h ",
                        minSymbol: "m ",
                        secSymbol: "s",
                        textStyle: utils.estiloSubtituloTarjeta(15),
                        onEnd: () => Future.delayed(
                            Duration(seconds: 2), () => setState(() {})),
                      )
                    : Text(
                        'Tiempo Indefinido',
                        style: utils.estiloSubtituloTarjeta(15),
                      ),
              ],
            ),
          ),
          Flexible(
            flex: 0,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: utils.colorPrincipal,
                    child: Container(
                      width: 100,
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        'Ver código',
                        style: utils.estiloBotones(12),
                      ),
                    ),
                    onPressed: () {
                      creaDialogQR(
                          _scaffoldKey.currentContext,
                          '',
                          _creaQR(visitante.codigo),
                          'Compartir',
                          'Cancelar',
                          () => _compartir(visitante.codigo),
                          () => Navigator.of(_scaffoldKey.currentContext)
                              .pop('dialog'));
                    },
                  ),
                  SizedBox(height: 15),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : utils.colorFondoPrincipalDark,
                    child: Container(
                        width: 100,
                        height: 50,
                        alignment: Alignment.center,
                        child: Text(
                          'Eliminar',
                          softWrap: false,
                          style: utils.estiloBotones(12,
                              color: Theme.of(context).scaffoldBackgroundColor),
                        )),
                    onPressed: () {
                      _eliminaVisitanteFreq(
                          _scaffoldKey.currentContext, visitante);
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _crearItemRostro(BuildContext context, VisitanteFreqModel visitante) {
    return ElevatedContainer(
      padding: EdgeInsets.all(10),
      child: Container(
        height: visitante.tipoVisitante != '' ? 158 : 138,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Image.asset(utils.rutaGifLoadRed),
                    imageUrl: visitante.urlImg,
                    errorWidget: (context, url, error) =>
                        Icon(Icons.broken_image)),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre', style: utils.estiloTituloTarjeta(11)),
                  Text(visitante.nombre,
                      style: utils.estiloSubtituloTarjeta(17)),
                  Visibility(
                      visible: visitante.tipoVisitante != '',
                      child: SizedBox(height: 5)),
                  Visibility(
                    visible: visitante.tipoVisitante != '',
                    child: Text(
                      visitante.tipoVisitante == '1'
                          ? 'Visita'
                          : visitante.tipoVisitante == '2'
                              ? 'Proveedor'
                              : 'Empleado',
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    visitante.tipoAcceso == '1'
                        ? 'Acceso peatonal'
                        : visitante.tipoAcceso == '2'
                            ? 'Acceso vehicular'
                            : 'Acceso vehicular-peatonal',
                  ),
                  SizedBox(height: 5),
                  Text('Estatus', style: utils.estiloTituloTarjeta(11)),
                  Row(
                    children: [
                      visitante.estatusDispositivo == '1' &&
                              visitante.activo == '1'
                          ? Icon(Icons.check_circle_outline,
                              color: utils.colorContenedorSaldo)
                          : Container(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator()),
                      SizedBox(width: 5),
                      Text(visitante.estatusDispositivo == '1'
                          ? visitante.activo == '0'
                              ? 'Eliminando...'
                              : 'Listo para usarse'
                          : 'Registrando...'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Visibility(
                      visible: visitante.estatusDispositivo == '0' ||
                          visitante.activo == '0',
                      child: AutoSizeText(
                        !visitante.expiroTolerancia
                            ? 'Esto puede tomar alrededor de 30 segundos.'
                            : 'El tiempo de espera está tomando mas de lo normal. Puede que en caseta ocurra una falla de internet.',
                        style: utils.estiloTituloTarjeta(12),
                        maxLines: 2,
                        minFontSize: 8,
                        wrapWords: false,
                      )),
                ],
              ),
            ),
            Visibility(
              visible: visitante.estatusDispositivo == '1' &&
                  visitante.activo == '1',
              child: Container(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    child: Icon(Icons.delete),
                    onTap: () => _eliminaVisitanteFreq(context, visitante),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget _creaQR(String codigo) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            height: 200,
            width: 200,
            child: QrImage(
              data: codigo,
              version: QrVersions.auto,
              size: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectableText(
              codigo,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  _compartir(String codigo) async {
    try {
      Directory dir = await pathProvider.getTemporaryDirectory();
      File imagenQR = new File("${dir.path}/${codigo}QR.png");
      if (await imagenQR.exists()) {
        imagenQR.delete();
      }
      await imagenQR.create(recursive: true);
      imagenQR.writeAsBytes(await toQrImageData(codigo));
      ShareExtend.share(imagenQR.path, Platform.isAndroid ? 'image' : 'file');
    } catch (e) {
      print('Ocurrió un error al compartir:\n $e');
    }
  }

  Future<List<int>> toQrImageData(String codigo) async {
    final imageqr = await QrPainter(
            data: codigo,
            version: QrVersions.auto,
            color: Colors.black,
            emptyColor: Colors.white,
            gapless: true)
        .toImageData(350);

    imageTools.Image image = imageTools.Image(450, 530);
    imageTools.fill(image, imageTools.getColor(255, 255, 255));
    imageTools.drawImage(
        image, imageTools.decodePng(imageqr.buffer.asUint8List()),
        dstX: 50, dstY: 40);
    imageTools.drawString(image, imageTools.arial_48, 112, 400, codigo,
        color: imageTools.getColor(0, 0, 0));
    imageTools.drawString(
        image, imageTools.arial_24, 60, 450, 'Presenta este QR en la entrada',
        color: imageTools.getColor(0, 0, 0));
    imageTools.drawString(
        image, imageTools.arial_24, 15, 470, '                    para acceder',
        color: imageTools.getColor(0, 0, 0));
    imageTools.drawString(
        image, imageTools.arial_24, 100, 500, '     www.dostop.mx',
        color: imageTools.getColor(0, 0, 0));

    return imageTools.encodeJpg(image);
  }

  void _eliminaVisitanteFreq(
      BuildContext context, VisitanteFreqModel visitante) {
    _dialogAbierto = true;
    creaDialogYesNoAlt(
        context,
        'Confirmar',
        '¿Estas seguro que deseas eliminar a \"${visitante.nombre}\'?\n\nEsta accíon es irreversible.',
        'Eliminar',
        'Cancelar', () async {
      Navigator.pop(context);
      Map estatus = await visitanteProvider.eliminaVisitanteFrecuente(
          visitante.idFrecuente, _prefs.usuarioLogged, _tabIndex + 1);
      switch (estatus['OK']) {
        case 1:
          setState(() {});
          Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
              Icon(Icons.delete), 'Visitante eliminado', 5));
          break;
        case 2:
          _dialogAbierto = false;
          Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
              Icon(Icons.error), 'No se pudo eliminar al visitante', 5));
          break;
      }
      _dialogAbierto = false;
    }, () {
      Navigator.pop(context);
      _dialogAbierto = false;
    });
  }

  Widget _creaFABMultiple(BuildContext context, String valor) {
    return _obteniendoConfig == 0
        ? FloatingActionButton(
            child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(utils.colorPrincipal)),
            onPressed: null)
        : _obteniendoConfig == 1
            ? SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                overlayColor: Theme.of(context).scaffoldBackgroundColor,
                overlayOpacity: 0.5,
                backgroundColor: utils.colorAcentuado,
                children: _obtenerElementosFAB(valor),
              )
            : Container();
  }

  List<SpeedDialChild> _obtenerElementosFAB(String valor) {
    List<SpeedDialChild> elementos = [
      _elementoFAB(
          titulo: 'Nuevo visitante QR',
          icon: Icon(Icons.qr_code),
          pageRoute: 'NuevoVisitFreq'),
      _elementoFAB(
          titulo: 'Nuevo visitante rostro',
          icon: Icon(Icons.person_add),
          pageRoute: 'NuevoVisitRostro',
          tipoRostro: 2,
          tipoAcceso: _tipoAcceso),
      _elementoFAB(
          titulo: 'Nuevo residente rostro',
          icon: Icon(Icons.home),
          pageRoute: 'NuevoVisitRostro',
          tipoRostro: 1,
          tipoAcceso: _tipoAcceso),
    ];
    if (valor == '0') {
      elementos.removeLast();
      elementos.removeLast();
    }
    if (valor == '1') {
      elementos.removeAt(1);
    } else if (valor == '2') {
      elementos.removeAt(2);
    }
    return valor == "" ? [] : elementos;
  }

  SpeedDialChild _elementoFAB(
      {String titulo,
      Widget icon,
      @required String pageRoute,
      int tipoRostro,
      Map tipoAcceso}) {
    return SpeedDialChild(
        child: Container(padding: EdgeInsets.all(10), child: icon),
        backgroundColor: utils.colorPrincipal,
        labelBackgroundColor: Theme.of(context).cardColor,
        label: titulo,
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () {
          _navegaPaginaRespuesta(context, pageRoute, tipoRostro, tipoAcceso);
        });
  }

  _navegaPaginaRespuesta(BuildContext context, String pageRoute, int tipoRostro,
      Map tipoAcceso) async {
    //Agregamos argumento para saber que tipo de pantalla de rostro mostrar, si el argumento se pasa
    //a otra pantalla este es ignorado
    final result = await Navigator.of(context)
            .pushNamed(pageRoute, arguments: [tipoRostro, tipoAcceso]) ??
        false;
    if (result) {
      setState(() {});
      Future.delayed(Duration(milliseconds: 500), () {
        _scaffoldKey.currentState.showSnackBar(utils.creaSnackBarIcon(
            SvgPicture.asset(utils.rutaIconoVisitantesFrecuentes,
                height: utils.tamanoIcoSnackbar,
                color: Theme.of(context).snackBarTheme.actionTextColor),
            tipoRostro == 1
                ? 'Acceso residente creado'
                : 'Visitante frecuente creado',
            5));
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
