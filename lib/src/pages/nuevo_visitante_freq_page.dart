import 'package:dostop_v2/src/models/tipo_visitante_model.dart';
import 'package:dostop_v2/src/providers/config_usuario_provider.dart';
import 'package:dostop_v2/src/widgets/custom_qr.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imageTools;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'package:dostop_v2/src/providers/login_validator.dart';
import 'package:dostop_v2/src/providers/visitantes_frecuentes_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

import 'package:flutter/material.dart';
import 'dart:io';

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
                _crearTextNombre('Nombre(s)', 'Ej. Luis'),
                _crearTextApellidoP('Apellido paterno', 'Ej. Fernández'),
                _crearTextApellidoM('Apellido materno', 'Ej. Herrera'),
                SizedBox(height: 5.0),
                _crearListaTipoVisitante(),
                const SizedBox(height: 15.0),
                _crearListaTipoQr(),
                Visibility(
                  visible: _seleccionTipoInvite == 'parco',
                  child: const SizedBox(height: 5.0)),
                Visibility(
                  visible: _seleccionTipoInvite == 'parco',
                  child: _crearTextTelefono('Teléfono', '4775872189')),
                Visibility(
                  visible: _seleccionTipoInvite == 'parco',
                  child: SizedBox(height: 5.0)),
                Visibility(
                  visible: _seleccionTipoInvite == 'parco',
                  child: _crearListaVigencia()),
                SizedBox(height: 15.0),
                _creaAvisoBoton()
              ],
            ),
          ),
        ),
      ),
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

  Widget _crearTextNombre(String label, String hint) {
    return TextFormField(
      controller: _txtNombreCtrl,
      maxLength: 30,
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
        contentPadding: const EdgeInsets.all(0)
      ),
      onFieldSubmitted: (valor) {
        FocusScope.of(context).requestFocus(sigFocusText);
      },
      validator: (texto) {
        if (utils.textoVacio(texto))
          return 'Ingresa el nombre';
        else
          return null;
      },
    );
  }

  Widget _crearTextApellidoP(String label, String hint) {
    return TextFormField(
      controller: _txtApPatCtrl,
      maxLength: 20,
      focusNode: sigFocusText,
      enabled: !_registrando,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-ZÀ-ÿ -]+'))
      ],
      onEditingComplete: FocusScope.of(context).unfocus,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        contentPadding: const EdgeInsets.all(0)
      ),
      onFieldSubmitted: (valor) {
        FocusScope.of(context).requestFocus(sigFocusText2);
      },
      validator: (texto) {
        if (utils.textoVacio(texto))
          return 'Ingresa el apellido paterno';
        else
          return null;
      },
    );
  }

  Widget _crearTextApellidoM(String label, String hint) {
    return TextFormField(
      controller: _txtApMatCtrl,
      maxLength: 20,
      focusNode: sigFocusText2,
      enabled: !_registrando,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-ZÀ-ÿ -]+'))
      ],
      onEditingComplete: FocusScope.of(context).unfocus,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        contentPadding: const EdgeInsets.all(0)
      ),
      validator: (texto) {
        if (utils.textoVacio(texto))
          return 'Ingresa el apellido materno';
        else
          return null;
      },
    );
  }

  Widget _crearTextTelefono(String label, String hint) {
    return IntlPhoneField(
      controller: _txtTelefono,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9]+'))
      ],
      searchText: 'Buscar país/región',
      maxLength: 10,
      decoration: InputDecoration(
        labelText: label, 
        hintText: hint,
        contentPadding: const EdgeInsets.all(0)),
      initialCountryCode: 'MX',
      autoValidate: false,
      keyboardAppearance: Theme.of(context).brightness,
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
            {'text': 'QR Dostop', 'value': 'dostop'}
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

    //NO OLVIDAR REMOVER EL COMENTARIO - ESTA DISPONIBLE EN NUEVAS VERSIONES DE SDK DE FLUTTER >= 1.12.13H5
    // return IgnorePointer(
    //   ignoring: _registrando,
    //   child: DropdownButton(
    //     focusNode: FocusNode(), <- ESTA ES LA LINEA DE CODIGO QUE CAMBIA
    //     isExpanded: true,
    //     value: _seleccionVigencia,
    //     items: getOpcionesDropdown(),
    //     onChanged: (opc) {
    //       setState(() {
    //         _seleccionVigencia = opc;

    //       });
    //     },
    //   ),
    // );
  }

  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    return [
      DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(Icons.access_time),
            SizedBox(
              width: 10,
            ),
            Text('1 Hora'),
          ],
        ),
        value: '1',
      ),
      DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(Icons.access_time),
            SizedBox(
              width: 10,
            ),
            Text('24 Horas'),
          ],
        ),
        value: '2',
      ),
      DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(Icons.access_time),
            SizedBox(
              width: 10,
            ),
            Text('1 Semana'),
          ],
        ),
        value: '3',
      ),
      DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(Icons.access_time),
            SizedBox(
              width: 10,
            ),
            Text('1 Mes'),
          ],
        ),
        value: '4',
      ),
      DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(Icons.av_timer),
            SizedBox(
              width: 10,
            ),
            Text('Indefinido'),
          ],
        ),
        value: '5',
      ),
    ];
  }

  Widget _creaSwitchUnicaOc() {
    return Column(
      children: <Widget>[
        SwitchListTile(
          title: Text('Código de única ocasión',
              style: TextStyle(
                fontSize: 20,
              )),
          activeColor: utils.colorPrincipal,
          value: _esCodigoUnico,
          onChanged: _bloqueaUnicaOcasion
              ? null
              : (valor) {
                  setState(() {
                    _esCodigoUnico = valor;
                  });
                },
        ),
        Visibility(
          child: Text(
              '* Los códigos de unica ocasión no pueden durar más de una semana de vigencia'),
          visible: _bloqueaUnicaOcasion,
        ),
      ],
    );
  }

  Widget _creaAvisoBoton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(_seleccionTipoInvite == 'parco' ? 'Invitar con Parco son códigos dinámicos'
        ' que el visitante podrá consultar desde su cuenta de Parco vinculada al teléfono.' :
            'QR Dostop son códigos de única ocasión que tendrán una vigencia 24hrs.'),
        const SizedBox(height: 10),
        Text('El tiempo de validez comienza a partir de seleccionar "Crear invitación"',
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
    sigFocusText.dispose();
    sigFocusText2.dispose();
  }
}
