import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'countdown_timer.dart';

class CustomQr extends StatefulWidget {
  final String code;
  final DateTime date;
  final double sizeQRImage;
  final double height;
  final double width;
  final double fontSize;

  const CustomQr({
    Key key, 
    @required this.code, 
    this.sizeQRImage = 100, 
    this.height = 200, 
    this.width = 200, 
    this.fontSize = 28, this.date = null}) : super(key: key);

  @override
  _CustomQrState createState() => _CustomQrState();
}

class _CustomQrState extends State<CustomQr> {
  bool _tiempoVencido = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            height: widget.height,
            width: widget.width,
            child: QrImage(
              data: widget.code,
              version: QrVersions.auto,
              size: widget.sizeQRImage,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectableText(
              widget.code,
              style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          Visibility(
            visible: widget.date != null,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 10),
              child: !_tiempoVencido && widget.date != null ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Vence en:', style: utils.estiloBotones(15,
                          color: utils.colorPrincipal)),
                  CountdownTimer(
                    mainAxisSize: MainAxisSize.min,
                    showZeroNumbers: false,
                    endTime: widget.date.millisecondsSinceEpoch,
                    minSymbol: 'm',
                    secSymbol: 's',
                    textStyle: utils.estiloBotones(15,
                        color: Colors.black),
                    onEnd: () => setState(() => _tiempoVencido = true)
                  ),
                ],
              ) : Text(
                'Código vencido',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: utils.colorToastRechazada,
                    fontSize: 15,
                    fontWeight: FontWeight.bold))
            ),)
        ],
      ),
    );
  }
}