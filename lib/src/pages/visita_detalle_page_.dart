// import 'dart:io';
// import 'dart:typed_data';

// import 'package:dostop_v2/src/models/visita_model.dart';
// import 'package:dostop_v2/src/utils/utils.dart' as utils;
// import 'package:flutter_svg/svg.dart';

// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:flutter_swiper/flutter_swiper.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:http/http.dart' as http;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

// class VisitaDetallePage extends StatefulWidget {
//   @override
//   _VisitaDetallePageState createState() => _VisitaDetallePageState();
// }

// class _VisitaDetallePageState extends State<VisitaDetallePage> {
//   bool _reporteEnviado = false;
//   VisitaModel _visita;
//   @override
//   Widget build(BuildContext context) {
//     _visita = ModalRoute.of(context).settings.arguments;
//     return Scaffold(
//       appBar: utils.appBarLogoD(titulo: 'Visita'),
//       body: _creaBody(_visita, context),
//       floatingActionButton:
//           _creaFABIncidente(context, [_visita.idVisitas, _visita.visitante], _visita.reporte=='1'||_reporteEnviado),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }

//   Widget _creaBody(VisitaModel visita, BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             visita.fechaEntrada.isNotEmpty && visita.fechaEntrada != null
//                 ? '${utils.fechaCompleta(DateTime.parse(visita.fechaEntrada))} ${visita.horaEntrada}'
//                 : '',
//             style: utils.estiloTextoAppBar(26),
//           ),
//           SizedBox(height: 10),
//           Text(
//             visita.fechaSalida.isNotEmpty && visita.fechaSalida != null
//                 ? 'Salida: ${utils.fechaCompleta(DateTime.parse(visita.fechaSalida))} ${visita.horaSalida}'
//                 : '',
//             style: TextStyle(fontSize: 18),
//           ),
//           SizedBox(height: 20),
//           _imagenesVisitante(
//               visita.idVisitas,
//               utils.validaImagenes(
//                   [visita.imgRostro, visita.imgId, visita.imgPlaca])),
//           SizedBox(height: 30),
//           _datosVisitante(visita, context),
//         ],
//       ),
//     );
//   }

//   Widget _imagenesVisitante(String id, List<String> imagenes) {
//     if (imagenes.length == 0)
//       return Container(
//         height: 240,
//         child: Center(child: Text('No hay imagenes para mostrar')),
//       );
//     else
//       return Column(
//         children: <Widget>[
//           Hero(
//             tag: id,
//             child: Container(
//               height: 220,
//               child: Swiper(
//                   loop: false,
//                   itemHeight: 240,
//                   itemCount: imagenes.length,
//                   pagination: imagenes.length > 1
//                       ? SwiperPagination(
//                           margin: EdgeInsets.all(2),
//                           alignment: Alignment.topCenter)
//                       : null,
//                   scale: 0.85,
//                   itemBuilder: (BuildContext context, int index) {
//                     return GestureDetector(
//                       child: PinchZoomImage(
//                         image: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Container(
//                             width: double.infinity,
//                             child: CachedNetworkImage(
//                               height: 220,
//                               placeholder: (context, url) =>
//                                   Image.asset(utils.rutaGifLoadRed),
//                               errorWidget: (context, url, error) => Container(
//                                   height: 240,
//                                   child:
//                                       Center(child: Icon(Icons.broken_image))),
//                               imageUrl: imagenes[index],
//                               fit: BoxFit.cover,
//                               fadeInDuration: Duration(milliseconds: 300),
//                             ),
//                           ),
//                         ),
//                       ),
//                       onLongPress: () {
//                         HapticFeedback.vibrate();
//                         _descargaImagen(context, imagenes[index]);
//                       },
//                     );
//                   }),
//             ),
//           ),
//           SizedBox(height: 0),
//           Text(
//               'Mantén presionada cualquier imagen para guardarla en tu galería.'),
//         ],
//       );
//   }

