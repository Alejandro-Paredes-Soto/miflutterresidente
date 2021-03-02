import 'dart:io';
import 'package:image/image.dart' as imageTools;
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_extend/share_extend.dart';

import 'package:dostop_v2/src/widgets/countdown_timer.dart';
import 'package:dostop_v2/src/models/visitante_freq_model.dart';
import 'package:dostop_v2/src/providers/visitantes_frecuentes_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class VisitantesFrecuentesPage extends StatefulWidget {
  @override
  _VisitantesFrecuentesPageState createState() =>
      _VisitantesFrecuentesPageState();
}

class _VisitantesFrecuentesPageState extends State<VisitantesFrecuentesPage> {
  final _prefs = PreferenciasUsuario();
  final visitanteProvider = VisitantesFreqProvider();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'V. Frecuentes'),
      body: _creaBody(),
      floatingActionButton: _creaFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // bottomNavigationBar: _creaBoton(),
    );
  }

  Widget _creaBody() {
    return FutureBuilder(
      future: visitanteProvider.cargaVisitantesFrecuentes(_prefs.usuarioLogged),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Container(
              padding: EdgeInsets.only(bottom: 70),
              child: ListView.builder(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) =>
                      _crearItem(context, snapshot.data[index])),
            );
          } else {
            return Center(
              child: Text(
                'No hay visitantes frecuentes registrados',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _crearItem(BuildContext context, VisitanteFreqModel visitante) {
    return Column(
      children: <Widget>[
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          //color: utils.colorFondoTarjeta,
          elevation: 3,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Nombre', style: estiloTituloTarjeta(11)),
                    Text(visitante.unico?'Único':'', textAlign: TextAlign.right,style: TextStyle(fontWeight: FontWeight.bold,color: colorPrincipal)),
                  ],
                ),
                Text(
                  '${visitante.nombre}',
                  style: estiloSubtituloTarjeta(17),
                ),
                SizedBox(height: 15),
                Text('Vence en:', style: estiloTituloTarjeta(11)),
                // Text(
                //   '${DateFormat('dd-MM-yyyy kk:mm').format(visitante.fechaAlta)}',
                //   style: estiloSubtituloTarjeta(17),
                // ),
                visitante.vigencia.isBefore(DateTime.now().add(Duration(days: 31)))?
                CountdownTimer(
                  endTime: visitante.vigencia.millisecondsSinceEpoch,
                  defaultDays: '0',
                  defaultHours: '00',
                  defaultMin: '00',
                  defaultSec: '00',
                  daysSymbol: " dias ",
                  hoursSymbol: "h ",
                  minSymbol: "m ",
                  secSymbol: "s",
                  // daysTextStyle: TextStyle(fontSize: 20, color: Colors.red),
                  // hoursTextStyle: TextStyle(fontSize: 30, color: Colors.orange),
                  // minTextStyle:
                  //     TextStyle(fontSize: 40, color: Colors.lightBlue),
                  // secTextStyle: TextStyle(fontSize: 50, color: Colors.pink),
                  // daysSymbolTextStyle:
                  //     TextStyle(fontSize: 25, color: Colors.green),
                  // hoursSymbolTextStyle:
                  //     TextStyle(fontSize: 35, color: Colors.amberAccent),
                  // minSymbolTextStyle:
                  //     TextStyle(fontSize: 45, color: Colors.black),
                  // secSymbolTextStyle:
                  //     TextStyle(fontSize: 55, color: Colors.deepOrange),
                ):Text('Tiempo Indefinido'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: colorPrincipal,
                      child: Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: Text(
                          'Ver Código',
                          style: estiloBotones(13),
                        ),
                      ),
                      onPressed: () {
                        creaDialogImagen(
                            context,
                            '',
                            _creaQR(visitante.codigo),
                            'Compartir',
                            'Cancelar',
                            () => _compartir(visitante.codigo),
                            () => Navigator.pop(context));
                      },
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: colorSecundario,
                      child: Container(
                          width: 80,
                          alignment: Alignment.center,
                          child: Text(
                            'Eliminar',
                            softWrap: false,
                            style: estiloBotones(13),
                          )),
                      onPressed: () {
                        _eliminaVisitanteFreq(context, visitante);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget _creaQR(String codigo) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          height: 200,
          width: 200,
          child: QrImage(
            data: codigo,
            version: QrVersions.auto,
            size: 100,
          ),
        ),
        SelectableText(
          codigo,
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        )
      ],
    );
  }

  _compartir(String codigo) async {
    try {
      Directory dir = await pathProvider.getTemporaryDirectory();
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

  void _eliminaVisitanteFreq(
      BuildContext context, VisitanteFreqModel visitante) {
    creaDialogYesNoAlt(
        context,
        'Confirmar',
        '¿Estas seguro que deseas eliminar al visitante \'${visitante.nombre}\'?\n\nSi lo haces, se le volverá a pedir confirmación de tu domicilio',
        'Eliminar',
        'Cancelar', () async {
      Navigator.pop(context);
      Map estatus = await visitanteProvider
          .eliminaVisitanteFrecuente(visitante.idFrecuente);
      switch (estatus['OK']) {
        case 1:
          setState(() {});
          Scaffold.of(context).showSnackBar(
              creaSnackBarIcon(Icon(Icons.delete), 'Visitante eliminado', 5));
          break;
        case 2:
          Scaffold.of(context).showSnackBar(creaSnackBarIcon(
              Icon(Icons.error), 'No se pudo eliminar al visitante', 5));
          break;
      }
    }, () {
      Navigator.pop(context);
    });
  }

  _creaFAB(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      width: double.infinity,
      height: 50,
      child: FloatingActionButton(
          child: Text(
            'Nuevo',
            style: estiloBotones(18),
          ),
          elevation: 2,
          highlightElevation: 4,
          backgroundColor: colorPrincipal,
          onPressed: () {
            _navegaPaginaRespuesta(context);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    );
  }

  _navegaPaginaRespuesta(BuildContext context) async {
    final result =
        await Navigator.of(context).pushNamed('NuevoVisitFreq') ?? false;
    if (result) {
      setState(() {});
      Future.delayed(Duration(milliseconds: 500), () {
        Scaffold.of(context).showSnackBar(creaSnackBarIcon(
            SvgPicture.asset(rutaIconoVisitantesFrecuentes,
                height: tamanoIcoSnackbar, color: Colors.white),
            'Visitante frecuente creado',
            5));
      });
    }
  }
}
