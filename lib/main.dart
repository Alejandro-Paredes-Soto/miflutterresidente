import 'package:dostop_v2/src/pages/areas_comunes_page.dart';
import 'package:dostop_v2/src/pages/aviso_detalle_page.dart';
import 'package:dostop_v2/src/pages/avisos_page.dart';
import 'package:dostop_v2/src/pages/emergencia_page.dart';
import 'package:dostop_v2/src/pages/estado_de_cuenta_page.dart';
import 'package:dostop_v2/src/pages/mi_casa_page.dart';
import 'package:dostop_v2/src/pages/mis_accesos_page.dart';
import 'package:dostop_v2/src/pages/nuevo_visitante_freq_page.dart';
import 'package:dostop_v2/src/pages/nuevo_visitante_rostro_page.dart';
import 'package:dostop_v2/src/pages/promocion_detalle_page.dart';
import 'package:dostop_v2/src/pages/login_page.dart';
import 'package:dostop_v2/src/pages/main_page.dart';
import 'package:dostop_v2/src/pages/promociones_page.dart';
import 'package:dostop_v2/src/pages/restablecer_usuario_page.dart';
import 'package:dostop_v2/src/pages/seguimiento_reporte_page.dart';
import 'package:dostop_v2/src/pages/visita_detalle_page.dart';
import 'package:dostop_v2/src/pages/reportar_incidente_page.dart';
import 'package:dostop_v2/src/pages/visita_notificacion_page.dart';
import 'package:dostop_v2/src/pages/visitantes_frecuentes_page.dart';
import 'package:dostop_v2/src/pages/visitas_page.dart';
import 'package:dostop_v2/src/providers/login_provider.dart';
import 'package:dostop_v2/src/push_manager/push_notification_manager.dart';

