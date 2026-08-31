package com.lkey.l_key

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The single activity, plus the one channel this app defines.
 *
 * The channel exists because no package was worth adding for it: `audio_service`
 * is a large dependency for a notification that is forty lines of Kotlin
 * (`CLAUDE.md` §42). See docs/adr/0016.
 */
class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.lkey.l_key/metronome_service",
        )
        this.channel = channel

        // Pressing Stop in the shade must actually release the audio, not merely
        // dismiss the notification over a click that carries on playing.
        MetronomeService.onStopRequested = {
            runOnUiThread { channel.invokeMethod("stopRequested", null) }
        }

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start", "update" -> {
                    val intent = Intent(this, MetronomeService::class.java).apply {
                        action = if (call.method == "start") {
                            MetronomeService.ACTION_START
                        } else {
                            MetronomeService.ACTION_UPDATE
                        }
                        putExtra(MetronomeService.EXTRA_TITLE, call.argument<String>("title"))
                        putExtra(MetronomeService.EXTRA_BODY, call.argument<String>("body"))
                        putExtra(
                            MetronomeService.EXTRA_STOP_LABEL,
                            call.argument<String>("stopLabel"),
                        )
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }

                "stop" -> {
                    stopService(Intent(this, MetronomeService::class.java))
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        MetronomeService.onStopRequested = null
        channel?.setMethodCallHandler(null)
        channel = null
        super.onDestroy()
    }
}
