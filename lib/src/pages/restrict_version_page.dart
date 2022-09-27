import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart' as utils;
import 'package:store_redirect/store_redirect.dart';

class RestrictVersionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Text(
                'Actualizar Dostop',
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    color: Colors.black),
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
                child: Icon(
              Icons.download_for_offline_rounded,
              size: 200,
              color: utils.colorPrincipal,
            )),
            SizedBox(height: 50),
            Container(
              child: Center(
                child: Text(
                  'Hola, actualmente usas una versión antigua de la aplicación, para poder seguir usando nuestros servicios y brindarte la mejor atención es necesario que actualices a la última versión disponible.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 50),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  primary: utils.colorAcentuado,
                ),
                onPressed: () => StoreRedirect.redirect(
                    androidAppId: 'com.dostop.dostop',
                    iOSAppId: 'com.DostopApp.Dostop'),
                child: Container(
                  height: 50,
                  width: 200,
                  alignment: Alignment.center,
                  child: Text(
                    'Actualizar',
                    style: utils.estiloBotones(20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
