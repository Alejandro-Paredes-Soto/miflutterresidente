import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:pagination_view/pagination_view.dart';

class VisitasPage extends StatefulWidget {
  @override
  _VisitasPageState createState() => _VisitasPageState();
}

class _VisitasPageState extends State<VisitasPage> {
  late int page;
  late PaginationViewType paginationViewType;
  late GlobalKey<PaginationViewState> key;
  late ScrollController scrollController;
  final _prefs = PreferenciasUsuario();
  final visitasProvider = VisitasProvider();
  String _fechaTemp = '', _fechaInicio = '', _fechaFinal = '';
  bool _habilitaBtn = false, _filtrado = false;
  String initData = '';
  double opacidad = 1.0;
  @override
  void initState() {
    super.initState();

    paginationViewType = PaginationViewType.listView;
    key = GlobalKey<PaginationViewState>();
    scrollController = ScrollController();
  
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => scrollController.addListener(() {
              setState(() {
                if (scrollController.position.userScrollDirection ==
                    ScrollDirection.reverse)
                  opacidad = 0.0;
                else
                  opacidad = 1.0;
              });
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Historial'),
      body: Stack(
        children: [
          Positioned(child: _cargaVisitas()),
          _elementosBuscador(),
        ],
      ),
      //floatingActionButton: _creaFAB(),
    );
  }

  Widget _elementosBuscador() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: opacidad,
      child: IgnorePointer(
        ignoring: opacidad == 0,
        child: Container(
          height: 260,
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30),
              GestureDetector(
                  child: _creaCampoFecha(
                    _fechaInicio == '' ? 'Desde' : _fechaInicio,
                  ),
                  onTap: _filtrado
                      ? null
                      : () async {
                          _fechaInicio = await _selectDate(context,
                                  fechaFinal: DateTime.tryParse(
                                      formatoFechaBusqueda(_fechaFinal))) ??
                              _fechaInicio;
                          setState(() {
                            if (_fechaInicio != '' && _fechaFinal != '')
                              _habilitaBtn = true;
                          });
                        }),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                  child: _creaCampoFecha(
                    _fechaFinal == '' ? 'Hasta' : _fechaFinal,
                  ),
                  onTap: _filtrado
                      ? null
                      : () async {
                          _fechaFinal = await _selectDate(context,
                                  fechaInicial: DateTime.tryParse(
                                      formatoFechaBusqueda(_fechaInicio))) ??
                              _fechaFinal;
                          setState(() {
                            if (_fechaInicio != '' && _fechaFinal != '')
                              _habilitaBtn = true;
                          });
                        }),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: utils.colorAcentuado,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                ),
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 60,
                  child: Text(!_filtrado ? 'Filtrar' : 'Quitar filtro',
                      style: utils.estiloBotones(15)),
                ),
                onPressed: _habilitaBtn
                    ? () {
                        _filtrarVisitas();
                        setState(() {});
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _creaCampoFecha(
    String contenido,
  ) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(contenido,
                    style: TextStyle(
                        fontSize: 16,
                        color: contenido.contains(RegExp('Desde|Hasta'))
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodyText2!.color)),
                Icon(
                  Icons.calendar_today,
                  size: 35,
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1.5,
          )
        ],
      ),
    );
  }

  Future<String?> _selectDate(BuildContext context,
      {DateTime? fechaInicial, DateTime? fechaFinal}) async {
    DateTime? picked = await showDatePicker(
        context: context,
        firstDate: fechaInicial ?? new DateTime.now().subtract(Duration(days: 365)),
        initialDate: fechaFinal ?? new DateTime.now(),
        lastDate: fechaFinal ?? new DateTime.now(),
        locale: Locale('es', 'MX'),
        builder: (context, widget) {
          return Theme(
            data: ThemeData(
                primaryColor: utils.colorCalendario,
                primarySwatch: utils.colorCalendario,
                //accentColor: utils.colorSecundario
                ),
            child: widget!,
          );
        });
    if (picked != null) {
      _fechaTemp = picked.toString();
      return formatoFechaVista(_fechaTemp);
    }
    return null;
  }

  Widget _cargaVisitas() {
    return PaginationView(
        key: Key(initData),
        scrollController: scrollController,
        itemBuilder: (BuildContext context, VisitaModel visit, int index) {
          if (index == 0) {
            return Container(
                padding: const EdgeInsets.only(top: 260, bottom: 20),
                child: _crearItem(context, visit, index));
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _crearItem(context, visit, index),
            );
          }
        },
        pullToRefresh: true,
        pageFetch: _dataRequester,
        onEmpty: const Center(
          child: Text('No se encontraron visitas'),
        ),
        onError: (dynamic error) => const Center(
              child: Text('Some error occured'),
            ));
  }

  Future<List<VisitaModel>> _dataRequester(int offset) async {
    page = (offset / 10).ceil() + 1;
    List<VisitaModel> list = await visitasProvider.buscarVisitasXFecha(
        _prefs.usuarioLogged,
        _fechaInicio.isEmpty
            ? ''
            : formatoFechaBusqueda(_fechaInicio),
        _fechaFinal.isEmpty
            ? ''
            : formatoFechaBusqueda(_fechaFinal),
        page);
    return list;
  }

  Widget _crearItem(BuildContext context, VisitaModel visita, int index) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedContainer(
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              _cargaImagenesVisita(
                  visita.idVisitas,
                  utils.validaImagenes(
                      [visita.imgRostro, visita.imgId, visita.imgPlaca])),
              Container(
                  padding: EdgeInsets.only(left: 10, bottom: 40),
                  child: Hero(
                    tag: visita.idVisitas + visita.visitante,
                    child: Text(
                      '${visita.visitante}',
                      style: utils.estiloTextoSombreado(18),
                      overflow: TextOverflow.fade,
                    ),
                  )),
              Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                  width: double.infinity,
                  height: 25,
                  child: Text(
                    '${utils.fechaCompleta(DateTime.tryParse(visita.fechaEntrada))} ${visita.horaEntrada}',
                    style: utils.estiloTextoSombreado(11),
                    overflow: TextOverflow.fade,
                  ))
            ],
          ),
        ),
      ),
      onTap: () => _abrirVisitaDetalle(visita, context),
    );
  }

  Widget _cargaImagenesVisita(String id, List<String> imagenes) {
    if (imagenes.length == 0) {
      return Container(
        height: 230,
        child: Center(child: Icon(Icons.broken_image)),
      );
    } else {
      return Container(
          height: 230,
          child: Hero(
            tag: id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Swiper(
                loop: imagenes.length > 1 ? true : false,
                scrollDirection: Axis.horizontal,
                containerHeight: 130,
                pagination: imagenes.length > 1
                    ? SwiperPagination(
                        alignment: Alignment.topCenter,
                        builder: DotSwiperPaginationBuilder(
                            color: Colors.white60,
                            activeColor: Colors.white60,
                            activeSize: 20.0))
                    : null,
                itemCount: imagenes.length,
                itemBuilder: (BuildContext context, int index) {
                  return CachedNetworkImage(
                    placeholder: (context, url) =>
                        Image.asset(utils.rutaGifLoadRed),
                    errorWidget: (context, url, error) => Container(
                        height: 200,
                        child: Center(child: Icon(Icons.broken_image))),
                    imageUrl: imagenes[index],
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 300),
                  );
                  // return Image(image: NetworkImage(imagenes[index]),);
                },
              ),
            ),
          ));
    }
  }

  String formatoFechaBusqueda(String? fecha) {
    if (fecha != null && fecha.isNotEmpty)
      return DateFormat('yyyy-MM-dd')
          .format(DateFormat("dd-MM-yyyy").parse(fecha));
    else
      return '';
  }

  String formatoFechaVista(String fechaRaw) {
    return DateFormat('dd-MM-yyyy')
        .format(DateFormat('yyyy-MM-dd').parse(fechaRaw));
  }

  void _filtrarVisitas() {
    if (!_filtrado) {
      initData = 'refresh';
      _filtrado = true;
    } else {
      initData = '';
      _filtrado = false;
      _habilitaBtn = false;
      _fechaInicio = '';
      _fechaFinal = '';
      _fechaTemp = '';
    }
  }

  _abrirVisitaDetalle(VisitaModel visita, BuildContext context) {
    Navigator.of(context).pushNamed('VisitaDetalle', arguments: visita);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
