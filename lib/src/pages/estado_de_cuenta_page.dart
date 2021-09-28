import 'package:auto_size_text/auto_size_text.dart';
import 'package:dostop_v2/src/widgets/custom_tabbar.dart';
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
  int _tabIndex = 0;

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

  Widget _creaTabs() {
    return Container(
      height: 60,
      child: CustomTabBar(
        Theme.of(context).brightness == Brightness.light
            ? utils.colorFondoPrincipalDark
            : utils.colorFondoTabs,
        utils.colorAcentuado,
        [
          Container(
              child: Text(
            '\nIngresos\n',
            textAlign: TextAlign.center,
            style: utils.estiloBotones(15),
          )),
          Container(
              child: Text(
            '\nEgresos\n',
            textAlign: TextAlign.center,
            style: utils.estiloBotones(15),
          ))
        ],
        () => _tabIndex,
        (index) {
          setState(() {
            _tabIndex = index;
          });
        },
        allowExpand: true,
        outerVerticalPadding: 40,
        borderRadius: BorderRadius.circular(15.0),
      ),
    );
  }

  Widget _creaBody() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: _saldo != ''
                    ? !_saldo.contains('-')
                        ? utils.colorPrincipal
                        : utils.colorToastRechazada
                    : Colors.black12,
              ),
              child: Center(
                widthFactor: 2,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Saldo actual:', style: utils.estiloBotones(15)),
                      AutoSizeText(
                        '$_saldo ',
                        maxLines: 1,
                        style: utils.estiloBotones(25),
                      )
                    ]),
              ),
            ),
            SizedBox(height: 30),
            _creaTabs(),
            SizedBox(height: 30),
            // _creaPagesCuentas(),
            Expanded(
              child: AnimatedCrossFade(
                crossFadeState: _tabIndex == 0
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: AnimatedContainer(
                    height: _tabIndex == 0 ? 0 : null,
                    child: _crearLista(_obtenerEgresos, _pageCuentasEgCtrl),
                    duration: Duration(milliseconds: 200)),
                secondChild: AnimatedContainer(
                    height: _tabIndex != 0 ? 0 : null,
                    child: _crearLista(_obtenerIngresos, _pageCuentasInCtrl),
                    duration: Duration(milliseconds: 200)),
                duration: Duration(milliseconds: 200),
              ),
            ),
          ],
        ));
  }

  Widget _crearLista(
      Future<List<CuentaModel>> future, PageController controller) {
    return FutureBuilder(
      future: future,
      builder:
          (BuildContext context, AsyncSnapshot<List<CuentaModel>> snapshot) {
        if (snapshot.hasData) if (snapshot.data.length > 0) {
          int _totalPaginas = snapshot.data.length;
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
                        if (controller.page < _totalPaginas - 1)
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
                        if (controller.page > 0)
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
        SizedBox(height: 20),
        Expanded(
          child: item.list.length == 0
              ? Container(
                  padding: EdgeInsets.only(
                    top: 50,
                  ),
                  child: Text('No hay movimientos',
                      style: TextStyle(fontSize: 16)))
              : ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: item.list.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      title: Text(item.list[index].concepto,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900)),
                      subtitle: item.list[index].nombreProv == ''
                          ? null
                          : Text(
                              item.list[index].nombreProv,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                      trailing: Text('\$${item.list[index].monto}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
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
