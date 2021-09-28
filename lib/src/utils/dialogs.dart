import 'package:auto_size_text/auto_size_text.dart';
import 'package:dostop_v2/src/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void creaDialogSimple(BuildContext context, String titulo, String contenido,
    String textOpcionOK, Function funcionOK) {
  showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: new Text(titulo),
          content: new Text(contenido),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(textOpcionOK),
              onPressed: funcionOK,
            ),
          ],
        );
      });
}

creaDialogProgress(BuildContext context, String titulo) {
  showCupertinoDialog(
      // barrierDismissible: false, //NO OLVIDAR REMOVER EL COMENTARIO - ESTA DISPONIBLE EN NUEVAS VERSIONES DE SDK DE FLUTTER >= 1.12.13H5
      // useRootNavigator: true, //NO OLVIDAR REMOVER EL COMENTARIO - ESTA DISPONIBLE EN NUEVAS VERSIONES DE SDK DE FLUTTER >= 1.12.13H5
      context: context,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: CupertinoAlertDialog(
            title: Text(titulo),
            content: CupertinoActivityIndicator(
              radius: 20,
            ),
          ),
        );
      });
}

creaDialogBloqueo(BuildContext context, String titulo, String mensaje) {
  showCupertinoDialog(
      // barrierDismissible: false, //NO OLVIDAR REMOVER EL COMENTARIO - ESTA DISPONIBLE EN NUEVAS VERSIONES DE SDK DE FLUTTER >= 1.12.13H5
      // useRootNavigator: true, //NO OLVIDAR REMOVER EL COMENTARIO - ESTA DISPONIBLE EN NUEVAS VERSIONES DE SDK DE FLUTTER >= 1.12.13H5
      context: context,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: CupertinoAlertDialog(
              title: Text(titulo, style: TextStyle(fontSize: 24)),
              content: Column(
                children: [
                  Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  Text(
                    mensaje,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              )),
        );
      });
}

creaDialogWidget(BuildContext context, String titulo, Widget widget,
    String textOpcionOK, Function funcionOK) {
  showCupertinoDialog(
      context: context,
      builder: (ctx) => ButtonBarTheme(
            data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
            child: AlertDialog(
              contentPadding: EdgeInsets.all(10.0),
              scrollable: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              content: Builder(
                  builder: (context) => Container(
                      color: Colors.transparent,
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget,
                              Text(
                                titulo,
                                textScaleFactor: 1.05,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ))),
              actions: [
                FlatButton(
                  child: Text(
                    textOpcionOK,
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: funcionOK,
                ),
              ],
            ),
          ));
}

void creaDialogYesNo(
    BuildContext context,
    String titulo,
    String contenido,
    String textOpcionPos,
    String textOpcionNeg,
    Function funcionPos,
    Function funcionNeg) {
  showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: new Text(titulo),
          content: new Text(contenido),
          actions: <Widget>[
            CupertinoDialogAction(
              //isDefaultAction: true,
              child: Text(textOpcionPos),
              onPressed: funcionPos,
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(textOpcionNeg),
              onPressed: funcionNeg,
            )
          ],
        );
      });
}

void creaDialogYesNoAlt(
    BuildContext context,
    String titulo,
    String contenido,
    String textOpcionPos,
    String textOpcionNeg,
    Function funcionPos,
    Function funcionNeg) {
  showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: CupertinoAlertDialog(
            title: new Text(titulo),
            content: new Text(contenido),
            actions: <Widget>[
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text(textOpcionPos),
                onPressed: funcionPos,
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(textOpcionNeg),
                onPressed: funcionNeg,
              )
            ],
          ),
        );
      });
}

void creaDialogQR(
    BuildContext context,
    String titulo,
    Widget contenido,
    String textOpcionPos,
    String textOpcionNeg,
    Function funcionPos,
    Function funcionNeg) {
  showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          backgroundColor: colorFondoTarjetaFreq,
          contentPadding: EdgeInsets.all(0),
          content: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      rutaFondoQR,
                      fit: BoxFit.fill,
                    )),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: contenido),
                      SizedBox(height: 20),
                      Flexible(
                        child: RaisedButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: AutoSizeText(
                              textOpcionPos,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: estiloBotones(13, color: Colors.black),
                            ),
                          ),
                          onPressed: funcionPos,
                        ),
                      ),
                      SizedBox(height: 20),
                      Flexible(
                        child: RaisedButton(
                          color: colorPrincipal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: AutoSizeText(
                              textOpcionNeg,
                              maxLines: 1,
                              style: estiloBotones(13),
                            ),
                          ),
                          onPressed: funcionNeg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
