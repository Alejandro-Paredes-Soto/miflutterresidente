import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageTools;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

bool isDebug = !kReleaseMode;

Color colorFondoPrincipalDark = Color.fromRGBO(22, 29, 40, 1.0);
Color colorFondoPrincipalLight = Color.fromRGBO(245, 244, 249, 1.0);
Color colorTextoPrincipalDark = Color.fromRGBO(184, 184, 184, 1.0);
Color colorIconos = Color.fromRGBO(65, 64, 64, 1.0);
Color colorPrincipal = Color.fromRGBO(2, 69, 232, 1.0);
Color colorPrincipal2 = Color.fromRGBO(0, 60, 206, 1.0);
Color colorAcentuado = Color.fromRGBO(2, 183, 84, 1.0);
Color colorSecundario = Color.fromRGBO(102, 106, 106, 1.0);
Color colorSecundario2 = Color.fromRGBO(96, 96, 96, 1.0);
Color colorSecundarioSemi = Color.fromRGBO(102, 106, 106, 0.5);
Color colorSecundarioSemi08 = Color.fromRGBO(102, 106, 106, 0.8);
Color colorFondoLoginSemi = Color.fromRGBO(0, 0, 0, 0.50);
Color colorTextLoginSemi = Color.fromRGBO(0, 0, 0, 0.60);
Color colorSecundarioToggle = Color.fromRGBO(102, 106, 106, 0.2);
Color colorIndicadorSwiper = Color.fromRGBO(128, 128, 128, 0.8);
Color colorFondoTarjeta = Color.fromRGBO(244, 244, 244, 1.0);
Color colorFondoTarjetaDark = Color.fromRGBO(32, 45, 61, 1.0);
Color colorFondoTarjetaFreq = Color.fromRGBO(226, 226, 226, 1.0);
Color colorContenedorSaldo = Color.fromRGBO(25, 163, 14, 1.0);
Color colorToastAceptada = Color.fromRGBO(25, 163, 14, 1.0);
Color colorToastRechazada = Color.fromRGBO(233, 55, 54, 1.0);
Color colorFechaAviso = Color.fromRGBO(146, 152, 160, 1.0);
Color colorFondoTabs = Color.fromRGBO(173, 176, 180, 1.0);

MaterialColor colorCalendario = MaterialColor(0xFF0245E8, _colorCalendario);
const Map<int, Color> _colorCalendario = {
  50: const Color(0xFF0245E8),
  100: const Color(0xFF0245E8),
  200: const Color(0xFF0245E8),
  300: const Color(0xFF0245E8),
  400: const Color(0xFF0245E8),
  500: const Color(0xFF003CCE),
  600: const Color(0xFF003CCE),
  700: const Color(0xFF003CCE),
  800: const Color(0xFF003CCE),
  900: const Color(0xFF003CCE)
};
LinearGradient colorGradientePrincipal = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [colorPrincipal, colorPrincipal2]);
LinearGradient colorGradienteSecundario = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [colorSecundario, colorSecundario2]);

double tamanoIcoNavBar = 28;
double tamanoIcoModal = 20;
double tamanoIcoSnackbar = 18;
String rutaLogoParcoDark='assets/LogoParcoDark.png';
String rutaLogoParcoLight='assets/LogoParcoLight.png';
String rutaLogoDostopDPng = 'assets/LogoDostopD.png';
String rutaLogoLetrasDostopPng = 'assets/LogoLetrasDostop.png';
String rutaLogoLetrasDostopParco = 'assets/LogoLetrasDostopParco.png';

