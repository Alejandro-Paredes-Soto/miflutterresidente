import 'package:dostop_v2/src/models/visita_model.dart';
import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dynamic_list_view/dynamic_list.dart';
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
  final _scrollControllerSliver = ScrollController();

  DynamicListController _dynamicListController = DynamicListController();
  final _prefs = PreferenciasUsuario();
  final visitasProvider = VisitasProvider();
  String _fechaTemp = '', _fechaInicio = '', _fechaFinal = '';
  bool _habilitaBtn = false, _filtrado = false;
  Future<List<VisitaModel>> _visitasProvider;
  int _pag = 1;
  final _key = GlobalKey();
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
                if (opacidad >0) opacidad -= 0.001;
              });
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Visitas'),
      body: Stack(
        children: [
          Positioned(child: _cargaVisitas()),
          _elementosBuscador(),
        ],
      ),
      //floatingActionButton: _creaFAB(),
    );
  }

  Widget _creaBuscador(bool boxIsScrolled) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      title: Text('Visitas'),
      expandedHeight: 240,
      elevation: 0.0,
      centerTitle: false,
      floating: true,
      forceElevated: boxIsScrolled,
      bottom: PreferredSize(
          child: _elementosBuscador(), preferredSize: Size.fromHeight(150)),
    );
  }

  Widget _elementosBuscador() {
    return Opacity(
      opacity: opacidad,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 240,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: <Widget>[
            InkWell(
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
            InkWell(
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
              color: utils.colorPrincipal,
              disabledColor: utils.colorSecundario,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                child: Text(!_filtrado ? 'Filtrar' : 'Quitar filtro',
                    style: utils.estiloBotones(18)),
              ),
              onPressed: _habilitaBtn
                  ? () {
                      // cacheData = [];
                      _filtrarVisitas();
                      setState(() {});
                    }
                  : null,
            ),
            SizedBox(
              height: 20,
            )
          ],
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
                Icon(Icons.calendar_today),
              ],
            ),
          ),
          Divider(
            thickness: 2,
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
                splashColor: Colors.green,
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
        key: _key,
        controller: _dynamicListController,
        dataRequester: _dataRequester,
        initRequester: _initRequester,
        itemBuilder: (List dataList, BuildContext context, int index) {
          if (dataList.length > 0)
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
              elevation: 4,
              child: Column(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: <Widget>[
                      _cargaImagenesVisita(
                          visita.idVisitas,
                          utils.validaImagenes([
                            visita.imgRostro,
                            visita.imgId,
                            visita.imgPlaca
                          ])),
                      Container(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: Hero(
                            tag: visita.idVisitas + visita.visitante,
                            child: Text(
                              '${visita.visitante}',
                              style: utils.estiloTextoBlancoSombreado(18),
                              overflow: TextOverflow.fade,
                            ),
                          )),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                        color: utils.colorPrincipal),
                    width: double.infinity,
                    height: 25,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '${utils.fechaCompleta(DateTime.tryParse(visita.fechaEntrada))} ${visita.horaEntrada}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
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
        height: 200,
        child: Center(child: Icon(Icons.broken_image)),
      );
    } else {
      return Container(
          height: 200,
          child: Hero(
            tag: id,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Swiper(
                loop: imagenes.length > 1 ? true : false,
                scrollDirection: Axis.horizontal,
                containerHeight: 130,
                pagination: imagenes.length > 1
                    ? SwiperPagination(
                        margin: EdgeInsets.all(2),
                        alignment: Alignment.topCenter)
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
      _key.currentState.didUpdateWidget(_key.currentWidget);
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
  }

  _abrirVisitaDetalle(VisitaModel visita, BuildContext context) {
    Navigator.of(context).pushNamed('VisitaDetalle', arguments: visita);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollControllerSliver.dispose();
  }

  Widget _creaFAB() {
    return FloatingActionButton(
      child: Icon(Icons.search),
      backgroundColor: utils.colorPrincipal,
      onPressed: () {
        // if (_scrollControllerSliver.position.pixels !=
        //     _scrollControllerSliver.position.maxScrollExtent) {
        //   _scrollControllerSliver.animateTo(
        //       _scrollControllerSliver.position.maxScrollExtent,
        //       curve: Curves.easeIn,
        //       duration: Duration(milliseconds: 300));
        // } else {
        //   _scrollControllerSliver.animateTo(
        //       _scrollControllerSliver.position.minScrollExtent,
        //       curve: Curves.easeIn,
        //       duration: Duration(milliseconds: 300));
        // }
        _dynamicListController.toTop();
      },
    );
  }
}
