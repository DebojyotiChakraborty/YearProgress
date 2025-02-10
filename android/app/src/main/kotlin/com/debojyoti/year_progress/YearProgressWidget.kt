package com.debojyoti.year_progress

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import java.util.Calendar
import java.text.SimpleDateFormat
import java.util.Locale
import android.content.Intent
import android.view.View
import android.widget.LinearLayout

class YearProgressWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        // Check for BOTH the standard update action AND your custom action.
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE ||
            intent.action == "com.debojyoti.year_progress.UPDATE_WIDGET") {

            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = intent.getIntArrayExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS)

            // Handle the case where appWidgetIds might be null.
            if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    val progress = calculateYearProgress()
    val progressInt = progress.toInt()
    val now = Calendar.getInstance()
    
    val dateFormat = SimpleDateFormat("dd'th' MMMM yyyy", Locale.getDefault())
    val dateStr = dateFormat.format(now.time)

    val views = RemoteViews(context.packageName, R.layout.year_progress_widget)
    views.setTextViewText(R.id.appwidget_text, "$progressInt%")
    views.setTextViewText(R.id.date_text, "Date    $dateStr")
    views.setTextViewText(R.id.progress_text, "${now.get(Calendar.YEAR)} is ${String.format("%.3f", progress)}% complete")

    // Create progress indicators
    val progressBars = LinearLayout(context)
    val totalBars = 35
    val completedBars = (progress / 100.0 * totalBars).toInt()

    for (i in 0 until totalBars) {
        val barView = View(context)
        barView.id = View.generateViewId()
        views.setInt(barView.id, "setBackgroundResource",
            if (i < completedBars) R.drawable.progress_bar_item else android.R.color.darker_gray)
    }

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

fun calculateYearProgress(): Double {
    val now = Calendar.getInstance()
    val year = now.get(Calendar.YEAR)
    val startOfYear = Calendar.getInstance().apply { 
        set(year, 0, 1, 0, 0, 0)
        set(Calendar.MILLISECOND, 0)
    }
    val endOfYear = Calendar.getInstance().apply { 
        set(year + 1, 0, 1, 0, 0, 0)
        set(Calendar.MILLISECOND, 0)
    }

    val totalSeconds = (endOfYear.timeInMillis - startOfYear.timeInMillis) / 1000.0
    val secondsPassed = (now.timeInMillis - startOfYear.timeInMillis) / 1000.0
    return (secondsPassed / totalSeconds) * 100
} 