package com.akshit.gymstats

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import androidx.core.graphics.toColorInt

/**
 * Implementation of App Widget functionality.
 */
class GymDaysWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val noOfGymDays = widgetData.getString("no_of_gym_days", null)
            val views = RemoteViews(context.packageName, R.layout.gym_days_widget).apply {
                setTextViewText(R.id.no_of_gym_days, noOfGymDays ?: "-")
                val color = getTextColor(noOfGymDays)
                setTextColor(R.id.no_of_gym_days, color)
            }
//            updateAppWidget(context, appWidgetManager, appWidgetId)

            appWidgetManager.updateAppWidget(appWidgetId, views)

        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    private fun getTextColor(noOfGymDays: String?): Int {
        if (noOfGymDays == null || noOfGymDays == "-") {
            return Color.WHITE
        }

        val days = noOfGymDays.toIntOrNull() ?: 0
        return when {
            days >= 6 -> "#4CAF50".toColorInt() // Green
            days >= 4 -> "#FFA500".toColorInt() // Orange
            else -> "#F44336".toColorInt()      // Red
        }
    }

}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val widgetText = context.getString(R.string.appwidget_text)
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.gym_days_widget)
    views.setTextViewText(R.id.no_of_gym_days, widgetText)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}