package com.lkey.l_key

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Keeps the metronome sounding while the app is backgrounded or the screen is off.
 *
 * Android will not let an ordinary process hold an audio track through Doze, so the
 * click needs a foreground service. Being foreground is also what makes it honest:
 * the notification is always visible and always stoppable from the shade, which is
 * the difference between a tool doing what it was asked and the battery leak
 * `mobile/CLAUDE.md` §50 warns about.
 *
 * **It hardcodes no user-facing text.** Every string arrives from Dart as an intent
 * extra, because Burmese is a first-class language (DESIGN.md §36) and a second
 * translation pipeline in Kotlin string resources would go stale.
 */
class MetronomeService : Service() {

    companion object {
        const val ACTION_START = "com.lkey.l_key.metronome.START"
        const val ACTION_UPDATE = "com.lkey.l_key.metronome.UPDATE"
        const val ACTION_STOP = "com.lkey.l_key.metronome.STOP"

        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_STOP_LABEL = "stopLabel"

        private const val CHANNEL_ID = "lkey.metronome"
        private const val NOTIFICATION_ID = 1001

        /** Set while the service holds the foreground, so Dart can be told. */
        @Volatile
        var onStopRequested: (() -> Unit)? = null
    }

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START, ACTION_UPDATE -> {
                val notification = buildNotification(
                    title = intent.getStringExtra(EXTRA_TITLE).orEmpty(),
                    body = intent.getStringExtra(EXTRA_BODY).orEmpty(),
                    stopLabel = intent.getStringExtra(EXTRA_STOP_LABEL).orEmpty(),
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    startForeground(
                        NOTIFICATION_ID,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
                    )
                } else {
                    startForeground(NOTIFICATION_ID, notification)
                }
            }

            ACTION_STOP -> {
                // Told to Dart first, so the audio is actually released rather than
                // the notification merely disappearing from under a running click.
                onStopRequested?.invoke()
                stopSelf()
            }
        }
        // Not sticky: a metronome the system restarts by itself, with no player
        // present and no tempo to play, would be sound nobody asked for.
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return

        // Low importance, silent, no badge, no vibration. A channel that chimed
        // over a metronome would be absurd, and one that buzzed would fight the
        // beat haptic.
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Metronome",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            setShowBadge(false)
            enableVibration(false)
            setSound(null, null)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(
        title: String,
        body: String,
        stopLabel: String,
    ): Notification {
        val open = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val stop = PendingIntent.getService(
            this,
            1,
            Intent(this, MetronomeService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_metronome)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(open)
            .addAction(0, stopLabel, stop)
            .setOngoing(true)
            .setSilent(true)
            .setShowWhen(false)
            .setCategory(NotificationCompat.CATEGORY_TRANSPORT)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
    }
}
