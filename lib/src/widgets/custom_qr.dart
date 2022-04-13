import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CustomQr extends StatelessWidget {
  final String code;
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
    this.fontSize = 28}) : super(key: key);

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
            height: height,
            width: width,
            child: QrImage(
              data: code,
              version: QrVersions.auto,
              size: sizeQRImage,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectableText(
              code,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}