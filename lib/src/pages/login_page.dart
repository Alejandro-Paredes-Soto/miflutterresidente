import 'package:dostop_v2/src/providers/login_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/widgets/gradient_button.dart';
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
          utils.rutaFondoLogin,
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: Scaffold(
            //resizeToAvoidBottomInset: false,
            backgroundColor: utils.colorFondoLoginSemi,
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
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      utils.rutaLogoLetras2023,
                      height: 40,
                    ),
                    SizedBox(height: 40.0),
                    Text(
                      'Inicio de sesión',
                      style: utils.estiloBotones(25),
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
            ),
          )
        ],
      ),
    );
  }

  AppBar _creaAppBar() {
    return AppBar(
      //brightness: Brightness.dark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _crearTextUsuario(String label, String hint) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      enabled: !_iniciando,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ]'))],
      controller: _txtUserCtrl,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: utils.colorTextLoginSemi,
        border: UnderlineInputBorder(borderRadius: BorderRadius.circular(15)),
        hintText: hint,
        labelText: label,
        labelStyle: TextStyle(color: utils.colorTextoPrincipalDark),
        hintStyle: TextStyle(color: utils.colorTextoPrincipalDark),
      ),
      onFieldSubmitted: (valor) {
        FocusScope.of(context).requestFocus(sigFocusText);
      },
      validator: (texto) {
        if (utils.textoVacio(texto!))
          return 'Ingresa tu correo electrónico';
        else if (!utils.correoValido(texto))
          return 'El correo escrito no es válido';
        else
          return null;
      },
    );
  }

  Widget _crearTextPassword(String label, String hint) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      enabled: !_iniciando,
      focusNode: sigFocusText,
      controller: _txtPassCtrl,
      obscureText: true,
      decoration: InputDecoration(
        border: UnderlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: utils.colorTextLoginSemi,
        hintText: hint,
        labelText: label,
        labelStyle: TextStyle(color: utils.colorTextoPrincipalDark),
        hintStyle: TextStyle(color: utils.colorTextoPrincipalDark),
      ),
      validator: (texto) {
        if (utils.textoVacio(texto!)) return 'Escribe tu contraseña';
        return null;
      },
    );
  }

  Widget _crearBotonLogin() {
    return RaisedGradientButton(
      padding: EdgeInsets.all(0.0),
      borderRadius: BorderRadius.circular(15),
      gradient: utils.colorGradientePrincipal,
      disabledGradient: utils.colorGradienteSecundario,
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(utils.colorPrincipal)),
              visible: _iniciando,
            ),
            SizedBox(width: 10),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                _iniciando ? 'Iniciando sesión...' : 'Iniciar sesión',
                style: utils.estiloBotones(15),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      onPressed: _iniciando ? null : _submit,
    );
  }

  void _submit() {
    if (!formKey.currentState!.validate())
      return;
    else {
      formKey.currentState!.save();

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
    Map response = await loginProvider.registrarTokenOS();
    switch (response['statusCode']) {
      case 0:
        print(response['message']);
        break;
      case 200:
        break;
      case 500:
        print(response['message']);
        break;
    }
  }

  Widget _crebaBotonForgPass() {
    return ButtonTheme(
      height: 60,
      minWidth: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Theme.of(context).colorScheme.primary.withOpacity(0.5);
              return utils.colorAcentuado; // Use the component's default.
            },
          ),
          minimumSize: MaterialStateProperty.all(Size(double.infinity, 60)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0))),
        ),
        child: Text(
          'Olvidé mi contraseña',
          style: utils.estiloBotones(15),
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
