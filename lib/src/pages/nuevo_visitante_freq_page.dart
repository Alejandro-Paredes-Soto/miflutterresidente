import 'package:dostop_v2/src/models/tipo_visitante_model.dart';
import 'package:dostop_v2/src/providers/config_usuario_provider.dart';
import 'package:dostop_v2/src/widgets/custom_qr.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:dostop_v2/src/providers/login_validator.dart';
import 'package:dostop_v2/src/providers/visitantes_frecuentes_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

import 'package:flutter/material.dart';

class NuevoVisitanteFrecuentePage extends StatefulWidget {
  @override
  _NuevoVisitanteFrecuentePageState createState() =>
      _NuevoVisitanteFrecuentePageState();
}

class _NuevoVisitanteFrecuentePageState
    extends State<NuevoVisitanteFrecuentePage> {
  String _seleccionVigencia = '1';
  String _seleccionTipoVisitante = '1';
  String _seleccionTipoInvite = 'parco';
  final formKey = GlobalKey<FormState>();
  final _txtNombreCtrl = TextEditingController();
  final _txtApPatCtrl = TextEditingController();
  final _txtApMatCtrl = TextEditingController();
  final _txtTelefono = TextEditingController();
  final focusText = FocusNode();
  final sigFocusText = FocusNode();
  final sigFocusText2 = FocusNode();
  final _prefs = PreferenciasUsuario();
  final visitanteProvider = VisitantesFreqProvider();
  final _validaSesion = LoginValidator();
  final _configUsuarioProvider = ConfigUsuarioProvider();
  bool _registrando = false;
  bool _visitanteRegistrado = false;
  bool _bloqueaCompartir = false;
  bool _esCodigoUnico = false;
  bool _bloqueaUnicaOcasion = false;
  String _codigo = '00000000';
  List<TipoVisitanteModel> tipoVisita = new List();
  List<DropdownMenuItem<String>> listTipo = new List();

  @override
  void initState() {
    super.initState();
    _configUsuarioProvider
        .obtenerEstadoConfig(_prefs.usuarioLogged, 6)
        .then((resultado) {
      if (!mounted) return;
      for (Map<String, dynamic> tipo in resultado['valor']) {
        final tempTipo = TipoVisitanteModel.fromJson(tipo);
        listTipo.add(DropdownMenuItem(
          child: Text(tempTipo.tipo),
          value: tempTipo.idTipoVisitante,
        ));
        tipoVisita.add(tempTipo);
      }

      setState(() {});
      _seleccionTipoVisitante = tipoVisita[0].idTipoVisitante;
    });
  }

  @override
  Widget build(BuildContext context) {
    _validaSesion.verificaSesion();
    return Scaffold(
      appBar: utils.appBarLogo(
          titulo: 'Agregar',
          backbtn: BackButton(
            onPressed: () {
              if (!_registrando) {
                if (_visitanteRegistrado)
                  Navigator.pop(context, true);
                else
                  Navigator.pop(context, false);
              }
            },
          )),
      body: AnimatedCrossFade(
        duration: Duration(milliseconds: 500),
        crossFadeState: _visitanteRegistrado
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: _creaBody(),
        secondChild: _creaBodyCompartir(),
      ),
    );
  }

  _creaBody() {
    return Visibility(
      visible: !_visitanteRegistrado,
      child: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _creaTitulo(),
                SizedBox(height: 10.0),
                _crearText(
                    controller: _txtNombreCtrl,
                    focus: focusText,
                    focusNext: sigFocusText,
                    label: 'Nombre(s)',
                    hint: 'Ej. Luis',
                    maxLength: 30,
                    textValidate: 'Ingresa el nombre'),
                _crearText(
                    controller: _txtApPatCtrl,
                    focus: sigFocusText,
                    focusNext: sigFocusText2,
                    label: 'Apellido paterno',
                    hint: 'Ej. Fernández',
                    maxLength: 20,
                    textValidate: 'Ingresa el apellido paterno'),
                _crearText(
                    controller: _txtApMatCtrl,
                    focus: sigFocusText2,
                    label: 'Apellido materno',
                    hint: 'Ej. Herrera',
                    maxLength: 20,
                    textValidate: 'Ingresa el apellido materno'),
                _crearListaTipoVisitante(),
                const SizedBox(height: 15.0),
                _crearListaTipoQr(),
                Visibility(
                    visible: _seleccionTipoInvite == 'parco',
                    child: _crearFieldParco()),
                SizedBox(height: 15.0),
                _creaAvisoBoton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearFieldParco() {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _crearTextTelefono('Teléfono', '4775872189'),
        SizedBox(height: 5.0),
        _crearListaVigencia(),
      ],
    );
  }

  _creaBodyCompartir() {
    return Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomQr(code: _codigo),
              SizedBox(height: 20),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  height: 60,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Compartir',
                        style: utils.estiloBotones(15),
                      )
                    ],
                  ),
                ),
                onPressed: _bloqueaCompartir
                    ? null
                    : () {
                        utils.compartir(_codigo);
                        setState(() {
                          _bloqueaCompartir = true;
                        });
                        Future.delayed(Duration(seconds: 2), () {
                          setState(() {
                            _bloqueaCompartir = false;
                          });
                        });
                      },
              ),
              SizedBox(height: 10),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  height: 60,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.arrow_back,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Regresar',
                        style: utils.estiloTextoAppBar(15),
                      )
                    ],
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ));
  }

  Widget _creaTitulo() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Nuevo Visitante Frecuente',
              textAlign: TextAlign.left, style: utils.estiloTextoAppBar(25)),
          SizedBox(height: 10),
          Text(
            'Es necesario ingresar la información completa del visitante.',
            style: utils.estiloTextoAppBar(16),
          )
        ]);
  }

  Widget _crearText(
      {TextEditingController controller,
      FocusNode focus,
      FocusNode focusNext,
      String label,
      String hint,
      String textValidate,
      int maxLength}) {
    return TextFormField(
      controller: controller,
      focusNode: focus,
      maxLength: maxLength,
      enabled: !_registrando,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-ZÀ-ÿ -]+'))
      ],
      textInputAction: TextInputAction.next,
      onEditingComplete: FocusScope.of(context).unfocus,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          contentPadding: const EdgeInsets.all(0)),
      onFieldSubmitted: (valor) {
        if (focusNext != null) FocusScope.of(context).requestFocus(focusNext);
      },
      validator: (texto) {
        if (utils.textoVacio(texto))
          return textValidate;
        else
          return null;
      },
    );
  }

  Widget _crearTextTelefono(String label, String hint) {
    return IntlPhoneField(
      controller: _txtTelefono,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]+'))],
      searchText: 'Buscar país/región',
      maxLength: 10,
      decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          contentPadding: const EdgeInsets.all(0)),
      initialCountryCode: 'MX',
      autoValidate: false,
      validator: (number) {
        if (utils.textoVacio(number))
          return 'Ingresa el teléfono';
        else
          return null;
      },
      onChanged: (phone) {
        print(phone.completeNumber);
      },
    );
  }

  Widget _crearListaTipoQr() {
    return IgnorePointer(
      ignoring: _registrando,
      child: Listener(
        onPointerDown: (_) => FocusScope.of(context).unfocus(),
        child: DropdownButton(
          isExpanded: true,
          value: _seleccionTipoInvite,
          items: _returnDropdownMenuItem([
            {'text': 'Invitar con Parco', 'value': 'parco'},
            {'text': 'QR de única ocasión', 'value': 'dostop'}
          ]),
          onChanged: (opc) {
            setState(() {
              _seleccionTipoInvite = opc;
            });
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _returnDropdownMenuItem(
      List<Map<String, dynamic>> listItems) {
    List<DropdownMenuItem<String>> listDropdownMenuItem = new List();

    for (var item in listItems) {
      listDropdownMenuItem.add(DropdownMenuItem(
        child: Text(item['text']),
        value: item['value'],
      ));
    }

    return listDropdownMenuItem;
  }

  Widget _crearListaTipoVisitante() {
    return IgnorePointer(
      ignoring: _registrando,
      child: Listener(
        onPointerDown: (_) => FocusScope.of(context).unfocus(),
        child: DropdownButton(
          isExpanded: true,
          value: _seleccionTipoVisitante,
          items: listTipo,
          onChanged: (opc) {
            setState(() {
              _seleccionTipoVisitante = opc;
            });
          },
        ),
      ),
    );
  }

  Widget _crearListaVigencia() {
    return IgnorePointer(
      ignoring: _registrando,
      child: Listener(
        onPointerDown: (_) => FocusScope.of(context).unfocus(),
        child: DropdownButton(
          isExpanded: true,
          value: _seleccionVigencia,
          items: getOpcionesDropdown(),
          onChanged: (opc) {
            setState(() {
              _seleccionVigencia = opc;
              if (int.parse(opc) > 3) {
                _bloqueaUnicaOcasion = true;
                _esCodigoUnico = false;
              } else
                _bloqueaUnicaOcasion = false;
            });
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    List<Map<String, dynamic>> listItems = [
      {'text': '1 Hora', 'value':'1'}, {'text': '24 Horas', 'value':'2'}, 
      {'text': '1 Semana', 'value':'3'}, {'text': '1 Mes', 'value':'4'},  
      {'text': 'Indefinido', 'value':'5'}, 
    ];
    List<DropdownMenuItem<String>> listDropdownMenuItem = new List();

    for (var item in listItems) {
      listDropdownMenuItem.add(DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(Icons.access_time),
            SizedBox(
              width: 10,
            ),
            Text(item['text']),
          ],
        ),
        value: item['value'],
      ));
    }

    return listDropdownMenuItem;
  }

  Widget _creaAvisoBoton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(_seleccionTipoInvite == 'parco'
            ? 'Invitar con Parco son códigos dinámicos'
                ' que el visitante podrá consultar desde su cuenta de Parco vinculada al teléfono.'
            : 'Los códigos de única ocasión tendrán una vigencia 24hrs.'),
        const SizedBox(height: 10),
        Text(
            'El tiempo de validez comienza a partir de seleccionar "Crear invitación"',
            style: utils.estiloTextoAppBar(16)),
        SizedBox(height: 10),
        RaisedButton(
          color: utils.colorAcentuado,
          disabledColor: utils.colorSecundario,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                    visible: _registrando,
                    child: CircularProgressIndicator(
                      backgroundColor: utils.colorSecundario,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(utils.colorPrincipal),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    _registrando ? 'Creando invitación...' : 'Crear invitación',
                    style: utils.estiloBotones(15),
                  ),
                ],
              )),
          onPressed: _registrando ? null : _submit,
        )
      ],
    );
  }

  void _submit() {
    if (!formKey.currentState.validate())
      return;
    else {
      formKey.currentState.save();

      setState(() => _registrando = true);
      _creaVisitante();
    }
    FocusScope.of(context).unfocus();
  }

  void _creaVisitante() async {
    Map estatus = await visitanteProvider.nuevoVisitanteFrecuente(
        idUsuario: _prefs.usuarioLogged,
        nombre: _txtNombreCtrl.text,
        apPaterno: _txtApPatCtrl.text,
        apMaterno: _txtApMatCtrl.text,
        vigencia: _seleccionVigencia,
        esUnico: _esCodigoUnico,
        tipoVisitante: _seleccionTipoVisitante);
    switch (estatus['OK']) {
      case 1:
        //
        setState(() {
          _visitanteRegistrado = true;
          _codigo = estatus['codigo'] ?? '00000000';
        });
        break;
      case 2:
        creaDialogSimple(context, '¡Ups! Algo salió mal', '', 'Aceptar', () {
          Navigator.pop(context);
          Navigator.pop(context, false);
        });
        break;
    }
    setState(() => _registrando = false);
  }

  @override
  void dispose() {
    super.dispose();
    _txtApMatCtrl.dispose();
    _txtApPatCtrl.dispose();
    _txtNombreCtrl.dispose();
    focusText.dispose();
    sigFocusText.dispose();
    sigFocusText2.dispose();
  }
}
