import 'package:flutter/material.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;

class MisAccesosPage extends StatefulWidget {
  @override
  _MisAccesosPageState createState() => _MisAccesosPageState();
}

class _MisAccesosPageState extends State<MisAccesosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Mis accesos'),
      body: _creaBody(),
    );
  }

  Widget _creaBody() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(15),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(Icons.arrow_circle_up, color: utils.colorContenedorSaldo,),
                  title: Text('Vehiculo'),
                  subtitle: Text('Nissan Versa GMB1232'),
                  trailing: Text('2020-03-03 12:44:00'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.arrow_circle_down, color: utils.colorPrincipal,),
                  title: Text('Vehiculo'),
                  subtitle: Text('Nissan Versa GMB1232'),
                  trailing: Text('2020-03-03 12:44:00'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
