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
                  Icon(Icons.lock, size: 100,),
                  Text(mensaje, style: TextStyle(fontSize: 20),),

                ],
              )),
        );
      });
}

creaDialogWidget(BuildContext context, String titulo, Widget widget,
    String textOpcionOK, Function funcionOK) {
  showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(titulo),
          content: widget,
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

void creaDialogEncuesta(
    BuildContext context,
    String titulo,
    String textOpcionPos,
    String textOpcionNeg,
    Function funcionPos,
    Function funcionNeg) {
  showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: new Text(titulo),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(textOpcionPos),
              onPressed: funcionPos,
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(textOpcionNeg),
              onPressed: funcionNeg,
            ),
            CupertinoDialogAction(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
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
        return CupertinoAlertDialog(
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
        );
      });
}

void creaDialogImagen(
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
          contentPadding: EdgeInsets.all(10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              contenido,
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: RaisedButton(
                      color: colorPrincipal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        textOpcionPos,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: estiloBotones(13),
                      ),
                      onPressed: funcionPos,
                    ),
                  ),
                  Flexible(
                    child: RaisedButton(
                      color: colorSecundario,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        textOpcionNeg,
                        softWrap: false,
                        style: estiloBotones(13),
                      ),
                      onPressed: funcionNeg,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      });
}