//   Widget _datosVisitante(VisitaModel visita, BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         AnimatedCrossFade(
//           duration: Duration(milliseconds: 300),
//           crossFadeState: visita.codigo != ''
//               ? CrossFadeState.showSecond
//               : CrossFadeState.showFirst,
//           firstChild: Container(
//               child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: <Widget>[
//               Icon(
//                 Icons.brightness_1,
//                 color: getColorEstatus(visita.estatus),
//                 size: 18,
//               ),
//               SizedBox(
//                 width: 2,
//               ),
//               Text('${visita.estatus}',
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: getColorEstatus(visita.estatus),
//                   )),
//             ],
//           )),
//           secondChild: Container(
//               child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: <Widget>[
//               SvgPicture.asset(
//                 utils.rutaIconoVisitantesFrecuentes,
//                 height: utils.tamanoIcoNavBar,
//                 color: Theme.of(context).iconTheme.color,
//               ),
//               // SizedBox(
//               //   width: 5,
//               // ),
//               // Text('V. Frecuente',
//               //     style: TextStyle(
//               //       fontSize: 18,
//               //     )),
//             ],
//           )),
//         ),
//         SizedBox(height: 5),
//         Text('Nombre',
//             style: TextStyle(
//               color: utils.colorPrincipal,
//               fontSize: 17,
//             )),
//         Text(visita.visitante,
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         SizedBox(
//           height: 30,
//         ),
//         Text('Placas',
//             style: TextStyle(
//               color: utils.colorPrincipal,
//               fontSize: 17,
//             )),
//         Text(visita.placa,
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         SizedBox(height: 5),
//         Text('Vehículo',
//             style: TextStyle(
//               color: utils.colorPrincipal,
//               fontSize: 17,
//             )),
//         Text(visita.modelo,
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         SizedBox(height: 5),
//         Text('Marca',
//             style: TextStyle(
//               color: utils.colorPrincipal,
//               fontSize: 17,
//             )),
//         Text(visita.marca,
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         SizedBox(height: 5),
//         Text(visita.codigo == '' ? 'Motivo' : '',
//             style: TextStyle(
//               color: utils.colorPrincipal,
//               fontSize: 17,
//             )),
//         Text(visita.codigo == '' ? visita.motivoVisita : '',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         SizedBox(height: 60)
//       ],
//     );
//   }

//   Widget _creaFABIncidente(BuildContext context, List<String> datos, bool reporte) {
//     return FloatingActionButton.extended(
//         backgroundColor: utils.colorPrincipal,
//         icon: Icon(!reporte ? Icons.report : Icons.chat),
//         label: Text(!reporte ? 'Reportar Incidente' : 'Ver reporte'),
//         onPressed: () => !_reporteEnviado
//             ? _abrirReportePage(context, datos)
//             : Navigator.of(context)
//                 .pushNamed('SeguimientoInc', arguments: datos),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
//   }

//   _abrirReportePage(BuildContext context, List<String> datos) async {
//     final result =
//         await Navigator.of(context).pushNamed('Incidente', arguments: datos) ??
//             false;
//     if (result)
//       setState(() {
//         _reporteEnviado = result;
//       });
//   }
// }

// void _descargaImagen(BuildContext context, String url) async {
//   Scaffold.of(context).showSnackBar(
//       utils.creaSnackBarIcon(Icon(Icons.cloud_download), 'Descargando...', 1));
//   try {
//     if (Platform.isAndroid) {
//       if (!await utils.obtenerPermisosAndroid())
//         throw 'No tienes permisos de almacenamiento';
//     }
//     var res = await http.get(url);
//     await ImageGallerySaver.saveImage(Uint8List.fromList(res.bodyBytes));
//     // print(result);
//     Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
//         Icon(Icons.file_download), 'Imagen guardada', 2));
//   } catch (e) {
//     Scaffold.of(context).showSnackBar(utils.creaSnackBarIcon(
//         Icon(Icons.error), 'La imagen no pudo ser guardada', 2));
//   }
// }

// Color getColorEstatus(String estatus) {
//   switch (estatus) {
//     case 'Aceptada':
//       return Colors.green;
//     case 'Rechazada':
//       return Colors.red;
//     // case 'Sin Respuesta':
//     //   return Colors.amber;
//     default:
//       return Colors.grey;
//   }
// }