import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = new PreferenciasUsuario();
  await prefs.initPrefs();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  final pushManager = PushNotificationsManager();
  final prefs = new PreferenciasUsuario();
  final _loginProvider = LoginProvider();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    //Agregar al main_page. para solo recibir notificaciones si esta logueado
    pushManager.initNotificationsOS();
    if (prefs.usuarioLogged.isNotEmpty && prefs.playerID.isEmpty) {
      pushManager.initNotifications();
    }

    if (prefs.usuarioLogged.isNotEmpty &&
        prefs.playerID.isNotEmpty &&
        !prefs.registeredPlayerID) {
      _loginProvider.registrarTokenOS();
    }
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
      child: MaterialApp(
        // /*BLOQUE DE CODIGO QUE PREVIENE EL ESCALADO DE TEXTO CON EL SISTEMA*/
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
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
          'resetUser': (BuildContext context) => RestablecerUsuarioPage(),
          'main': (BuildContext context) => MainPage(),
          'visitas': (BuildContext context) => VisitasPage(),
          'emergencias': (BuildContext context) => EmergenciasPage(),
          'avisos': (BuildContext context) => AvisosPage(),
          'visitantesFreq': (BuildContext context) =>
              VisitantesFrecuentesPage(),
          'estadosCuenta': (BuildContext context) => EstadoDeCuentaPage(),
          'areasComunes': (BuildContext context) => AreasComunesPage(),
          'miCasa': (BuildContext context) => MiCasaPage(),
          'promociones': (BuildContext context) => PromocionesPage(),
          'AvisoDetalle': (BuildContext context) => AvisoDetallePage(),
          'VisitaDetalle': (BuildContext context) => VisitaDetallePage(),
          'VisitaNotif': (BuildContext context) => VisitaNofificacionPage(),
          'promoDetalle': (BuildContext context) => PromocionDetallePage(),
          'NuevoVisitFreq': (BuildContext context) =>
              NuevoVisitanteFrecuentePage(),
          'NuevoVisitRostro': (BuildContext context) =>
              NuevoVisitanteRostroPage(),
          'Incidente': (BuildContext context) => ReportarIncidentePage(),
          'SeguimientoInc': (BuildContext context) =>
              SeguimientoIncidentePage(),
          'misAccesos': (BuildContext context) => MisAccesosPage()
        },
        themeMode: prefs.themeMode == 'Dark' ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
            textTheme: TextTheme(caption: TextStyle(color: Colors.black)),
            snackBarTheme: SnackBarThemeData(actionTextColor: Colors.white),
            iconTheme: IconThemeData(color: Colors.black),
            fontFamily: 'PlusJakarta',
            primaryColor: utils.colorPrincipal,
            primarySwatch: utils.colorCalendario,
            dividerTheme: DividerThemeData(color: Colors.black, thickness: 1),
            buttonTheme: ButtonThemeData(
                buttonColor: utils.colorPrincipal,
                disabledColor: utils.colorSecundario),
            elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed))
                    return Theme.of(context).colorScheme.primary;
                  else if (states.contains(MaterialState.disabled))
                    return utils.colorSecundario;
                  return null; // Use the component's default.
                },
              ),
            )),
            textSelectionTheme: TextSelectionThemeData(
                cursorColor: utils.colorPrincipal,
                selectionColor: Colors.black26,
                selectionHandleColor: utils.colorSecundario),
            cardColor: Colors.white,
            appBarTheme: AppBarTheme(
                toolbarTextStyle: TextStyle(color: Colors.black),
                titleTextStyle: TextStyle(color: Colors.black),
                iconTheme: IconThemeData(color: Colors.black),
                actionsIconTheme: IconThemeData(color: Colors.black),
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                elevation: 0,
                color: utils.colorFondoPrincipalLight),
            scaffoldBackgroundColor: utils.colorFondoPrincipalLight),
        darkTheme: ThemeData(
            dialogBackgroundColor: utils.colorFondoTarjetaDark,
            disabledColor: utils.colorSecundario,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: utils.colorTextoPrincipalDark),
                hintStyle: TextStyle(color: utils.colorTextoPrincipalDark)),
            iconTheme: IconThemeData(color: Colors.white),
            snackBarTheme: SnackBarThemeData(
                actionTextColor: utils.colorFondoPrincipalDark),
            dividerTheme: DividerThemeData(color: Colors.white, thickness: 1),
            textTheme: TextTheme(
                bodyText2: TextStyle(color: Colors.white),
                caption: TextStyle(color: Colors.white)),
            fontFamily: 'PlusJakarta',
            brightness: Brightness.dark,
            primaryColor: utils.colorPrincipal,
            primarySwatch: utils.colorCalendario,
            textSelectionTheme: TextSelectionThemeData(
                cursorColor: utils.colorPrincipal,
                selectionColor: Colors.grey,
                selectionHandleColor: Colors.grey),
            backgroundColor: utils.colorFondoPrincipalDark,
            cardColor: utils.colorFondoTarjetaDark,
            buttonTheme: ButtonThemeData(
                buttonColor: utils.colorPrincipal,
                disabledColor: utils.colorSecundario),
            elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed))
                    return Theme.of(context).colorScheme.primary;
                  else if (states.contains(MaterialState.disabled))
                    return utils.colorSecundario;
                  return null; // Use the component's default.
                },
              ),
            )),
            appBarTheme: AppBarTheme(
                toolbarTextStyle: TextStyle(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white),
                iconTheme: IconThemeData(color: Colors.white),
                actionsIconTheme: IconThemeData(color: Colors.white),
                systemOverlayStyle: SystemUiOverlayStyle.light,
                elevation: 0,
                color: utils.colorFondoPrincipalDark),
            canvasColor: utils.colorFondoTarjetaDark,
            floatingActionButtonTheme:
                FloatingActionButtonThemeData(foregroundColor: Colors.white),
            scaffoldBackgroundColor: utils.colorFondoPrincipalDark),
      ),
    );
  }

  void changeTheme() {
    setState(() {
      prefs.themeMode = prefs.themeMode == 'Dark' ? 'Light' : 'Dark';
    });
  }
}
