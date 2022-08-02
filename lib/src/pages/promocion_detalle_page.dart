import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dostop_v2/src/models/promo_model.dart';
import 'package:dostop_v2/src/providers/login_validator.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
class PromocionDetallePage extends StatelessWidget {
  final _validaSesion = LoginValidator();
  @override
  Widget build(BuildContext context) {
    _validaSesion.verificaSesion();
    final query = MediaQuery.of(context).size;
    final promo = ModalRoute.of(context)!.settings.arguments as PromocionModel;
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Promoción'),
      body: _creaBody(promo, query),
    );
  }

  Widget _creaBody(PromocionModel promo, Size query) {
    return Container(
      padding: EdgeInsets.all(15.0),
      alignment: Alignment.center,
      child: PinchZoomImage(
        image: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: CachedNetworkImage(
            height: (query.height * 0.85),
            imageUrl: promo.ruta2,
            placeholder: (context, url) => Image.asset(utils.rutaGifLoadRed),
            errorWidget: (context, url, error) => Container(
                height: 200, child: Center(child: Icon(Icons.broken_image))),
            fit: BoxFit.contain,
            fadeInDuration: Duration(milliseconds: 400),
          ),
        ),
      ),
    );
  }
}