String rutaIconoInicio = 'assets/IconoInicio.svg';
String rutaIconoVisitas = 'assets/IconoVisitas.svg';
String rutaIconoEmergencia = 'assets/IconoEmergencia.svg';
String rutaIconoAvisos = 'assets/IconoAvisos.svg';
String rutaIconoVisitantesFrecuentes = 'assets/IconoVisitaFrecuente.svg';
String rutaIconoEstadoDeCuenta = 'assets/IconoEstadoDeCuenta.svg';
String rutaIconoAreasComunes = 'assets/IconoAreasComunes.svg';
String rutaIconoMiCasa = 'assets/IconoMiCasa.svg';
String rutaIconoPromociones = 'assets/IconoPromociones.svg';
String rutaIconoCerrarSesion = 'assets/IconoCerrarSesion.svg';
String rutaIconoMenu = 'assets/IconoMenu.svg';
String rutaIconoCaseta = 'assets/IconoCaseta.svg';
String rutaGifLoadRed = 'assets/loading-image.gif';
String rutaGifLoadBanner = 'assets/loading-banner.gif';
String rutaIconoWhastApp = 'assets/whatsapp.svg';
String rutaFondoLogin = 'assets/fondo-login-main.jpg';
String rutaFondoQR = 'assets/FondoQR.png';
String rutaIconoAccesos = 'assets/IconoAccesos.svg';
String rutaIconTipoAcceso = 'assets/accessType.svg';
String rutaIconQR = 'assets/IconoQR.svg';

AppBar appBarLogo(
    {@required String titulo, BackButton backbtn = const BackButton()}) {
  return AppBar(
    automaticallyImplyLeading: false,
    centerTitle: false,
    elevation: 0.0,
    leading: backbtn,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            titulo,
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -1),
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ),
        SizedBox(),
        dostopLogo(),
      ],
    ),
  );
}

Text dostopLogo() {
  return Text(
    'dostop',
    style: TextStyle(
        fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700),
  );
}

TextStyle estiloFechaAviso(double fontSize, {Color color = const Color.fromRGBO(146, 152, 160, 1.0)}) {
  return TextStyle(
      fontSize: fontSize, fontWeight: FontWeight.w500, color: color);
}

TextStyle estiloTextoAppBar(double fontSize) {
  return TextStyle(
      fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: fontSize);
}

TextStyle estiloBotones(double fontSize, {Color color = Colors.white}) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: FontWeight.w900,
  );
}

TextStyle estiloTituloTarjeta(double fontSize) {
  return TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500);
}

TextStyle estiloSubtituloTarjeta(double fontSize) {
  return TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900);
}

TextStyle estiloTextoSombreado(double fontSize,
    {Color color = Colors.white,
    double blurRadius = 20,
    double offsetX = 0,
    double offsetY = 0,
    bool dobleSombra = true,
    FontWeight fontWeight = FontWeight.w900}) {
  return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      shadows: [
        Shadow(
            color: Colors.black,
            blurRadius: blurRadius,
            offset: Offset(offsetX, offsetY)),
        Shadow(
            color: dobleSombra ? Colors.black : Colors.transparent,
            blurRadius: blurRadius,
            offset: Offset(offsetX, offsetY)),
      ]);
}

TextStyle estiloTituloInfoVisita(double fontSize) {
  return TextStyle(
      color: colorAcentuado, fontSize: fontSize, fontWeight: FontWeight.w900,
      shadows: [
        Shadow(
            color: Colors.black,
            blurRadius: 5,
            offset: Offset(0, 0)),
      ]);
}

Brightness temaStatusBar(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS
      ? Brightness.light
      : Brightness.dark;
}

bool correoValido(String email) {
  Pattern patternCorreoValido =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  if (!RegExp(patternCorreoValido).hasMatch(email))
    return false;
  else
    return true;
}

bool textoVacio(String text) {
  if (text.trim().isEmpty) {
    return true;
  } else
    return false;
}

Flushbar creaSnackPersistent(IconData icon, String texto, Color color,
    {Duration duration, dismissible = false}) {
  return Flushbar(
    flushbarPosition: FlushbarPosition.BOTTOM,
    borderRadius: 5,
    animationDuration: Duration(milliseconds: 300),
    icon: Icon(
      icon,
      color: color,
    ),
    margin: EdgeInsets.only(bottom: 50, left: 50, right: 50),
    flushbarStyle: FlushbarStyle.FLOATING,
    message: texto,
    duration: duration,
    isDismissible: dismissible,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
  );
}

SnackBar creaSnackBarIcon(Widget icon, String texto, int segundos) {
  return SnackBar(
    content: Row(
      children: <Widget>[
        icon,
        SizedBox(
          width: 15,
        ),
        Flexible(
          child: Text(texto,
              style: TextStyle(fontSize: 16), overflow: TextOverflow.fade),
        ),
      ],
    ),
    duration: Duration(seconds: segundos),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {},
    ),
  );
}

