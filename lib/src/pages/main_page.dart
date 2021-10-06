import 'package:dostop_v2/src/providers/login_validator.dart';
import 'package:dostop_v2/src/push_manager/push_notification_manager.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

import 'package:flutter/material.dart';

import 'home_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final _prefs = PreferenciasUsuario();
  final pushManager = PushNotificationsManager();
  final _validaSesion = LoginValidator();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
        Duration(milliseconds: 2300), () => pushManager.mostrarUltimaVisita()));
    WidgetsBinding.instance.addObserver(this);
    _validaSesion.sesion.listen((sesionValida) {
      if (sesionValida == 0) {
        if (navigatorKey.currentContext != null) {
          _prefs.borraPrefs();
          //print('${_prefs.usuarioLogged}');
          Navigator.of(navigatorKey.currentContext).pushNamedAndRemoveUntil(
              'login', (Route<dynamic> route) => false);
        }
      }
      if (sesionValida == 2) {
        creaDialogBloqueo(navigatorKey.currentContext, 'Cuenta Suspendida',
            'Tu cuenta ha sido suspendida. Para reactivarla, comunícate con tu administración.');
      }
    });
    pushManager.mensajeStream.mensajes.listen((data) async {
      if (data.containsKey('areas'))
        utils
            .creaSnackPersistent(
                Icons.notifications_active, data['areas'], Colors.white,
                dismissible: true)
            .show(navigatorKey.currentContext);
      if (data.containsKey('aviso'))
        Navigator.pushNamed(navigatorKey.currentContext, 'AvisoDetalle',
            arguments: data['aviso']);
      if (data.containsKey('visita')) {
        ///previene la llamada del setState cuando el widget ya ha sido destruido. (if (!mounted) return;)
        if (!mounted) return;
        await Navigator.pushNamed(navigatorKey.currentContext, 'VisitaNotif',
            arguments: data['visita']);
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        // pushManager.detenerTimer();
        break;
      case AppLifecycleState.paused:
        // pushManager.detenerTimer();
        break;
      case AppLifecycleState.resumed:
        Future.delayed(Duration(milliseconds: 1200), () {
          // if (ModalRoute.of(context).isCurrent)
          pushManager.mostrarUltimaVisita();
        });
        break;
      case AppLifecycleState.detached:
        // pushManager.detenerTimer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: navigatorKey, body: HomePage());
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
