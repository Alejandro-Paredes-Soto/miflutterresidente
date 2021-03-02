import 'package:dostop_v2/src/pages/areas_comunes_page.dart';
import 'package:dostop_v2/src/pages/avisos_page.dart';
import 'package:dostop_v2/src/pages/emergencia_page.dart';
import 'package:dostop_v2/src/pages/estado_de_cuenta_page.dart';
import 'package:dostop_v2/src/pages/home_page.dart';
import 'package:dostop_v2/src/pages/mi_casa_page.dart';
import 'package:dostop_v2/src/pages/promociones_page.dart';
import 'package:dostop_v2/src/pages/visitantes_frecuentes_page.dart';
import 'package:dostop_v2/src/pages/visitas_page.dart';
import 'package:dostop_v2/src/providers/login_validator.dart';
import 'package:dostop_v2/src/providers/login_provider.dart';
import 'package:dostop_v2/src/push_manager/push_notification_manager.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _indexItem = 0;
  final _pageController = PageController(keepPage: true);
  final _prefs = PreferenciasUsuario();
  final _loginProvider = LoginProvider();
  final pushManager = PushNotificationsManager();
  final _validaSesion = LoginValidator();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  final GlobalKey _navKey = GlobalKey();

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
      if (data.containsKey('encuesta')) {
        creaDialogSimple(
            navigatorKey.currentContext,
            'Nueva encuesta disponible',
            'Respóndela en la sección de inicio',
            'Aceptar', () {
          Navigator.pop(navigatorKey.currentContext);
          setState(() {});
        });
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
    return Scaffold(
      key: navigatorKey,
      body:  _creaBody(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                  child: AnimatedContainer(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _indexItem == 0
                      ? utils.colorPrincipal
                      : Colors.transparent,
                ),
                duration: Duration(milliseconds: 200),
                height: 5,
              )),
              Flexible(
                  child: AnimatedContainer(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _indexItem == 1
                      ? utils.colorPrincipal
                      : Colors.transparent,
                ),
                duration: Duration(milliseconds: 200),
                height: 5,
              )),
              Flexible(
                  child: AnimatedContainer(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _indexItem == 2
                      ? utils.colorPrincipal
                      : Colors.transparent,
                ),
                duration: Duration(milliseconds: 200),
                height: 5,
              )),
              Flexible(
                  child: AnimatedContainer(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _indexItem == 3
                      ? utils.colorPrincipal
                      : Colors.transparent,
                ),
                duration: Duration(milliseconds: 200),
                height: 5,
              )),
            ],
          ),
          _crearBNavBar(),
        ],
      ),
    );
  }

  Widget _creaBody() {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          if (_indexItem < 3) _indexItem = index;
        });
      },
      children: <Widget>[
        HomePage(
          pageController: _pageController,
        ),
        VisitasPage(),
        EmergenciasPage(),
        AvisosPage(),
        VisitantesFrecuentesPage(),
        EstadoDeCuentaPage(),
        AreasComunesPage(),
        MiCasaPage(),
        PromocionesPage(),
      ],
    );
  }

  Widget _crearBNavBar() {
    return BottomNavigationBar(
      key: _navKey,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: utils.colorPrincipal,
      currentIndex: _indexItem,
      onTap: (index) {
        if (index == 3) {
          _crearModalBottom(context);
        } else {
          _indexItem = index;
          setState(() {
            _pageController.jumpToPage(index);
          });
        }
      },
      items: [
        BottomNavigationBarItem(
            icon: SvgPicture.asset(utils.rutaIconoInicio,
                color: Theme.of(context).iconTheme.color,
                height: utils.tamanoIcoNavBar),
            activeIcon: SvgPicture.asset(
              utils.rutaIconoInicio,
              height: utils.tamanoIcoNavBar,
              color: utils.colorPrincipal,
            ),
            title: Column(
              children: <Widget>[
                // SizedBox(
                //   height: 5.0,
                // ),
                // Text('Inicio', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(utils.rutaIconoVisitas,
                color: Theme.of(context).iconTheme.color,
                height: utils.tamanoIcoNavBar),
            activeIcon: SvgPicture.asset(utils.rutaIconoVisitas,
                height: utils.tamanoIcoNavBar, color: utils.colorPrincipal),
            title: Column(
              children: <Widget>[
                // SizedBox(
                //   height: 5.0,
                // ),
                // Text('Visitas', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(utils.rutaIconoEmergencia,
              color: Theme.of(context).iconTheme.color,
              height: utils.tamanoIcoNavBar),
          activeIcon: SvgPicture.asset(
            utils.rutaIconoEmergencia,
            height: utils.tamanoIcoNavBar,
            color: utils.colorPrincipal,
          ),
          title: Column(
            children: <Widget>[
              // SizedBox(
              //   height: 5.0,
              // ),
              // Text('Emergencias', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        BottomNavigationBarItem(
          icon: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SvgPicture.asset(utils.rutaIconoMenu,
                  height: 16, color: Theme.of(context).iconTheme.color)),
          activeIcon: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SvgPicture.asset(utils.rutaIconoMenu,
                  height: 16, color: utils.colorPrincipal)),
          title: Column(
            children: <Widget>[
              SizedBox(
                height: 5.0,
              ),
              // Text('Menú', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  _crearModalBottom(BuildContext context) {
    showModalBottomSheet<void>(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: _creaItemModal(
                              icono: SvgPicture.asset(
                                utils.rutaIconoAvisos,
                                color: Theme.of(context).iconTheme.color,
                                height: utils.tamanoIcoNavBar,
                              ),
                              titulo: 'Avisos',
                              onTap: () {
                                setState(() {
                                  _pageController.jumpToPage(3);
                                  _indexItem = 3;
                                  Navigator.pop(ctx);
                                });
                              }),
                        ),
                        //FUTURO BOTÖN DE CONFIGURACIONES.
                        // Flexible(
                        //   flex: 1,
                        //   child: IconButton(
                        //     icon: Icon(Icons.settings),
                        //     onPressed: (){},),
                        // )
                      ],
                    ),
                    _creaItemModal(
                        icono: SvgPicture.asset(
                          utils.rutaIconoVisitantesFrecuentes,
                          color: Theme.of(context).iconTheme.color,
                          height: utils.tamanoIcoNavBar,
                        ),
                        titulo: 'Visitantes Frecuentes',
                        onTap: () {
                          setState(() {
                            _pageController.jumpToPage(4);
                            _indexItem = 3;
                            Navigator.pop(ctx);
                          });
                        }),
                    _creaItemModal(
                        icono: SvgPicture.asset(
                          utils.rutaIconoEstadoDeCuenta,
                          color: Theme.of(context).iconTheme.color,
                          height: utils.tamanoIcoNavBar,
                        ),
                        titulo: 'Estados de Cuenta',
                        onTap: () {
                          setState(() {
                            _pageController.jumpToPage(5);
                            _indexItem = 3;
                            Navigator.pop(ctx);
                          });
                        }),
                    _creaItemModal(
                        icono: SvgPicture.asset(
                          utils.rutaIconoAreasComunes,
                          color: Theme.of(context).iconTheme.color,
                          height: utils.tamanoIcoNavBar,
                        ),
                        titulo: 'Áreas Comunes',
                        onTap: () {
                          setState(() {
                            _pageController.jumpToPage(6);
                            _indexItem = 3;
                            Navigator.pop(ctx);
                          });
                        }),
                    _creaItemModal(
                        icono: SvgPicture.asset(
                          utils.rutaIconoMiCasa,
                          color: Theme.of(context).iconTheme.color,
                          height: utils.tamanoIcoNavBar,
                        ),
                        titulo: 'Mi Casa',
                        onTap: () {
                          setState(() {
                            _pageController.jumpToPage(7);
                            _indexItem = 3;
                            Navigator.pop(ctx);
                          });
                        }),
                    _creaItemModal(
                        icono: SvgPicture.asset(
                          utils.rutaIconoPromociones,
                          color: Theme.of(context).iconTheme.color,
                          height: utils.tamanoIcoNavBar,
                        ),
                        titulo: 'Promociones',
                        onTap: () {
                          setState(() {
                            _pageController.jumpToPage(8);
                            _indexItem = 3;
                            Navigator.pop(ctx);
                          });
                        }),
                    _creaItemModal(
                        icono: SvgPicture.asset(
                          utils.rutaIconoCerrarSesion,
                          color: Theme.of(context).iconTheme.color,
                          height: utils.tamanoIcoNavBar,
                        ),
                        titulo: 'Cerrar Sesión',
                        onTap: () {
                          Navigator.pop(ctx);
                          _cerrarSesion();
                        }),
                    _creaTerminosLegales()
                    // ListTile(
                    //     trailing: Icon(
                    //       Icons.close,
                    //       size: 40,
                    //     ),
                    //     onTap: () => Navigator.pop(ctx)),
                    //subtitle: Text('deslice hacia abajo para cerrar',textAlign: TextAlign.right,),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _creaItemModal({Widget icono, String titulo, Function onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 10),
            Container(
                alignment: Alignment.center,
                height: 45,
                width: 35,
                child: icono),
            SizedBox(width: 20),
            Flexible(
                fit: FlexFit.tight,
                child: Text(
                  titulo,
                  style: utils.estiloItemsModal(16),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                )),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _creaTerminosLegales() {
    return Container(
      height: 35,
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Text('Aviso de privacidad',
                  textScaleFactor: 0.8,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12)),
              onPressed: () => utils.abrirPaginaWeb(
                  url: 'https://dostop.mx/aviso-de-privacidad.html'),
            ),
          ),
          //Flexible(fit: FlexFit.tight, child: Icon(Icons.phone, size: 36,),),
          Flexible(
            fit: FlexFit.tight,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Text('Terms. y condiciones',
                  textScaleFactor: 0.8,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12)),
              onPressed: () => utils.abrirPaginaWeb(url: 'https://dostop.mx/'),
            ),
          ),
        ],
      ),
    );
  }

  _cerrarSesion() {
    creaDialogYesNoAlt(
        context,
        'Confirmar',
        '¿Estás seguro de que deseas cerrar sesión?\n\nDejarás de recibir notificaciones de tus visitas.',
        'Cerrar sesión',
        'Cancelar', () {
      Navigator.pop(context);
      creaDialogProgress(context, 'Cerrando Sesión...');
      _loginProvider.logout().then((logout) {
        Navigator.pop(context);
        if (logout) {
          _prefs.borraPrefs();
          print('${_prefs.usuarioLogged}');
          Navigator.of(context).pushNamedAndRemoveUntil(
              'login', (Route<dynamic> route) => false);
        } else {
          creaDialogSimple(
              context,
              '¡Ups! algo salió mal',
              'No se pudo cerrar tu sesión, verifica tu conexión a internet',
              'Aceptar',
              () => Navigator.pop(context));
        }
      });
    }, () => Navigator.pop(context));
  }

  @override
  void deactivate() {
    super.deactivate();
    // pushManager.detenerTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
