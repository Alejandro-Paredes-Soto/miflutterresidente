import 'package:dostop_v2/src/providers/areas_comunes_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter/material.dart';

class AreasComunesPage extends StatefulWidget {
  @override
  _AreasComunesPageState createState() => _AreasComunesPageState();
}

class _AreasComunesPageState extends State<AreasComunesPage> {
  AreaComunModel _seleccionArea;
  bool _reservando = true;
  CalendarController _calendarController;
  AreasComunesProvider _areasComunesProvider;
  final _prefs = PreferenciasUsuario();
  List<String> _fechasNoDispsList = List();
  Future<List<AreaReservadaModel>> _areasResevadasFuture;
  Future<List<AreaComunModel>> _areasComunesFuture;
  final _scrollController = ScrollController();
   final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _areasComunesProvider = AreasComunesProvider();
    _areasComunesFuture =
        _areasComunesProvider.obtenerListadoAreas(_prefs.usuarioLogged);
    _areasResevadasFuture =
        _areasComunesProvider.obtenerMisReservas(_prefs.usuarioLogged);
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      key:_scaffoldKey,
      appBar: utils.appBarLogo(titulo: 'Áreas Comunes'),
      body: _creaBody(),
    );
  }

  Widget _creaBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          _creaListadoAreas(),
          _creaCalendario(),
          _creaBtnReservar(),
          SizedBox(height: 20),
          _creaListadoReservasActivas(),
        ],
      ),
    );
  }

  Widget _creaListadoAreas() {
    return FutureBuilder(
      future: _areasComunesFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<AreaComunModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return DropdownButton<AreaComunModel>(
              hint: Text('Seleccione'),
              isExpanded: true,
              items: getOpcionesDropdown(snapshot.data),
              value: _seleccionArea,
              onChanged: (AreaComunModel opc) {
                setState(() {
                  _reservando = true;
                });
                _seleccionArea = opc;
                _areasComunesProvider
                    .obtenerReservasCalendario(
                        _prefs.usuarioLogged, _seleccionArea.idAreasComunes)
                    .then((reservas) {
                  setState(() {
                    _fechasNoDispsList = reservas;
                    _reservando = false;
                  });
                });
              },
            );
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 22.0),
              child: Text('No hay áreas comunes disponibles'),
            );
          }
        } else {
          return Padding(
            padding:  EdgeInsets.symmetric(vertical: 22.0),
            child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(utils.colorPrincipal) ,backgroundColor: Theme.of(context).scaffoldBackgroundColor,),
          );
        }
      },
    );
  }

    List<DropdownMenuItem<AreaComunModel>> getOpcionesDropdown(List<AreaComunModel> list) {
    return list.map((AreaComunModel item) {
      return DropdownMenuItem(
        child: Text(item.nombre),
        value: item,
      );
    }).toList();
  }

  Widget _creaCalendario() {
    return Container(
      child: TableCalendar(
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
          weekendStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color)),
        availableCalendarFormats: {CalendarFormat.month: 'mes'},
        calendarController: _calendarController,
        locale: 'es-MX',
        startDay: DateTime.now(),
        endDay: DateTime.now().add(Duration(days: 182)),
        calendarStyle: CalendarStyle(
          weekendStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
          selectedColor: utils.colorPrincipal,
          todayColor: utils.colorSecundarioSemi,
          outsideDaysVisible: false,
        ),
        // builders:
        //     CalendarBuilders(markersBuilder: (context, date, events, holidays) {
        //   final children = <Widget>[];
        //   if (holidays.isNotEmpty) {
        //     children.add(
        //       Positioned(
        //         right: -2,
        //         top: -2,
        //         child: _buildHolidaysMarker(),
        //       ),
        //     );
        //   }
        //   return children;
        // }),
        // holidays: _bloquearAreasReservadas(),
        enabledDayPredicate: (date) {
          return !_fechasNoDispsList
              .contains(DateFormat('yyyy-MM-dd').format(date));
        },
        onUnavailableDaySelected: () {
          _scaffoldKey.currentState.showSnackBar(utils.creaSnackBarIcon(
              Icon(Icons.sentiment_dissatisfied), 'Fecha no disponible', 1));
        },
      ),
    );
  }

  Widget _creaBtnReservar() {
    return RaisedButton(
      color: utils.colorPrincipal,
      disabledColor: utils.colorSecundario,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: Text(
          'Reservar',
          style: utils.estiloBotones(15),
        ),
      ),
      onPressed: _reservando
          ? null
          : () {
              if (_seleccionArea.idAreasComunes!='') {
                if (!_fechasNoDispsList.contains(DateFormat('yyyy-MM-dd')
                    .format(_calendarController.selectedDay))) {
                  creaDialogYesNo(
                      context,
                      'Confirma tu reserva',
                      '¿Confirmas la reserva de ${_seleccionArea.nombre} para '
                          '${utils.fechaCompletaFuturo(_calendarController.selectedDay, articuloDef: 'el')}?\n\nCuando confirmes, '
                          'le llegará una notificación a tu administración, la cual será la encargada de reservar tu fecha.',
                      'Sí',
                      'No',
                      () => _confirmarArea(),
                      () => Navigator.pop(context));
                } else
                  creaDialogSimple(
                      context,
                      '¡Ups!',
                      'La fecha que intentas reservar no esta disponible',
                      'OK',
                      () => Navigator.pop(context));
              }
            },
    );
  }

  _confirmarArea() async {
    setState(() {
      _reservando = true;
    });
    Navigator.pop(context);
    creaDialogProgress(context, 'Enviando solicitud');
    Map resultado = await _areasComunesProvider.reservarAreaComun(
        _prefs.usuarioLogged,
        _calendarController.selectedDay.toIso8601String(),
        _seleccionArea.idAreasComunes);
    Navigator.pop(context);
    setState(() {
      _reservando = false;
      _scaffoldKey.currentState.showSnackBar(utils.creaSnackBarIcon(
          Icon(resultado['OK'] ? Icons.send : Icons.error),
          resultado['message'],
          5));
      _areasResevadasFuture =
          _areasComunesProvider.obtenerMisReservas(_prefs.usuarioLogged);
    });
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Widget _creaListadoReservasActivas() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Mis reservas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          height: 300,
          child: _listadoReservas(),
        ),
      ],
    );
  }

  _listadoReservas() {
    return FutureBuilder(
        future: _areasResevadasFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<AreaReservadaModel>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return Scrollbar(
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return _creaItemReservas(snapshot.data[index]);
                    }),
              );
            } else {
              return Text('No tienes ninguna reserva');
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _creaItemReservas(AreaReservadaModel reserva) {
    return ListTile(
        title: Text(reserva.nombre),
        subtitle: Text(utils.fechaCompletaFuturo(reserva.fecha)),
        trailing: Container(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Icon(
                  Icons.place,
                  color: getColorReserva(reserva.estatus),
                  size: 32,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                reserva.estatus,
                softWrap: false,
                style: TextStyle(
                  color: getColorReserva(reserva.estatus),
                ),
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ));
  }

  Color getColorReserva(String estatus) {
    switch (estatus) {
      case 'Pendiente':
        return Colors.amber;
      case 'Rechazada':
        return Colors.red;
      case 'Confirmada':
        return utils.colorAcentuado;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _calendarController.dispose();
    _scrollController.dispose();
    _fechasNoDispsList.clear();
  }
}
