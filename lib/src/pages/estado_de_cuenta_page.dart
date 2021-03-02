import 'package:dostop_v2/src/providers/estado_de_cuenta_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';

class EstadoDeCuentaPage extends StatefulWidget {
  @override
  _EstadoDeCuentaPageState createState() => _EstadoDeCuentaPageState();
}

class _EstadoDeCuentaPageState extends State<EstadoDeCuentaPage> {
  final estadoDeCuentaProvider = EstadoDeCuentaProvider();
  final _prefs = PreferenciasUsuario();
  final _pageCuentasEgCtrl = PageController();
  final _pageCuentasInCtrl = PageController();
  Future<List<CuentaModel>> _obtenerEgresos;
  Future<List<CuentaModel>> _obtenerIngresos;
  String _saldo = '';
  bool _cambiaEstados = false;
  @override
  void initState() {
    super.initState();
    estadoDeCuentaProvider
        .obtenerSaldoTotal(_prefs.usuarioLogged)
        .then((saldo) {
      setState(() {
        _saldo = saldo;
      });
      _obtenerEgresos =
          estadoDeCuentaProvider.obtenerEgresos(_prefs.usuarioLogged);
      _obtenerIngresos =
          estadoDeCuentaProvider.obtenerIngresos(_prefs.usuarioLogged);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Edo. de Cuenta'),
      body: _creaBody(),
    );
  }


  Widget _creaBody() {
    return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: _saldo != ''
                      ? !_saldo.contains('-')
                          ? utils.colorContenedorSaldo
                          : utils.colorPrincipal
                      : Colors.black12,
                ),
                margin: EdgeInsets.symmetric(horizontal: 80),
                alignment: Alignment.center,
                width: double.infinity,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                      text: 'Saldo actual:\n',
                      style: TextStyle(
                          color: _saldo != '' ? Colors.white : Colors.grey,
                          fontSize: 15),
                    ),
                    TextSpan(
                      text: '$_saldo',
                      style: utils.estiloBotones(18),
                    )
                  ]),
                )),
            SizedBox(height: 20),
            _creaTabsCuentas(),
            SizedBox(height: 20),
            // _creaPagesCuentas(),
            Expanded(
              child: AnimatedCrossFade(
                crossFadeState: _cambiaEstados
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: AnimatedContainer(
                    height: _cambiaEstados ? 0 : null,
                    child: _crearLista(_obtenerEgresos, _pageCuentasEgCtrl),
                    duration: Duration(milliseconds: 200)),
                secondChild: AnimatedContainer(
                    height: !_cambiaEstados ? 0 : null,
                    child: _crearLista(_obtenerIngresos, _pageCuentasInCtrl),
                    duration: Duration(milliseconds: 200)),
                duration: Duration(milliseconds: 200),
              ),
            ),
          ],
        ));
  }

  Widget _creaTabsCuentas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: FlatButton(
            color: !_cambiaEstados ? utils.colorSecundarioToggle : Colors.transparent,
            child: Container(
                alignment: Alignment.center,
                height: 50,
                child: Text('Egresos', style: TextStyle(fontSize: 18))),
            onPressed: () {
              setState(() {
                _cambiaEstados = false;
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          height: 30,
          width: 1,
          color: Colors.grey,
        ),
        Expanded(
          child: FlatButton(
            color: _cambiaEstados ? utils.colorSecundarioToggle : Colors.transparent,
            child: Container(
                alignment: Alignment.center,
                height: 50,
                child: Text('Ingresos', style: TextStyle(fontSize: 18))),
            onPressed: () {
              setState(() {
                _cambiaEstados = true;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _crearLista(
      Future<List<CuentaModel>> future, PageController controller) {
    return FutureBuilder(
      future: future,
      builder:
          (BuildContext context, AsyncSnapshot<List<CuentaModel>> snapshot) {
        if (snapshot.hasData) if (snapshot.data.length > 0) {
            int _totalPaginas=snapshot.data.length;
          return Stack(
            children: <Widget>[
              PageView.builder(
                  controller: controller,
                  reverse: true,
                  itemCount: _totalPaginas,
                  itemBuilder: (context, index) {
                    return _creaItem(context, snapshot.data[index]);
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      setState(() {
                        if(controller.page<_totalPaginas-1)
                        controller.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      setState(() {
                        if(controller.page>0)
                        controller.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      });
                    },
                  )
                ],
              ),
            ],
          );
        } else {
          return Center(
            child: Text('No hay información', style: TextStyle(fontSize: 16)),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _creaItem(BuildContext context, CuentaModel item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(item.mes,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(item.anio, style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),
        Text('Total del mes:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('\$${item.tipoCuentaMes}', style: TextStyle(fontSize: 16)),
        Expanded(
          child: item.list.length == 0
              ? Container(
                  padding: EdgeInsets.only(top: 50,),
                  child: Text('No hay movimientos',
                      style: TextStyle(fontSize: 16)))
              : ListView.builder(
                  itemCount: item.list.length,
                  itemExtent: 70,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: Colors.black12)),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        title: Text(
                          item.list[index].concepto,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${item.list[index].nombreProv}', softWrap: false, overflow: TextOverflow.visible,),
                        trailing: Text('\$${item.list[index].monto}',
                            style: TextStyle(fontSize: 15)),
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _pageCuentasEgCtrl.dispose();
    _pageCuentasInCtrl.dispose();
    super.dispose();
  }
}
