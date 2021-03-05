import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dostop_v2/src/providers/login_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _txtUserCtrl = TextEditingController();
  final _txtPassCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final loginProvider = LoginProvider();
  bool _iniciando = false;
  final sigFocusText = FocusNode();
  //int _item=0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          rutaFondoLogin,
          fit: BoxFit.fitHeight,
        ),
        Positioned.fill(
          child: Scaffold(
            //resizeToAvoidBottomInset: false,
            backgroundColor: colorFondoLoginSemi,
            appBar: _creaAppBar(),
            body: Container(
                padding: EdgeInsets.all(10), child: _contenidoLogin()),
          ),
        )
      ],
    );
  }

  Widget _contenidoLogin() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Dostop',
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(
                fontFamily: 'Play', fontSize: 40, color: colorPrincipal),
          ),
          Row(
            children: <Widget>[
              Text('Protegemos ',
                  style: TextStyle(fontFamily: 'Play', color: Colors.white)),
              TyperAnimatedTextKit(
                text: ['tu hogar', 'a tu familia', 'lo que más importa'],
                pause: Duration(seconds: 2),
                speed: Duration(milliseconds: 100),
                textStyle: TextStyle(fontFamily: 'Play', color: Colors.white),
                isRepeatingAnimation: false,
                //totalRepeatCount: 3,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 40.0),
                  Text(
                    'Inicio de Sesión',
                    style: estiloBotones(24),
                  ),
                  SizedBox(height: 40.0),
                  _crearTextUsuario('Usuario', 'mail@ejemplo.com'),
                  SizedBox(height: 20.0),
                  _crearTextPassword('Contraseña', 'Contraseña de la cuenta'),
                  SizedBox(height: 20.0),
                  _crearBotonLogin(),
                  SizedBox(height: 20.0),
                  _crebaBotonForgPass(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _creaAppBar() {
    return AppBar(
      brightness: Brightness.dark,
      elevation: 0,
      backgroundColor: Colors.transparent,
      // title: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     Text(
      //       'Dostop',
      //       softWrap: false,
      //       overflow: TextOverflow.visible,
      //       style: TextStyle(
      //           fontFamily: 'Play', fontSize: 40, color: colorPrincipal),
      //     ),
      //     Hero(
      //       tag: 'd',
      //       // child: SvgPicture.asset(
      //       //   rutaLogoDostopD,
      //       //   fit: BoxFit.cover,
      //       //   height: 32,
      //       // ),
      //       child: Container(
      //         height: 32,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _crearTextUsuario(String label, String hint) {
    return TextFormField(
      style: TextStyle(color: colorFondoPrincipalDark),
      enabled: !_iniciando,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ]'))],
      controller: _txtUserCtrl,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: colorTextLoginSemi,
        border: UnderlineInputBorder(borderRadius: BorderRadius.circular(15)),
        hintText: hint,
        labelText: label,
      ),
      onFieldSubmitted: (valor) {
        FocusScope.of(context).requestFocus(sigFocusText);
      },
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

  Widget _crearTextPassword(String label, String hint) {
    return TextFormField(
      style: TextStyle(color: colorFondoPrincipalDark),
      enabled: !_iniciando,
      focusNode: sigFocusText,
      controller: _txtPassCtrl,
      obscureText: true,
      decoration: InputDecoration(
        border: UnderlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: colorTextLoginSemi,
        hintText: hint,
        labelText: label,
      ),
      validator: (texto) {
        if (textoVacio(texto)) return 'Escribe tu contraseña';
        return null;
      },
    );
  }

  Widget _crearBotonLogin() {
    return MaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      height: 50,
      highlightElevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorPrincipal)),
            visible: _iniciando,
          ),
          SizedBox(width: 10),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              _iniciando ? 'Iniciando Sesión...' : 'Iniciar Sesión',
              style: estiloBotones(18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      color: colorPrincipal,
      disabledColor: colorSecundario,
      onPressed: _iniciando ? null : _submit,
    );
  }

  void _submit() {
    if (!formKey.currentState.validate())
      return;
    else {
      formKey.currentState.save();

      setState(() => _iniciando = true);
      _login();
    }
    FocusScope.of(context).unfocus();
  }

  void _login() async {
    Map estatus =
        await loginProvider.login(_txtUserCtrl.text, _txtPassCtrl.text);
    switch (estatus['OK']) {
      case 1:
        await _navegarAHome();
        Navigator.pushReplacementNamed(context, 'main');
        break;
      case 2:
        creaDialogSimple(
            context,
            'Atención',
            'El usuario y/o contraseña no son correctos.\nVerifica tu información por favor.',
            'Aceptar',
            () => Navigator.pop(context));
        break;
      case 3:
        creaDialogSimple(context, '¡Ups! Algo salió mal', estatus['message'],
            'Aceptar', () => Navigator.pop(context));
        break;
    }
    setState(() => _iniciando = false);
  }

  _navegarAHome() async {
    Map estatus =
        await loginProvider.registrarTokenFCM(obtenerIDPlataforma(context));
    switch (estatus['OK']) {
      case 0:
        print(estatus['message']);
        break;
      case 1:
        print(estatus['message']);
        break;
      case 2:
        print(estatus['message']);
        break;
      case 3:
        print(estatus['message']);
        break;
    }
  }

  Widget _crebaBotonForgPass() {
    return ButtonTheme(
      height: 50,
      minWidth: double.infinity,
      child: FlatButton(
        colorBrightness: Brightness.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Align(
          child: Text(
            'Olvidé mi contraseña',
            style: estiloBotones(18),
          ),
          alignment: Alignment.centerLeft,
        ),
        onPressed: _iniciando
            ? null
            : () {
                Navigator.of(context).pushNamed('resetUser');
              },
      ),
    );
  }

  @override
  void dispose() {
    _txtUserCtrl.dispose();
    _txtPassCtrl.dispose();
    super.dispose();
  }
}
