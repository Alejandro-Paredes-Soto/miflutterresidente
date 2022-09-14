import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/utils/dialogs.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Configuraciones'),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: MyApp.of(context)!.changeTheme,
              child: Row(
                children: [
                  Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round,
                    size: 30,
                    color: Theme.of(context).textTheme.bodyText2!.color
                  ),
                  const SizedBox(width: 10),
                  Text('Tema',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyText2!.color)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, elevation: 0),
            ),
            Divider(),
            ElevatedButton(
                onPressed: _notificationChannel,
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 30,
                      color: Theme.of(context).textTheme.bodyText2!.color
                    ),
                    const SizedBox(width: 10),
                    Text('Restablecer notificación de visita',
                        style: TextStyle(
                            fontSize: 20,
                            color:
                                Theme.of(context).textTheme.bodyText2!.color)),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.transparent, elevation: 0)),
            Divider(),
            ElevatedButton(
              onPressed: () => utils.abrirPaginaWeb(
                  url: 'https://dostop.mx/aviso-de-privacidad.html'),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outlined,
                    size: 30,
                    color: Theme.of(context).textTheme.bodyText2!.color
                  ),
                  const SizedBox(width: 10),
                  Text('Aviso de privacidad',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyText2!.color)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, elevation: 0),
            ),
          ],
        ),
      ),
    );
  }

  _notificationChannel() async {
    final Map resp = await _notificationProvider.notificationChannel();

    if (resp['statusCode'] == 200) {
      final List<AndroidNotificationChannel>? channels =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .getNotificationChannels();

      for (AndroidNotificationChannel channel in channels!) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.deleteNotificationChannel(channel.id);
      }

      String channelId = resp['channel'];
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
    } else {
      creaDialogSimple(
          context,
          '¡Ups! Algo salió mal',
          'Ocurrió un error al intentar restablecer los ajuste de la notificación de visita',
          'Aceptar',
          () => Navigator.pop(context));
    }
  }
}
