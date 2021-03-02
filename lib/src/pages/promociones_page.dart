import 'package:dostop_v2/src/models/promo_model.dart';
import 'package:dostop_v2/src/providers/promociones_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';

class PromocionesPage extends StatefulWidget {
  @override
  _PromocionesPageState createState() => _PromocionesPageState();
}

class _PromocionesPageState extends State<PromocionesPage> {
  final _prefs = PreferenciasUsuario();
  final promoProvider = PromocionesProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Promociones'),
      body: _creaBody(),
    );
  }

  // Widget _creaAppBar() {
  //   return AppBar(
  //     title: Text(
  //       'Promociones',
  //       style: TextStyle(
  //           fontSize: 40, color: Colors.black, fontWeight: FontWeight.bold),
  //     ),
  //     elevation: 0.0,
  //     centerTitle: false,
  //   );
  // }

  Widget _creaBody() {
    return FutureBuilder(
      future: promoProvider.cargaPromociones(_prefs.usuarioLogged),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if(snapshot.data.length>0){
          return Container(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) =>
                    _crearItem(context, snapshot.data[index])),
          );
          }else{
            return Center(
              child: Text('Pronto tendremos las mejores promociones para ti', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
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

  Widget _crearItem(BuildContext context, PromocionModel promo) {
    return Container(
      child: GestureDetector(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FadeInImage(
                image: NetworkImage(
                  promo.ruta1,
                ),
                placeholder: AssetImage(utils.rutaGifLoadBanner),
              )),
        ),
        onTap: () =>
            Navigator.of(context).pushNamed('promoDetalle', arguments: promo),
      ),
    );
  }
}
