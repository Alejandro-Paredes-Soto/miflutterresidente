import 'dart:developer';

import 'package:dostop_v2/src/pages/restrict_version_page.dart';
import 'package:dostop_v2/src/providers/login_validator.dart';
import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/push_manager/push_notification_manager.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:dostop_v2/src/pages/settings_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../providers/config_usuario_provider.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final _prefs = PreferenciasUsuario();
  final pushManager = PushNotificationsManager();
  final _validaSesion = LoginValidator();
  final configUsuarioProvider = ConfigUsuarioProvider();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  bool _importance = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _notificationProvider = NotificacionesProvider();

  @override
  void initState() {
    //Se manda a llamr la funcion cuando se mata la app y vuelve a abrir
    checkDate();
    checkVersion();
    checkNotifications();
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => Future.delayed(
        Duration(milliseconds: 2300), () => pushManager.mostrarUltimaVisita()));
    WidgetsBinding.instance?.addObserver(this);
    _validaSesion.sesion.listen((sesionValida) {
      if (sesionValida == 0) {
        if (navigatorKey.currentContext != null) {
          _prefs.borraPrefs();
          Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(
              'login', (Route<dynamic> route) => false);
        }
      }
      if (sesionValida == 2) {
        creaDialogBloqueo(navigatorKey.currentContext!, 'Cuenta Suspendida',
            'Tu cuenta ha sido suspendida. Para reactivarla, comunícate con tu administración.');
      }
    });
    pushManager.mensajeStream.mensajes.listen((data) async {
      if (data.containsKey('visita')) {
        ///previene la llamada del setState cuando el widget ya ha sido destruido. (if (!mounted) return;)
        if (!mounted) return;
        await Navigator.pushNamed(navigatorKey.currentContext!, 'VisitaNotif',
            arguments: data['visita']);
        setState(() {});
      }

      if (data.containsKey('areas'))
        utils
            .creaSnackPersistent(
                Icons.notifications_active, data['areas'], Colors.white,
                dismissible: true)
            .show(navigatorKey.currentContext!);
      if (data.containsKey('aviso'))
        Navigator.pushNamed(navigatorKey.currentContext!, 'AvisoDetalle',
            arguments: data['aviso']);
      if (data.containsKey('encuesta')) {
        if (!mounted) return;
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
          //Se manda a llamar la funcion al abrir la aplicacion cuando se encuentra en segundo plano
          checkDate();
        });
        break;
      case AppLifecycleState.detached:
        // pushManager.detenerTimer();
        break;
    }
  }

  void checkVersion() async {
    final value = await _validaSesion.checkVersion();

    if (value == 'Critico') {
      _importance = true;
    } else {
      _importance = false;
    }
    setState(() {});
  }

  void checkNotifications() async {
    final resp = await pushManager.checkStatusnotifications();
    log('respuesta: $resp');
    if (resp == false) {
      creaDialogSettingsNotify(
          navigatorKey.currentContext!,
          'Notificaciones desactivadas',
          'Dostop necesita enviarte notificaciones para poder avisarte cuando tengas alguna visita.');
      log('activa tus notificaciones');
    } else {
      log('notificaciones activadas');
    }
  }

//Funcion para verificar si existe una fecha guardada en las preferencias y llamar al reestablecimiento del canal
  void checkDate() async {
    if (_prefs.dateChannel == '') {
      //Cuando no existe una fecha guardada en las preferencias
      _notificationChannel();
    } else {
      //Conversion de String a DateTime
      var date = DateTime.parse(_prefs.dateChannel);
      //Comparacion de entre la fecha guardada en las preferencias y la fecha actual si la fecha guardada es menor a la fecha actual se reestablece canal
      if (date.isBefore(DateTime.now())) {
        _notificationChannel();
      } else {
        log('Faltan ${DateTime.parse(_prefs.dateChannel).difference(DateTime.now())} para actualizar');
      }
    }
  }

//Metodo para reestablecer el canal y guardar la proxima fecha de actualiacion en las preferencias
  _notificationChannel() async {
    final Map resp = await _notificationProvider.notificationChannel();
//Si el reestablecimiento del canal fue correcto
    if (resp['statusCode'] == 201) {
      //Guardamos en las preferencias le fecha actual mas 30 dias para la proxima actualizacion
      _prefs.dateChannel = DateTime.now().add(Duration(days: 30)).toString();
      final List<AndroidNotificationChannel>? channels =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .getNotificationChannels();

      for (AndroidNotificationChannel channel in channels!) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.deleteNotificationChannel(channel.id);
      }

      String channelId = resp['canal'];
      AndroidNotificationChannel androidNotificationChannel =
          AndroidNotificationChannel(
        channelId,
        'Notificaciones de visitas',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('doorbell'),
        importance: Importance.high,
        description:
            'RECOMENDACIÓN: EVITE CAMBIAR CUALQUIER CONFIGURACIÓN DE ESTE APARTADO PARA ASEGURAR LA RECEPCIÓN DE VISITAS',
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);
      log('chanel: ${androidNotificationChannel.sound}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_importance == false) {
      return Scaffold(key: navigatorKey, body: HomePage());
    } else {
      return Scaffold(key: navigatorKey, body: RestrictVersionPage());
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }
}
