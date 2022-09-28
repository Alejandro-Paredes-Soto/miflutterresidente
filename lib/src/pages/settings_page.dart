
import 'dart:developer';
import 'dart:io';

import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart' as toast;
import 'package:package_info_plus/package_info_plus.dart';


import '../../main.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _notificationProvider = NotificacionesProvider();


  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    bool _enabled = true;
    if(Platform.isIOS){
      _enabled = false;
      setState(() {});
    }
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Configuración'),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Tema'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: (){},
                  child: Row(
                    children: [
                       _option(Icons.dark_mode ,'Modo oscuro')
                    ],
                  ),
                ),
                CupertinoSwitch(
                    value: _isDarkMode,
                    onChanged: (bool value) {
                      _isDarkMode = value;
                      MyApp.of(context)!.changeTheme();
                      setState(() {});
                    }),
              ],
            ),
            const SizedBox(height: 30),
            _title('Notificaciones'),      
            TextButton(
                onPressed:
                 _enabled == false 
                  ? null
                  : _notificationChannel,
               
                child: _enabled == false
                   ?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _option(Icons.notifications_outlined, 'Restablecer configuración', _enabled),
                       Padding(
                         padding: const EdgeInsets.only(left: 40),
                         child: Text('(Solo para dispositivos Android)', style: TextStyle(fontSize: 12, color: Colors.grey),),
                       )
                     ],
                   )
                    :_option(Icons.notifications_outlined, 'Restablecer configuración'),
              ),
            const SizedBox(height: 50),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => utils.abrirPaginaWeb(
                      url: 'https://dostop.mx/aviso-de-privacidad.html'),
                  child: Row(
                    children: [
                      Text('Aviso de privacidad\nTérminos y condiciones',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .color)),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: PackageInfo.fromPlatform(),
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    if (snapshot.hasData)
                      return
                        Text('DostopV ${snapshot.data.version}',
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).textTheme.bodyText2!.color));
                    else
                      return 
                        Text('Dostop');
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String title) {
    return Text(title,
        style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Theme.of(context).textTheme.bodyText2!.color));
  }

  Widget _option(icon, String option, [bool? enabled]) {
    Color color;
    enabled == false
    ? color = Colors.grey
    : color = Theme.of(context).textTheme.bodyText2!.color!;
    return Row(
      children: [
        Icon(icon,
            size: 30, color: color),
        const SizedBox(width: 10),
        Text(option,
            style: TextStyle(
                fontSize: 16,
                color: color
                )
                ),
      ],
    );
  }

  _cupertinoIndicator(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoActivityIndicator(
            animating: true,
            radius: 25,
            color: Colors.white,
          );
        });
  }

  _newChannelReady() {
    toast.showToast('Configuración restablecida',
        context: context,
        textStyle: const TextStyle(fontSize: 24, color: Colors.white),
        backgroundColor: utils.colorPrincipal,
        borderRadius: BorderRadius.circular(20),
        animation: toast.StyledToastAnimation.slideFromTop,
        reverseAnimation: toast.StyledToastAnimation.slideToTop,
        position: toast.StyledToastPosition.top,
        startOffset: Offset(0.0, -3.0),
        reverseEndOffset: Offset(0.0, -3.0),
        duration: Duration(seconds: 3),
        animDuration: Duration(seconds: 1),
        curve: Curves.elasticOut,
        reverseCurve: Curves.fastOutSlowIn);
  }

  _notificationChannel() async {
    _cupertinoIndicator(context);
    final Map resp = await _notificationProvider.notificationChannel();

    if (resp['statusCode'] == 201) {
      final List<AndroidNotificationChannel>? channels =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .getNotificationChannels();
              
      Navigator.pop(context);
      _newChannelReady();

      for (AndroidNotificationChannel channel in channels!) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.deleteNotificationChannel(channel.id);
      }

      String channelId = resp['canal'];
      AndroidNotificationChannel androidNotificationChannel =
          AndroidNotificationChannel(
        channelId,
        'Notificaciones de visitas',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('doorbell'),
        importance: Importance.high,
        description:
            'RECOMENDACIÓN: EVITE CAMBIAR CUALQUIER CONFIGURACIÓN DE ESTE APARTADO PARA ASEGURAR LA RECEPCIÓN DE VISITAS',
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);
          log('chanel: ${androidNotificationChannel.sound}');
    } else {
      creaDialogSimple(
          context,
          '¡Ups! Algo salió mal',
          'Ocurrió un error al intentar restablecer los ajuste de la notificación de visita',
          'Aceptar',
          () {Navigator.pop(context);
          Navigator.pop(context);}
          );
    }
  }
}
