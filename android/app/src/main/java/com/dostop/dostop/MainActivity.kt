package com.dostop.dostop

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;


class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val soundUri = Uri.parse("android.resource://" + applicationContext.packageName + "/" + R.raw.doorbell)
            val audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
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
        }
    }
}