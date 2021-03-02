import 'package:dostop_v2/src/providers/emergencia_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergenciasPage extends StatelessWidget {
  final _emergenciasProvider = EmergenciaProvider();
  final _prefs = PreferenciasUsuario();
  @override
  Widget build(BuildContext context) {
    //final _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: utils.appBarLogo(titulo:'Emergencias'),
      body: _crearBotonesEmergencia(context),
    );
  }

  Widget _crearBotonesEmergencia(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                height: 200,
                alignment: Alignment.center,
                child: Text(
                  'Pedir apoyo a caseta de vigilancia',
                  style: utils.estiloBotones(30),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () => _confirmaApoyoCaseta(context),
              color: utils.colorPrincipal,
            ),
            SizedBox(
              height: 20,
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                alignment: Alignment.center,
                height: 200,
                width: double.infinity,
                child: Text(
                  'Llamar al 911',
                  style: utils.estiloBotones(30),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () => _llama911(),
              color: utils.colorPrincipal,
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  _confirmaApoyoCaseta(BuildContext context) {
    creaDialogYesNo(
        context,
        'Confirmar',
        'Se enviará una alerta de emergencia. El guardia recibirá una notificación inmediata de tu domicilio.\n\n¿Deseas continuar?',
        'Continuar',
        'Cancelar', () {
      _apoyoCaseta(context);
      Navigator.pop(context);
    }, () => Navigator.pop(context));
  }

  _apoyoCaseta(BuildContext context) async {
    Map estatus =
        await _emergenciasProvider.pedirApoyoCaseta(_prefs.usuarioLogged);
    if (estatus['OK'])
      Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
          SvgPicture.asset(utils.rutaIconoEmergencia, height: utils.tamanoIcoSnackbar, color: Colors.white),
          'Se envió la alerta a caseta correctamente',
          5));
    else
    Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
          Icon(Icons.error_outline),
          'No se pudo enviar la notificación',
          5));
  }

  _llama911() async {
    const url = 'tel:911';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('No se pudo llamar a $url');
    }
  }
}
