import 'dart:developer';

import 'package:dostop_v2/src/providers/contact_support_provider.dart';
import 'package:dostop_v2/src/providers/restablecer_usuario_provider.dart';
import 'package:dostop_v2/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';

class ContactSupportPage extends StatefulWidget {
  @override
  _ContactSupportPageState createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final formKey = GlobalKey<FormState>();
  final restableceUsrProvider = RestablecerUsuarioProvider();
  final _txtReason = TextEditingController();
  final _prefs = PreferenciasUsuario();
  final _numberContact = ContactSupport();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: '¿Necesitas ayuda?'),
      body: _creaBody(),
    );
  }

  Widget _creaBody() {
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              _inputReason(),
              SizedBox(height: 20),
              _buttonSendMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputReason() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contáctanos',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            style: TextStyle(
                fontSize: 16,
                color:
                    _prefs.themeMode == 'Dark' ? Colors.white : Colors.black),
            children: <TextSpan>[
              TextSpan(text: 'Por favor ingresa '),
              TextSpan(
                  text: 'tu dirección y el problema que tienes',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              TextSpan(
                  text:
                      ', alguien de nuestro equipo de soporte te atenderá lo antes posible.'),
            ],
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          maxLines: null,
          minLines: 5,
          controller: _txtReason,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Este formulario es de carácter obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buttonSendMessage() {
    return MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        height: 60,
        minWidth: double.infinity,
        highlightElevation: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Text(
                'Enviar WhatsApp a soporte',
                style: estiloBotones(15),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        color: colorPrincipal,
        disabledColor: colorSecundario,
        onPressed: () {
          if (formKey.currentState!.validate()) {
            _launchWhatsApp(
                _prefs.supportContact == ''
                    ? '524775872189'
                    : _prefs.supportContact,
                _txtReason.text);
            _txtReason.clear();
          }
        });
  }

  void getNumber() async {
    final _num = await _numberContact.getContactNumber();
    _prefs.supportContact = _num;
  }

  _launchWhatsApp(String numero, String mensaje) async {
    final link = WhatsAppUnilink(
        phoneNumber: numero, text: '*Soy usuario Dostop:* $mensaje');
    await launchUrl(Uri.parse(link.toString()),
        mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _txtReason.dispose();
    super.dispose();
  }
}
