import 'package:dostop_v2/src/pages/aviso_detalle_page.dart';
import 'package:dostop_v2/src/pages/nuevo_visitante_freq_page.dart';
import 'package:dostop_v2/src/pages/promocion_detalle_page.dart';
import 'package:dostop_v2/src/pages/login_page.dart';
import 'package:dostop_v2/src/pages/main_page.dart';
import 'package:dostop_v2/src/pages/restablecer_usuario_page.dart';
import 'package:dostop_v2/src/pages/seguimiento_reporte_page.dart';
import 'package:dostop_v2/src/pages/visita_detalle_page.dart';
import 'package:dostop_v2/src/pages/reportar_incidente_page.dart';
import 'package:dostop_v2/src/pages/visita_notificacion_page.dart';
import 'package:dostop_v2/src/push_manager/push_notification_manager.dart';

import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new PreferenciasUsuario();
  await prefs.initPrefs();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final prefs = new PreferenciasUsuario();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    //Agregar al main_page. para solo recibir notificaciones si esta logueado
    final pushManager = PushNotificationsManager();
    pushManager.initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return StyledToast(
        locale: Locale('es', 'ES'),
        toastAnimation: StyledToastAnimation.slideFromBottom,
        reverseAnimation: StyledToastAnimation.slideToBottom,
        startOffset: Offset(0.0, 3.0),
        reverseEndOffset: Offset(0.0, 5.0),
        duration: Duration(seconds: 4),
        //Animation duration   animDuration * 2 <= duration
        animDuration: Duration(seconds: 1),
        curve: Curves.elasticOut,
        reverseCurve: Curves.fastOutSlowIn,
        toastPositions:
            StyledToastPosition(align: Alignment.bottomCenter, offset: 80),
        child:
            MaterialApp(
          // /*BLOQUE DE CODIGO QUE PREVIENE EL ESCALADO DE TEXTO CON EL SISTEMA*/
          // builder: (BuildContext context, Widget child) {
          //   return MediaQuery(
          //   data: MediaQuery.of(context).copyWith(textScaleFactor: 1.2),
          //   child: child,);},
          // /*FIN DEL BLOQUE*/
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('es'), //Español
            const Locale('en'),
          ],
          locale: const Locale('es'),
          title: 'Dostop',
          initialRoute: prefs.usuarioLogged == '' ? 'login' : 'main',
          routes: {
            'login': (BuildContext context) => LoginPage(),
            'main': (BuildContext context) => MainPage(),
            'resetUser': (BuildContext context) => RestablecerUsuarioPage(),
            'AvisoDetalle': (BuildContext context) => AvisoDetallePage(),
            'VisitaDetalle': (BuildContext context) => VisitaDetallePage(),
            'VisitaNotif': (BuildContext context) => VisitaNofificacionPage(),
            'promoDetalle': (BuildContext context) => PromocionDetallePage(),
            'NuevoVisitFreq': (BuildContext context) =>
                NuevoVisitanteFrecuentePage(),
            'Incidente': (BuildContext context) => ReportarIncidentePage(),
            'SeguimientoInc': (BuildContext context) => SeguimientoIncidentePage(),
          },
          theme: ThemeData(
              snackBarTheme: SnackBarThemeData(actionTextColor: Colors.white),
              iconTheme: IconThemeData(color: utils.colorIconos),
              fontFamily: 'Poppins',
              primaryColor: utils.colorPrincipal,
              primarySwatch: utils.colorCalendario,
              accentColor: utils.colorSecundario,
              buttonTheme: ButtonThemeData(
                  buttonColor: utils.colorPrincipal,
                  disabledColor: utils.colorSecundario),
              cursorColor: utils.colorPrincipal,
              textSelectionColor: Colors.black26,
              textSelectionHandleColor: utils.colorSecundario,
              cardColor: utils.colorFondoTarjeta,
              appBarTheme: AppBarTheme(
                  textTheme:
                      TextTheme(headline6: TextStyle(color: Colors.black)),
                  iconTheme: IconThemeData(color: utils.colorSecundario),
                  actionsIconTheme: IconThemeData(color: utils.colorSecundario),
                  brightness: Brightness.light,
                  elevation: 0,
                  color: Colors.white),
              scaffoldBackgroundColor: Colors.white),
          // CONFIGURACIONES DEL DARK MODE THEME
          darkTheme: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(
                  color: utils.colorSecundario,
                ),
                hintStyle: TextStyle(color: utils.colorSecundario)),
            iconTheme: IconThemeData(color: utils.colorTextoPrincipalDark),
            snackBarTheme: SnackBarThemeData(
                actionTextColor: utils.colorFondoPrincipalDark),
            textTheme: TextTheme(
                bodyText2: TextStyle(color: utils.colorTextoPrincipalDark)),
            fontFamily: 'Poppins',
            brightness: Brightness.dark,
            primaryColor: utils.colorPrincipal,
            accentColor: Colors.grey,
            cursorColor: Colors.red,
            backgroundColor: utils.colorFondoPrincipalDark,
            textSelectionColor: Colors.grey,
            textSelectionHandleColor: Colors.grey,
            buttonTheme: ButtonThemeData(
                buttonColor: utils.colorPrincipal,
                disabledColor: utils.colorSecundario),
            appBarTheme: AppBarTheme(
                textTheme: TextTheme(
                    headline6: TextStyle(color: utils.colorTextoPrincipalDark)),
                iconTheme: IconThemeData(color: utils.colorTextoPrincipalDark),
                actionsIconTheme:
                    IconThemeData(color: utils.colorFondoPrincipalDark),
                brightness: Brightness.dark,
                elevation: 0,
                color: utils.colorFondoPrincipalDark),
            canvasColor: utils.colorFondoPrincipalDark,
            floatingActionButtonTheme:
                FloatingActionButtonThemeData(foregroundColor: Colors.white),
          ),
        ));
  }
}
