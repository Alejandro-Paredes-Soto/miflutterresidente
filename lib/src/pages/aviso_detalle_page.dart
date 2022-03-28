import 'package:cached_network_image/cached_network_image.dart';
import 'package:dostop_v2/src/models/aviso_model.dart';
import 'package:dostop_v2/src/utils/utils.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

class AvisoDetallePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final aviso = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Aviso'),
      body: _creaBody(context, aviso),
      //floatingActionButton: _creaFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _creaBody(BuildContext context, AvisoModel aviso) {
    return Container(
      margin: EdgeInsets.all(15.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: aviso.idAviso,
                child: Material(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                  elevation: 0,
                  child: Scrollbar(
                    child: ElevatedContainer(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                              utils.fechaCompleta(DateTime.tryParse(aviso.fecha)),
                              style: utils.estiloFechaAviso(12)),
                          SizedBox(height: 5),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    aviso.descripcion,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                  Visibility(
                                    visible: aviso.descripcion.isNotEmpty && aviso.imgAviso.isNotEmpty,
                                    child: SizedBox(height: 25)),
                                   _imagenAviso(aviso.idAviso, validaImagenes([aviso.imgAviso]))
                                ],
                              ),
                            ),
                          ),
                          
                         
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                    width: 100,
                    alignment: Alignment.center,
                    height: 60,
                    child: Text(
                      'Cerrar',
                      style: utils.estiloBotones(12),
                    )),
                onPressed: () => Navigator.pop(context))
          ],
        ),
      ),
    );
  }

  Widget _imagenAviso(String id, List<String> imagenes) {
    print(imagenes.length);
    if (imagenes.length == 0)
      return Container();
    else
      return Column(
        children: <Widget>[
          Container(
              height: 500,
              child: Swiper(
                  loop: false,
                  itemCount: imagenes.length,
                  pagination: imagenes.length > 1
                      ? SwiperPagination(
                          margin: EdgeInsets.all(2),
                          alignment: Alignment.bottomCenter,
                          builder: DotSwiperPaginationBuilder(
                              color: Colors.white60,
                              activeColor: Colors.white60,
                              activeSize: 20.0))
                      : null,
                  scale: 0.85,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: PinchZoomImage(
                        image: ClipRRect(
                          //borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  Image.asset(utils.rutaGifLoadRed),
                              errorWidget: (context, url, error) => Container(
                                  height: 240,
                                  child:
                                      Center(child: Icon(Icons.broken_image))),
                              imageUrl: imagenes[index],
                              fit: BoxFit.scaleDown,
                              fadeInDuration: Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                      ),
                      onLongPress: () {
                        HapticFeedback.vibrate();
                        descargaImagen(context, imagenes[index]);
                      },
                    );
                  }),
            ),
          
        ],
      );
  }
}
