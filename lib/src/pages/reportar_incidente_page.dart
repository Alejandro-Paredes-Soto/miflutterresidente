import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/providers/reporte_incidente_provider.dart';

import 'package:flutter/material.dart';



class ReportarIncidentePage extends StatefulWidget {
  const ReportarIncidentePage({Key key}) : super(key: key);

  @override
  _ReportarIncidentePageState createState() => _ReportarIncidentePageState();
}

class _ReportarIncidentePageState extends State<ReportarIncidentePage> {
  
  bool _registrando=false;
  final formKey = GlobalKey<FormState>();
  final _txtIncidenteCtrl = TextEditingController();
  final reportesProvider = ReportesProvider();
  String _idVisita;
  final _prefs = PreferenciasUsuario();
  
  @override
  Widget build(BuildContext context) {
    final List<String> _datosVisita = ModalRoute.of(context).settings.arguments;
    _idVisita=_datosVisita[0];
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Reportar'),
      body: _creaBody(context, _datosVisita[1]),
    );
  }

  _creaBody(BuildContext context, String nombreVisitante) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
      children: <Widget>[
        Text('Escribe el problema que tuviste con la visita de $nombreVisitante',style: TextStyle(fontSize: 20),),
        SizedBox(height: 20),
        _creaTextIncidente(context,'Comentarios', 'Ej. No conozco a la persona.'),
        SizedBox(height: 20),
        _creaBtnEnviar()
      ],
    ));
  }

   Widget _creaTextIncidente(BuildContext context, String label, String hint) {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: _txtIncidenteCtrl,
        style: TextStyle(fontSize: 18),
        maxLines:6,
        enabled: !_registrando,
        onEditingComplete: FocusScope.of(context).unfocus,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        maxLength: 250,
        decoration: InputDecoration(
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15)
        ),
          hintText: hint,
          labelText: label,
        ),
        validator: (texto) {
          if (utils.textoVacio(texto))
            return 'Escribe el problema por favor';
          else
            return null;
        },
      ),
    );
   }

  _creaBtnEnviar() {
    return RaisedButton(
          color: utils.colorPrincipal,
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
                      valueColor: AlwaysStoppedAnimation<Color>(utils.colorPrincipal),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    _registrando ? 'Enviando reporte...' : 'Enviar reporte',
                    style: utils.estiloBotones(15),
                  ),
                ],
              )),
          onPressed: _registrando ? null : _submit,
        );
  }

   void _submit() {
    if (!formKey.currentState.validate())
      return;
    else {
      formKey.currentState.save();

      setState(() => _registrando = true);
      _enviaReporte();
    }
    // FocusScope.of(context).unfocus();
  }

  void _enviaReporte() async{
     Map estatus = await reportesProvider.enviaReporteIncidente(
        idUsuario: _prefs.usuarioLogged,
        reporte: _txtIncidenteCtrl.text,
        idVisita: _idVisita,);
    switch (estatus['OK']) {
      case 1:
        Navigator.pop(context, true);
        break;
      case 2:
        creaDialogSimple(context, '¡Ups! Algo salió mal','',
            'Aceptar', () { Navigator.pop(context);
        Navigator.pop(context, false);});
        break;
  }
  setState(() => _registrando = false);
  }
}