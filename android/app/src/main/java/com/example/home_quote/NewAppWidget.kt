package com.example.home_quote

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin


/**
 * Implementation of App Widget functionality.
 */
class NewAppWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            println("hi")
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val widgetData = HomeWidgetPlugin.getData(context)
    val views = RemoteViews(context.packageName, R.layout.new_app_widget).apply{


    val color = widgetData.getString("color","#000000")
    val textColor = Color.parseColor(widgetData.getString("textColor", "#ffffff"))
        
    if(color == "#000000"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_000000)
    }else if(color == "#ffffff"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_ffffff)
    }else if(color == "#c8c8c8"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_c8c8c8)
    }else if(color == "#323232"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_323232)
    }else if(color == "#c80000"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_c80000)
    }else if(color == "#00c800"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_00c800)
    }else if(color == "#0000c8"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_0000c8)
    }else if(color == "#c8c800"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_c8c800)
    }else if(color == "#00c8c8"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_00c8c8)
    }else if(color == "#c800c8"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_c800c8)
    }else if(color == "#646464"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_646464)
    }else if(color == "#969696"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_969696)
    }else if(color == "#640000"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_640000)
    }else if(color == "#646400"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_646400)
    }else if(color == "#006400"){
        this.setInt(R.id.visible,"setBackgroundResource",R.drawable.back_006400)
    }
    setTextColor(R.id.visible,textColor)

    val visible = widgetData.getString("visible","Error")
    setTextViewText(R.id.visible,visible)

    }
    appWidgetManager.updateAppWidget(appWidgetId,views)
}
