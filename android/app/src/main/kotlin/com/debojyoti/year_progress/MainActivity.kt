package com.debojyoti.year_progress

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.appwidget.AppWidgetManager
import android.content.ComponentName

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.debojyoti.year_progress/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "updateWidgetData") {

                val intent = Intent(this, YearProgressWidget::class.java)
                intent.action = "com.debojyoti.year_progress.UPDATE_WIDGET"
                val ids = AppWidgetManager.getInstance(application)
                    .getAppWidgetIds(ComponentName(application, YearProgressWidget::class.java))
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                sendBroadcast(intent)
                result.success(null) // Send success result
            } else {
                result.notImplemented()
            }
        }
    }
}
