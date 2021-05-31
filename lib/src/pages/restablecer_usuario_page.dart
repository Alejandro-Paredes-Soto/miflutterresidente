import 'package:dostop_v2/src/providers/restablecer_usuario_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RestablecerUsuarioPage extends StatefulWidget {
  @override
  _RestablecerUsuarioPageState createState() => _RestablecerUsuarioPageState();
}

class _RestablecerUsuarioPageState extends State<RestablecerUsuarioPage> {
  final formKeyRestPass = GlobalKey<FormState>();
  bool _enviando = false;
  final restableceUsrProvider = RestablecerUsuarioProvider();
  final _txtEmailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_enviando,
      child: Scaffold(
        appBar: _creaAppBar(),
        body: _creaBody(),
      ),
    );
  }

  Widget _creaAppBar() {
    return AppBar(
      leading: BackButton(),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Hero(
          //   tag: 'd',
          //   child: SvgPicture.asset(
          //     rutaLogoDostopD,
          //     fit: BoxFit.cover,
          //     height: 32,
          //   ),
          // ),
          // SizedBox(
          //   width: 20,
          // ),
          Flexible(
            child: Text(
              'Restablece tu contraseña',
              style: estiloTextoAppBar(16),
              overflow: TextOverflow.fade,
            ),
          )
        ],
      ),
    );
  }

  Widget _creaBody() {
    return Form(
      key: formKeyRestPass,
      child: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _crearAvisoContra(),
              SizedBox(height: 20),
              _crearTextCorreo(),
              SizedBox(height: 20),
              _crearBotonRest(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearAvisoContra() {
    return Text(
        'Te enviaremos un correo donde podrás restablecer la contraseña de tu cuenta.\n\nAl realizar esta acción, '
        'tendrás que iniciar sesión de nuevo en todos los dispositivos donde tienes tu cuenta activa. Y así seguir notificándote cuando tengas una nueva visita.',
        style: TextStyle(fontSize: 15),
        textAlign: TextAlign.center);
  }

  Widget _crearTextCorreo() {
    return TextFormField(
      controller: _txtEmailCtrl,
      enabled: !_enviando,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ]'))],
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail_outline),
        labelText: 'Correo electrónico asociado a la cuenta',
        hintText: 'mail@ejemplo.com',
      ),
      validator: (texto) {
        if (textoVacio(texto))
          return 'Ingresa tu correo electrónico';
        else if (!correoValido(texto))
          return 'El correo escrito no es válido';
        else
          return null;
      },
    );
  }

  Widget _crearBotonRest() {
    return MaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      height: 50,
      minWidth: double.infinity,
      highlightElevation: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorPrincipal)),
            visible: _enviando ? true : false,
          ),
          SizedBox(width: 10),
          Flexible(
            flex: 1,
            child: Text(
              _enviando
                  ? 'Enviando solicitud...'
                  : 'Solicitar nueva contraseña',
              style: estiloBotones(18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      color: colorPrincipal,
      disabledColor: colorSecundario,
      onPressed: _enviando ? null : _submit,
    );
  }

  void _submit() {
    if (!formKeyRestPass.currentState.validate())
      return;
    else {
      formKeyRestPass.currentState.save();
      FocusScope.of(context).unfocus();
      setState(() => _enviando = true);
      _accionRestablecer();
    }
  }

  void _accionRestablecer() async {
    Map estatus =
        await restableceUsrProvider.restablecerXEmail(_txtEmailCtrl.text);
    if (estatus['OK'])
      creaDialogSimple(
          context,
          'Correo enviado',
          'Se ha enviado un correo con las instrucciones.\n\n Si no lo ves en tu bandeja de entrada, '
              'te recomendamos revisar tu bandeja de Spam/Correo no deseado.\n\n¿No lo recibiste? Por favor inténtalo de nuevo en 3 minutos.',
          'Aceptar', () {
        Navigator.pop(context);
        Navigator.of(context).pop();
      });
    else
      creaDialogSimple(
          context,
          '¡Ups! Algo salió mal',
          'No se encontró una cuenta con el correo \'${_txtEmailCtrl.text}\'. verifica que esté escrito correctamente.',
          'Aceptar',
          () => Navigator.pop(context));
    setState(() => _enviando = false);
  }

  @override
  void dispose() {
    _txtEmailCtrl.dispose();
    super.dispose();
  }
}
