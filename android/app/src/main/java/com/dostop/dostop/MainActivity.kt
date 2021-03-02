package com.dostop.dostop

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        /*
        SAUL RAMIREZ LOPEZ 28-01-2020

        SE AGREGA FRAGMENTO DE CODIGO ANTES DE GENERAR EL PLUGIN DE DART VM.

        SE REVISARON ALTERNATIVAS PARA USAR EL SONIDO DE NOTIFICACION DE DOORBELL.MP3 YA QUE ACTUALMENTE
        EXISTE UNA LIMITANTE DESDE ANDROID 8.0 (OREO) CON LOS SERVICIOS EN SEGUNDO PLANO Y AGREGANDO
        NOTIFICACIONES. PARA ESTO SE TIENE QUE AGREGAR UN CANAL DE NOTIFICACIONES.

        ESTO PODRIA CAMBIAR EN ALGUN MOMENTO ASI QUE HAY QUE ESTAR AL PENDIENTE DEL LINK SIGUIENTE:
        https://github.com/FirebaseExtended/flutterfire/issues/523

        SE EXPLICA ESTA SOLUCION TEMPORAL Y SE ENCUENTRA ABIERTO UN ISSUE DONDE SE EXPERIMENTA EL PROBLEMA
        ESTAR AL PENDIENTE DE CUALQUIER CAMBIO

        NOTA: Si se desea llamar a este canal de notificaciones desde el json de firebase, simplemente
        se debe de poner el parámetro "android_channel_id":"canal_de_visitas" dentro de notification y
        asi se llamará debidamente con el timbre de doorbell.
     */

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val soundUri = Uri.parse("android.resource://" + applicationContext.packageName + "/" + R.raw.doorbell)
            val audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    //NADA PUEDE SILENCIAR DOSTOP ASI QUE SI EN ALGUN MOMENTO REPORTAN QUE DOSTOP
                    //NO PUEDE SILENCIARSE EN MODO VIBRACION USAR ESTE FRAGMENTO REEMPLAZANDO EL DE
                    //ARRIBA
                    //
                    //.setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()

            // Creating Channel
            val channel = NotificationChannel(getString(R.string.notification_channel_id), getString(R.string.channel_name), NotificationManager.IMPORTANCE_HIGH)
            channel.setSound(soundUri, audioAttributes)
            channel.vibrationPattern = longArrayOf(0, 800)
            val notificationManager = getSystemService<NotificationManager>(NotificationManager::class.java)
            val existingChannel = notificationManager.getNotificationChannel(getString(R.string.notification_channel_id))
            //it will delete existing channel if it exists
            if (existingChannel != null)
                notificationManager.deleteNotificationChannel(getString(R.string.notification_channel_id))
            notificationManager.createNotificationChannel(channel)
        }//FIN DEL FRAGMENTO DE CODIGO

        GeneratedPluginRegistrant.registerWith(this)
    }
}