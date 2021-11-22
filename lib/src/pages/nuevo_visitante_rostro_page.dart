import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:dostop_v2/src/providers/visitantes_frecuentes_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image/image.dart' as imgTools;

class NuevoVisitanteRostroPage extends StatefulWidget {
  @override
  _NuevoVisitanteRostroPageState createState() =>
      _NuevoVisitanteRostroPageState();
}

class _NuevoVisitanteRostroPageState extends State<NuevoVisitanteRostroPage> {
  final _prefs = PreferenciasUsuario();
  final _visitantesFreqProvider = VisitantesFreqProvider();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _txtNombreCtrl = TextEditingController();
  final _txtApPatCtrl = TextEditingController();
  final _txtApMatCtrl = TextEditingController();
  final visitanteProvider = VisitantesFreqProvider();
  String _seleccionTipoAcceso;
  bool _registrando = false;
  bool _imagenLista = false, _mostrarErrorImg = false;
  bool _mostrarErrorAcceso = false;
  bool _visitanteRegistrado = false;
  File _imgRostro;
  int _tipoRostro = 0;

  @override
  Widget build(BuildContext context) {
    _tipoRostro = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      key: _scaffoldKey,
      appBar: utils.appBarLogo(
          titulo: 'Agregar',
          backbtn: BackButton(
            onPressed: () {
              if (!_registrando) {
                Navigator.pop(context, _visitanteRegistrado);
              }
            },
          )),
      body: _creaBody(),
    );
  }

  Widget _creaBody() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _creaTitulo(),
              _creaCampoNombre('Nombre(s)', 'Ej. Luis'),
              _creaCampoApellidoPat('Apellido paterno', 'Ej. Fernández'),
              _creaCampoApellidoMat('Apellido materno', 'Ej. Herrera'),
              _crearListaTipoAcceso(),
              _creaTextoErrorAcceso(),
              SizedBox(height: 10.0),
              _creaBtnAgregaImagen(),
              _creaTextoErrorImg(),
              SizedBox(height: 10.0),
              _creaRecomendacionImg(),
              SizedBox(height: 10.0),
              _creaBtnRegistrar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _creaTitulo() {
    return Container(
      width: double.infinity,
      child: Text(
        _tipoRostro == 1
            ? 'Nuevo colono con rostro'
            : 'Nuevo visitante con rostro',
        textAlign: TextAlign.left,
        style: utils.estiloTextoAppBar(25),
      ),
    );
  }

  Widget _creaCampoNombre(String label, String hint) {
    return TextFormField(
      enabled: !_registrando,
      controller: _txtNombreCtrl,
      maxLength: 30,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-ZÀ-ÿ -]+'))
      ],
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
      ),
      validator: (texto) {
        if (utils.textoVacio(texto))
          return 'Ingresa el nombre';
        else
          return null;
      },
    );
  }

  Widget _creaCampoApellidoPat(String label, String hint) {
    return TextFormField(
      enabled: !_registrando,
      controller: _txtApPatCtrl,
      maxLength: 20,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-ZÀ-ÿ -]+'))
      ],
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
      ),
      validator: (texto) {
        if (utils.textoVacio(texto))
          return 'Ingresa el apellido paterno';
        else
          return null;
      },
    );
  }

  Widget _creaCampoApellidoMat(String label, String hint) {
    return TextFormField(
      enabled: !_registrando,
      controller: _txtApMatCtrl,
      maxLength: 20,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-ZÀ-ÿ -]+'))
      ],
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
      ),
      validator: (texto) {
        if (utils.textoVacio(texto))
          return 'Ingresa el apellido materno';
        else
          return null;
      },
    );
  }

  Widget _crearListaTipoAcceso() {
    return IgnorePointer(
      ignoring: _registrando,
      child: Listener(
        onPointerDown: (_) => FocusScope.of(context).unfocus(),
        child: DropdownButton(
          isExpanded: true,
          value: _seleccionTipoAcceso,
          hint: Text('Tipo de acceso'),
          underline: Container(
            height: 1,
            color: _mostrarErrorAcceso ? utils.colorToastRechazada : Theme.of(context).disabledColor,
          ),
          items: getOpcionesDropdown(),
          onChanged: (opc) {
            setState(() {
              _seleccionTipoAcceso = opc;
            });
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    return [
      DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(Icons.directions_walk),
            SizedBox(width: 10),
            Text('Peatonal'),
          ],
        ),
        value: '1',
      ),
      DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(Icons.directions_car_sharp),
            SizedBox( width: 10),
            Text('Vehicular'),
          ],
        ),
        value: '2',
      ),
      DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(Icons.vpn_key),
            SizedBox(width: 10),
            Text('Vehicular y Peatonal'),
          ],
        ),
        value: '3',
      )
    ];
  }

  Widget _creaBtnAgregaImagen() {
    return GestureDetector(
      onTap: _registrando ? null : _mostrarOpcImagen,
      child: ElevatedContainer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 200,
            height: 250,
            child: AnimatedCrossFade(
              crossFadeState: _imagenLista
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 500),
              firstChild: Center(
                child: Icon(
                  Icons.add_a_photo,
                  size: 40.0,
                ),
              ),
              secondChild: _imagenLista
                  ? Container(
                      width: double.infinity,
                      child: Image.file(
                        _imgRostro,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(),
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarOpcImagen() {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                    child: Text(
                      'Tomar fotografía',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).iconTheme.color),
                      textScaleFactor: 1.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop('dialog');
                      obtenerImagen(picker.ImageSource.camera);
                    }),
                CupertinoActionSheetAction(
                    child: Text(
                      'Escoger de la galería',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).iconTheme.color),
                      textScaleFactor: 1.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop('dialog');
                      obtenerImagen(picker.ImageSource.gallery);
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textScaleFactor: 1.0,
                ),
              ),
            ));
  }

  void obtenerImagen(picker.ImageSource source) async {
    try {
      if (Platform.isAndroid) {
        if (!await utils.obtenerPermisosAndroid()) throw 'permission_denied';
      }
      var imgFile = await picker.ImagePicker.pickImage(
          source: source, maxHeight: 1024, maxWidth: 768, imageQuality: 50);
      if (imgFile != null) {
        var fixedImg = await fixExifRotation(imgFile.path);
        var img = await decodeImageFromList(fixedImg.readAsBytesSync());
        if (img.height > img.width) {
          _imgRostro = fixedImg;
          setState(() {
            _imagenLista = true;
          });
        } else {
          _scaffoldKey.currentState.showSnackBar(utils.creaSnackBarIcon(
              Icon(Icons.error), 'La imagen no está en formato vertical', 2));
        }
        print(await imgFile.length());
      }
    } on PlatformException catch (e) {
      //buscamos el error. Si contiene el texto photo_access_deined de los permisos de android
      // o directamente de la plataforma ios cambiamos el mensaje.
      String mensajeError = '';
      if (e.code.toString().contains('photo_access_denied'))
        mensajeError = 'Otorga el permiso de almacenamiento por favor';
      else if (e.code.toString().contains('camera_access_denied'))
        mensajeError = 'Otorga el permiso de la cámara por favor';
      _scaffoldKey.currentState.showSnackBar(utils.creaSnackBarIcon(
          Icon(Icons.error),
          'Ocurrió un error al procesar la imagen. $mensajeError',
          2));
    } catch (e) {
      String mensajeError = '';
      if (e.toString().contains('permission_denied'))
        mensajeError = 'Otorga los permisos correspondientes.';
      else
        mensajeError = e.toString();
      _scaffoldKey.currentState.showSnackBar(utils.creaSnackBarIcon(
          Icon(Icons.error),
          'Ocurrió un error al procesar la imagen. $mensajeError',
          2));
    }
  }

  Future<File> fixExifRotation(String imagePath) async {
    final originalFile = File(imagePath);
    final imgTools.Image capturedImage =
        imgTools.decodeImage(await originalFile.readAsBytes());
    final imgTools.Image orientedImage =
        imgTools.bakeOrientation(capturedImage);
    await originalFile
        .writeAsBytes(imgTools.encodeJpg(orientedImage, quality: 50));
    return originalFile;
  }

  Widget _creaTextoErrorImg() {
    return Visibility(
      visible: _mostrarErrorImg,
      child: Text(
        '* Selecciona o toma una fotografía',
        style: TextStyle(color: utils.colorPrincipal),
      ),
    );
  }

  Widget _creaTextoErrorAcceso() {
    return Visibility(
      visible: _mostrarErrorAcceso,
      child: Container(
        width: double.infinity,
        child: Text(
          'Selecciona el tipo de acceso',
          style: TextStyle(color: utils.colorToastRechazada, fontSize: 12.0),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _creaRecomendacionImg() {
    return Text(
      'Por favor, usa una imagen en formato vertical. No usar lentes o algún accesorio que pueda cubrir parte del rostro.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _creaBtnRegistrar() {
    return RaisedButton(
        color: utils.colorAcentuado,
        disabledColor: utils.colorSecundario,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
            height: 60,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: _registrando,
                  child: CircularProgressIndicator(
                    backgroundColor: utils.colorSecundario,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(utils.colorPrincipal),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  'Agregar visitante',
                  style: utils.estiloBotones(15),
                )
              ],
            )),
        onPressed: _registrando ? null : _submitForm);
  }

  _submitForm() {
    if (_formKey.currentState.validate() && _seleccionTipoAcceso != null
        && _imgRostro != null) {
        _formKey.currentState.save();
        _mostrarErrorImg = false;
        _mostrarErrorAcceso = false;
        _registrando = true;
        _registrarAcceso();
    }else{
      if(_seleccionTipoAcceso == null)
        _mostrarErrorAcceso = true;
      else 
        _mostrarErrorAcceso = false;

      if(_imgRostro == null)
        _mostrarErrorImg = true;
      else
        _mostrarErrorImg = false;
    }
    
    setState(() {});
  }

  void _registrarAcceso() async {
    Map estatus = await _visitantesFreqProvider.nuevoAccesoRostro(
      idUsuario: _prefs.usuarioLogged,
      nombre: _txtNombreCtrl.text,
      apPaterno: _txtApPatCtrl.text,
      apMaterno: _txtApMatCtrl.text,
      tipoAcceso: _seleccionTipoAcceso,
      imgRostroB64: base64Encode(_imgRostro.readAsBytesSync()),
      tipo: _tipoRostro,
    );
    switch (estatus['OK']) {
      case 1:
        //
        setState(() {
          _visitanteRegistrado = true;
        });
        Navigator.pop(context, _visitanteRegistrado);
        break;
      case 2:
        creaDialogSimple(
            context, '¡Ups! Algo salió mal', estatus['message'], 'Aceptar', () {
          Navigator.of(context).pop('dialog');
          Navigator.pop(context, _visitanteRegistrado);
        });
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _txtNombreCtrl.dispose();
    _txtApPatCtrl.dispose();
    _txtApMatCtrl.dispose();
  }
}
