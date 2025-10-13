package com.akshit.gymstats

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.EditText
import android.widget.RemoteViews
import com.akshit.gymstats.databinding.GraphWidgetImageConfigureBinding
import es.antonborri.home_widget.HomeWidgetPlugin
import androidx.core.content.edit

/**
 * The configuration screen for the [GraphWidgetImage] AppWidget.
 */
class GraphWidgetImageConfigureActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private var onClickListener = View.OnClickListener {
        val context = this@GraphWidgetImageConfigureActivity

        // When the button is clicked, store the string locally

        // It is the responsibility of the configuration activity to update the app widget
        val appWidgetManager = AppWidgetManager.getInstance(context)

        val views = RemoteViews(packageName, R.layout.graph_widget_image)
        appWidgetManager.updateAppWidget(appWidgetId, views)


        // Make sure we pass back the original appWidgetId
        val resultValue = Intent()
        resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        setResult(RESULT_OK, resultValue)
        finish()
    }
    private lateinit var binding: GraphWidgetImageConfigureBinding

    public override fun onCreate(icicle: Bundle?) {
        super.onCreate(icicle)

        // Set the result to CANCELED.  This will cause the widget host to cancel
        // out of the widget placement if the user presses the back button.
        setResult(RESULT_CANCELED)

        binding = GraphWidgetImageConfigureBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.saveButton.setOnClickListener(onClickListener)

        // Find the widget id from the intent.
        val intent = intent
        val extras = intent.extras
        if (extras != null) {
            appWidgetId = extras.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID
            )
        }

        // If this activity was started with an intent without an app widget ID, finish with an error.
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val options = listOf("Body Weight Progress", "Skeletal Muscle Mass", "Fat Mass Progress", "Body Water", "Fat Percentage", "BMR (Basal Metabolic Rate)", "Energy Expenditure", "Average Heart Rate", "Maximum Heart Rate")

        // Populate Spinner with options
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, options)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        binding.titleSpinner.adapter = adapter

        val saveButton = findViewById<Button>(R.id.save_button)

        saveButton.setOnClickListener {
            val title = binding.titleSpinner.selectedItem.toString()

            // Save to HomeWidget preferences
            val prefs = HomeWidgetPlugin.getData(this) // <- SharedPreferences
            prefs.edit { putString("title", title) }

            // Tell AppWidgetManager to update this widget
            val resultValue = Intent()
            resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            setResult(RESULT_OK, resultValue)
            finish()
        }


    }

}

private const val PREFS_NAME = "com.akshit.gymstats.GraphWidgetImage"
private const val PREF_PREFIX_KEY = "appwidget_"

// Write the prefix to the SharedPreferences object for this widget
internal fun saveTitlePref(context: Context, appWidgetId: Int, text: String) {
    val prefs = context.getSharedPreferences(PREFS_NAME, 0).edit()
    prefs.putString(PREF_PREFIX_KEY + appWidgetId, text)
    prefs.apply()
}

// Read the prefix from the SharedPreferences object for this widget.
// If there is no preference saved, get the default from a resource
internal fun loadTitlePref(context: Context, appWidgetId: Int): String {
    val prefs = context.getSharedPreferences(PREFS_NAME, 0)
    val titleValue = prefs.getString(PREF_PREFIX_KEY + appWidgetId, null)
    return titleValue ?: context.getString(R.string.appwidget_text)
}

internal fun deleteTitlePref(context: Context, appWidgetId: Int) {
    val prefs = context.getSharedPreferences(PREFS_NAME, 0).edit()
    prefs.remove(PREF_PREFIX_KEY + appWidgetId)
    prefs.apply()
}