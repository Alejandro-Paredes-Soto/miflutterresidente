import 'dart:io';

import 'package:dostop_v2/src/models/visita_model.dart';
import 'package:dostop_v2/src/providers/reporte_incidente_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter_svg/svg.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

class VisitaDetallePage extends StatefulWidget {
  @override
  _VisitaDetallePageState createState() => _VisitaDetallePageState();
}

class _VisitaDetallePageState extends State<VisitaDetallePage> {
  final ReportesProvider _reportesProvider = ReportesProvider();
  final _prefs = PreferenciasUsuario();
  AppBar appBar;
  double availableHeight;
  List imagenes = [];
  bool loadImg = false;

  @override
  void initState() {
    super.initState();
    imagenes = [];
  }

  @override
  Widget build(BuildContext context) {
    appBar = utils.appBarLogo(titulo: 'Visita');
    final VisitaModel _visita = ModalRoute.of(context).settings.arguments;
    availableHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    if (Platform.isIOS) {
      availableHeight =
          availableHeight == 492 ? (availableHeight - 15) : availableHeight;
    }

    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Visita'),
      body: Platform.isIOS
          ? _creaBody(_visita, context)
          : LayoutBuilder(
              builder: (context, constraints) {
                availableHeight = constraints.maxHeight - 20;
                return _creaBody(_visita, context);
              },
            ),
      floatingActionButton:
          _cargaFABIncidente(context, [_visita.idVisitas, _visita.visitante]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _creaBody(VisitaModel visita, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Stack(
        children: <Widget>[
          imagenes.length == 0
              ? FutureBuilder(
                  future: utils.validaImagenesOrientacion(
                      [visita.imgRostro, visita.imgId, visita.imgPlaca]),
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.hasData) {
                      imagenes = snapshot.data;
                      return _imagenesVisitante(
                          visita.idVisitas, snapshot.data, visita);
                    } else {
                      return Stack(children: [
                        Image.asset(utils.rutaGifLoadRed,
                            alignment: Alignment.center),
                        _datosVisita(visita)
                      ]);
                    }
                  })
              : _imagenesVisitante(visita.idVisitas, imagenes, visita),
        ],
      ),
    );
  }

  Widget _imagenesVisitante(String id, List<Map> imagenes, VisitaModel visita) {
    if (imagenes.length == 0)
      return Column(
        children: [
          Stack(
            children: [
              Container(
                height: 240,
                child: Center(child: Text('No hay imagenes para mostrar')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _fechaVisita(visita),
              )
            ],
          ),
          _datosVisitante(visita, context)
        ],
      );
    else
      return Column(
        children: <Widget>[
          Hero(
            tag: id,
            child: Container(
              height: availableHeight,
              child: Swiper(
                  loop: false,
                  itemHeight: 240,
                  itemCount: imagenes.length,
                  pagination: imagenes.length > 1
                      ? SwiperPagination(
                          margin: EdgeInsets.all(2),
                          alignment: Alignment.topCenter,
                          builder: DotSwiperPaginationBuilder(
                              color: Colors.white60,
                              activeColor: Colors.white60,
                              activeSize: 20.0))
                      : null,
                  scale: 0.85,
                  itemBuilder: (BuildContext context, int index) {
                    bool isVertical = imagenes[index]['isVertical'];
                    return isVertical
                        ? Stack(
                            children: [
                              _imgOrientacion(context, availableHeight,
                                  imagenes[index]['img']),
                              _datosVisita(visita),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(children: [
                              Stack(
                                children: [
                                  _imgOrientacion(
                                      context, 240, imagenes[index]['img']),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: _fechaVisita(visita),
                                  )
                                ],
                              ),
                              Text(
                                  'Mantén presionada cualquier imagen para guardarla en tu galería.'),
                              _datosVisitante(visita, context)
                            ]),
                          );
                  }),
            ),
          ),
        ],
      );
  }

  Widget _fechaVisita(VisitaModel visita) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          visita.fechaEntrada.isNotEmpty && visita.fechaEntrada != null
              ? '${utils.fechaCompleta(DateTime.tryParse(visita.fechaEntrada))} ${visita.horaEntrada}'
              : '',
          style: utils.estiloTextoSombreado(20, dobleSombra: false),
        ),
        const SizedBox(height: 10),
        Visibility(
          visible: visita.fechaSalida.isNotEmpty && visita.fechaSalida != null,
          child: Text(
            'Salida: ${utils.fechaCompleta(DateTime.tryParse(visita.fechaSalida))} ${visita.horaSalida}',
            style: utils.estiloTextoSombreado(16, dobleSombra: false, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _datosVisita(VisitaModel visita) {
    return Column(
      children: [
        Container(
          height: availableHeight,
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fechaVisita(visita),
              Expanded(child: _datosVisitante(visita, context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imgOrientacion(
      BuildContext context, double availableHeight, String img) {
    return Column(
      children: [
        GestureDetector(
          child: PinchZoomImage(
            image: Container(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: availableHeight,
                  alignment: Alignment.topCenter,
                  placeholder: (context, url) => Image.asset(
                      utils.rutaGifLoadRed,
                      alignment: Alignment.topCenter),
                  errorWidget: (context, url, error) => Container(
                      height: 240,
                      child: Center(child: Icon(Icons.broken_image))),
                  imageUrl: img,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 0),
                  placeholderFadeInDuration: Duration(milliseconds: 0),
                ),
              ),
            ),
          ),
          onLongPress: () {
            HapticFeedback.vibrate();
            utils.descargaImagen(context, img);
          },
        ),
      ],
    );
  }

  Widget _datosVisitante(VisitaModel visita, BuildContext context) {
    final colorIcon = getColorEstatus(visita.estatus);
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          visita.codigo != ''
              ? Container(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SvgPicture.asset(
                      utils.rutaIconoVisitantesFrecuentes,
                      height: utils.tamanoIcoNavBar,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ],
                ))
              : Container(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(colorIcon['icono'],
                        color: colorIcon['color'], size: 22),
                    SizedBox(width: 2),
                    Text('${visita.estatus}',
                        style: utils.estiloTextoSombreado(18,
                            dobleSombra: false, color: colorIcon['color'])),
                  ],
                )),
          SizedBox(height: 5),
          Text('Nombre', style: utils.estiloTituloInfoVisita(12)),
          Text(visita.visitante,
              style: utils.estiloTextoSombreado(18, dobleSombra: false)),
          SizedBox(height: 10),
          Text('Placas', style: utils.estiloTituloInfoVisita(12)),
          Text(visita.placa,
              style: utils.estiloTextoSombreado(18, dobleSombra: false)),
          SizedBox(height: 10),
          Text('Vehículo', style: utils.estiloTituloInfoVisita(12)),
          Text(visita.modelo,
              style: utils.estiloTextoSombreado(18, dobleSombra: false)),
          SizedBox(height: 10),
          Text('Marca', style: utils.estiloTituloInfoVisita(12)),
          Text(visita.marca,
              style: utils.estiloTextoSombreado(18, dobleSombra: false)),
          SizedBox(height: 10),
          Text('Tipo', style: utils.estiloTituloInfoVisita(12)),
          Text(visita.tipoVisitante == '' ? 'Visita': visita.tipoVisitante,
              style: utils.estiloTextoSombreado(18, dobleSombra: false)),
          SizedBox(height: 10),
          Text(visita.codigo == '' ? 'Motivo' : '',
              style: utils.estiloTituloInfoVisita(12)),
          Text(visita.codigo == '' ? visita.motivoVisita : '',
              style: utils.estiloTextoSombreado(18, dobleSombra: false)),
          SizedBox(height: 80)
        ],
      ),
    );
  }

  Widget _cargaFABIncidente(BuildContext context, List<String> datos) {
    return FutureBuilder(
        future: _reportesProvider.obtenerReporte(
            idUsuario: _prefs.usuarioLogged, idVisita: datos[0]),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.containsKey('OK')) {
              switch (snapshot.data['OK']) {
                case 1:
                  ReporteModel reporte = snapshot.data['datos'];
                  return _creaFAB(reporte, null);
                case 2:
                  return _creaFAB(null, datos);
                default:
                  return Container();
              }
            } else {
              return Container();
            }
          } else {
            return FloatingActionButton(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(utils.colorPrincipal)),
                onPressed: null);
          }
        });
  }

  Widget _creaFAB(ReporteModel reporte, List<String> datos) {
    return RaisedButton(
        color: utils.colorPrincipal,
        child: Container(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(reporte == null ? Icons.report : Icons.chat,
                  color: Colors.white),
              SizedBox(width: 10),
              Container(
                  child: Text(
                reporte == null ? 'Reportar incidente' : 'Ver reporte',
                style: utils.estiloBotones(15),
              )),
            ],
          ),
        ),
        onPressed: () => reporte == null
            ? _abrirReportePage(context, datos)
            : Navigator.of(context)
                .pushNamed('SeguimientoInc', arguments: reporte),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)));
  }

  _abrirReportePage(BuildContext context, List<String> datos) async {
    final result =
        await Navigator.of(context).pushNamed('Incidente', arguments: datos) ??
            false;
    if (result) setState(() {});
  }
}

Map<String, dynamic> getColorEstatus(String estatus) {
  switch (estatus) {
    case 'Aceptada':
      return {'icono': Icons.check_circle, 'color': utils.colorAcentuado};
    case 'Rechazada':
      return {'icono': Icons.cancel, 'color': Colors.red};
    default:
      return {'icono': Icons.remove_circle, 'color': Colors.grey};
  }
}
