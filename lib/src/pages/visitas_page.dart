import 'package:dostop_v2/src/models/visita_model.dart';
import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dynamic_list_view/dynamic_list.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class VisitasPage extends StatefulWidget {
  @override
  _VisitasPageState createState() => _VisitasPageState();
}

class _VisitasPageState extends State<VisitasPage> {
  DynamicListController _dynamicListController = DynamicListController();
  final _prefs = PreferenciasUsuario();
  final visitasProvider = VisitasProvider();
  String _fechaTemp = '', _fechaInicio = '', _fechaFinal = '';
  bool _habilitaBtn = false, _filtrado = false;
  Future<List<VisitaModel>> _visitasProvider;
  int _pag = 1;
  double opacidad = 1.0;
  @override
  void initState() {
    super.initState();
    if (!_filtrado) {
      _visitasProvider =
          visitasProvider.buscarVisitasXFecha(_prefs.usuarioLogged, '', '', 1);
    }
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _dynamicListController.scrollController.addListener(() {
              setState(() {
                if (_dynamicListController
                        .scrollController.position.userScrollDirection ==
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
              SizedBox(height:30),
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
              RaisedButton(
                color: utils.colorAcentuado,
                disabledColor: utils.colorSecundario,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 60,
                  child: Text(!_filtrado ? 'Filtrar' : 'Quitar filtro',
                      style: utils.estiloBotones(15)),
                ),
                onPressed: _habilitaBtn
                    ? () {
                        // cacheData = [];
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
                            : Theme.of(context).textTheme.bodyText2.color)),
                Icon(Icons.calendar_today, size: 35,),
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

  Future<String> _selectDate(BuildContext context,
      {DateTime fechaInicial, DateTime fechaFinal}) async {
    DateTime picked = await showDatePicker(
        context: context,
        firstDate:
            fechaInicial ?? new DateTime.now().subtract(Duration(days: 365)),
        initialDate: fechaFinal ?? new DateTime.now(),
        lastDate: fechaFinal ?? new DateTime.now(),
        locale: Locale('es', 'MX'),
        builder: (context, widget) {
          return Theme(
            data: ThemeData(
                primaryColor: utils.colorCalendario,
                primarySwatch: utils.colorCalendario,
                accentColor: utils.colorSecundario),
            child: widget,
          );
        });
    if (picked != null) {
      _fechaTemp = picked.toString();
      return formatoFechaVista(_fechaTemp);
    }
    return null;
  }

  Widget _cargaVisitas() {
    return DynamicList.build(
        controller: _dynamicListController,
        dataRequester: _dataRequester,
        initRequester: _initRequester,
        itemBuilder: (List dataList, BuildContext context, int index) {
          if (dataList.length > 0) if (index == 0)
            return Container(
                padding: EdgeInsets.only(top: 260),
                child: _crearItem(context, dataList[index], index));
          else
            return _crearItem(context, dataList[index], index);
          else
            return Center(
              child: Text('No se encontraron visitas'),
            );
        });
  }

  Future<List> _dataRequester() async {
    _pag++;
    return await visitasProvider.buscarVisitasXFecha(
        _prefs.usuarioLogged,
        formatoFechaBusqueda(_fechaInicio),
        formatoFechaBusqueda(_fechaFinal),
        _pag);
  }

  Future<List> _initRequester() async {
    return Future.value(_visitasProvider);
  }

  _crearItem(BuildContext context, VisitaModel visita, int index) {
    return Column(
      children: <Widget>[
        GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
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
                          style: utils.estiloTextoBlancoSombreado(18),
                          overflow: TextOverflow.fade,
                        ),
                      )),
                  Container(
                    padding: EdgeInsets.only(right: 15, bottom: 10),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    width: double.infinity,
                    height: 25,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '${utils.fechaCompleta(DateTime.tryParse(visita.fechaEntrada))} ${visita.horaEntrada}',
                            style: utils.estiloTextoBlancoSombreado(11),
                            overflow: TextOverflow.fade,
                          )
                        ]),
                  )
                ],
              ),
            ),
          ),
          onTap: () => _abrirVisitaDetalle(visita, context),
        ),
        SizedBox(
          height: 10,
        )
      ],
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

  String formatoFechaBusqueda(String fecha) {
    if (fecha.isNotEmpty)
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
      _pag = 1;
      _visitasProvider = visitasProvider.buscarVisitasXFecha(
          _prefs.usuarioLogged,
          formatoFechaBusqueda(_fechaInicio),
          formatoFechaBusqueda(_fechaFinal),
          _pag);
      _filtrado = true;
    } else {
      _pag = 1;
      _visitasProvider = visitasProvider.buscarVisitasXFecha(
          _prefs.usuarioLogged, '', '', _pag);
      _filtrado = false;
      _habilitaBtn = false;
      _fechaInicio = '';
      _fechaFinal = '';
      _fechaTemp = '';
    }
    _dynamicListController.refresh();
  }

  _abrirVisitaDetalle(VisitaModel visita, BuildContext context) {
    Navigator.of(context).pushNamed('VisitaDetalle', arguments: visita);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