SnackBar creaSnackBarIconFn(Widget icon, String texto, int segundos,
    String textFn, Function funcionSnack) {
  return SnackBar(
    content: Row(
      children: <Widget>[
        icon,
        SizedBox(
          width: 15,
        ),
        Flexible(
          child: Text(texto,
              style: TextStyle(fontSize: 16), overflow: TextOverflow.fade),
        ),
      ],
    ),
    duration: Duration(seconds: segundos),
    action: SnackBarAction(
      label: textFn,
      onPressed: funcionSnack,
    ),
  );
}

abrirPaginaWeb({@required String url}) async {
  if (await canLaunch(url)) if (url.contains(RegExp(
      r'(https?:\/\/)?(www\.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)|(https?:\/\/)?(www\.)?(?!ww)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)')))
    await launch(url);
  else
    print('No es una dirección válida');
  else
    print('No se pudo abrir: $url');
}

String fechaCompleta(DateTime tm, {bool showTime = false}) {
  if (tm == null) return "";
  DateTime today = new DateTime.now();
  Duration oneDay = new Duration(days: 1);
  Duration twoDay = new Duration(days: 2);
  String month;
  switch (tm.month) {
    case 1:
      month = 'enero';
      break;
    case 2:
      month = 'febrero';
      break;
    case 3:
      month = 'marzo';
      break;
    case 4:
      month = 'abri';
      break;
    case 5:
      month = 'mayo';
      break;
    case 6:
      month = 'junio';
      break;
    case 7:
      month = 'julio';
      break;
    case 8:
      month = 'agosto';
      break;
    case 9:
      month = 'septiembre';
      break;
    case 10:
      month = 'octubre';
      break;
    case 11:
      month = 'noviembre';
      break;
    case 12:
      month = 'diciembre';
      break;
  }

  Duration difference = today.difference(tm);

  if (difference.compareTo(oneDay) < 1) {
    return "Hoy";
  } else if (difference.compareTo(twoDay) < 1) {
    return "Ayer";
  } else {
    return '${tm.day} de $month de ${tm.year}' +
        (showTime ? ' ${DateFormat("h:mm a").format(tm)}' : '');
  }
}

String fechaCompletaFuturo(DateTime tm, {String articuloDef = ''}) {
  if (tm == null) return '';
  DateTime today = DateTime.now();
  Duration oneDay = Duration(days: 1);
  final tomorrow = today.add(oneDay);
  String month;
  switch (tm.month) {
    case 1:
      month = 'enero';
      break;
    case 2:
      month = 'febrero';
      break;
    case 3:
      month = 'marzo';
      break;
    case 4:
      month = 'abri';
      break;
    case 5:
      month = 'mayo';
      break;
    case 6:
      month = 'junio';
      break;
    case 7:
      month = 'julio';
      break;
    case 8:
      month = 'agosto';
      break;
    case 9:
      month = 'septiembre';
      break;
    case 10:
      month = 'octubre';
      break;
    case 11:
      month = 'noviembre';
      break;
    case 12:
      month = 'diciembre';
      break;
  }

  if (tm.isBefore(today)) {
    return "Hoy";
  } else if (!tm.isAfter(tomorrow)) {
    return "Mañana";
  } else {
    return '$articuloDef ${tm.day} de $month de ${tm.year}';
  }
}

List<String> validaImagenes(List<String> imagenes) {
  List<String> list = [];
  
  list.addAll(imagenes);
  imagenes.forEach((item) {
    if (item == '' || item == null) list.remove(item);
  });
  return list;
}

Future<List<Map<String, dynamic>>> validaImagenesOrientacion(List<String> imagenes) async {
  List<Map<String, dynamic>> list = [];

  for (var i = 0; i < imagenes.length; i++) {
    if(imagenes[i] != '' && imagenes[i] != null){
      ui.Image img = await getImage(imagenes[i]);
      list.add({'img': imagenes[i], 'isVertical': img.height > img.width});
    }
  }
 
  return list;
}

Future<ui.Image> getImage(String path) async {
    var completer = Completer<ImageInfo>();
    var img = new NetworkImage(path);
    img
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
   
    return imageInfo.image;
  }

void descargaImagen(BuildContext context, String url) async {
  Scaffold.of(context).showSnackBar(
      creaSnackBarIcon(Icon(Icons.cloud_download), 'Descargando...', 1));
  try {
    if (Platform.isAndroid) {
      if (!await obtenerPermisosAndroid())
        throw 'No tienes permisos de almacenamiento';
    }
    var res = await http.get(url);
    await ImageGallerySaver.saveImage(Uint8List.fromList(res.bodyBytes));
    // print(result);
    Scaffold.of(context).showSnackBar(creaSnackBarIcon(
        Icon(Icons.file_download), 'Imagen guardada', 2));
  } catch (e) {
    Scaffold.of(context).showSnackBar(creaSnackBarIcon(
        Icon(Icons.error), 'La imagen no pudo ser guardada', 2));
  }
}

Future<bool> obtenerPermisosAndroid() async {
  Map<Permission, PermissionState> permission =
      await PermissionsPlugin.checkPermissions(
          [Permission.WRITE_EXTERNAL_STORAGE]);

  if (permission[Permission.WRITE_EXTERNAL_STORAGE] !=
      PermissionState.GRANTED) {
    try {
      permission = await PermissionsPlugin.requestPermissions(
          [Permission.WRITE_EXTERNAL_STORAGE]);
    } on Exception {
      return false;
    }

    if (permission[Permission.WRITE_EXTERNAL_STORAGE] ==
        PermissionState.GRANTED)
      return true;
    else
      return false;
  } else {
    return true;
  }
}

Future<bool> obtenerPermisosAndroidMic() async {
  Map<Permission, PermissionState> permission =
      await PermissionsPlugin.checkPermissions(
          [Permission.RECORD_AUDIO]);

  if (permission[Permission.RECORD_AUDIO] !=
      PermissionState.GRANTED) {
    try {
      permission = await PermissionsPlugin.requestPermissions(
          [Permission.RECORD_AUDIO]);
    } on Exception {
      return false;
    }

    if (permission[Permission.RECORD_AUDIO] ==
        PermissionState.GRANTED)
      return true;
    else
      return false;
  } else {
    return true;
  }
}

String obtenerIDPlataforma(BuildContext context) {
  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS:
      return '1';
    case TargetPlatform.android:
      return '2';
    default:
      return '1';
  }
}


void compartir(String codigo) async {
    try {
      Directory dir = await getTemporaryDirectory();
      File imagenQR = new File("${dir.path}/${codigo}QR.png");
      if (await imagenQR.exists()) {
        imagenQR.delete();
      }
      await imagenQR.create(recursive: true);
      imagenQR.writeAsBytes(await toQrImageData(codigo));
      ShareExtend.share(imagenQR.path, Platform.isAndroid ? 'image' : 'file');
    } catch (e) {
      print('Ocurrió un error al compartir:\n $e');
    }
  }

  Future<List<int>> toQrImageData(String codigo) async {
    final imageqr = await QrPainter(
            data: codigo,
            version: QrVersions.auto,
            color: Colors.black,
            emptyColor: Colors.white,
            gapless: true)
        .toImageData(350);

    imageTools.Image image = imageTools.Image(450, 530);
    imageTools.fill(image, imageTools.getColor(255, 255, 255));
    imageTools.drawImage(
        image, imageTools.decodePng(imageqr.buffer.asUint8List()),
        dstX: 50, dstY: 40);
    imageTools.drawString(image, imageTools.arial_48, 112, 400, codigo,
        color: imageTools.getColor(0, 0, 0));
    imageTools.drawString(
        image, imageTools.arial_24, 60, 450, 'Presenta este QR en la entrada',
        color: imageTools.getColor(0, 0, 0));
    imageTools.drawString(
        image, imageTools.arial_24, 15, 470, '                    para acceder',
        color: imageTools.getColor(0, 0, 0));
    imageTools.drawString(
        image, imageTools.arial_24, 100, 500, '     www.dostop.mx',
        color: imageTools.getColor(0, 0, 0));

    return imageTools.encodeJpg(image);
  }

