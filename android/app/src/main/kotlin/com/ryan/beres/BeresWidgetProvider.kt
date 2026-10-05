package com.ryan.beres

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/// Widget home screen Beres?.
///
/// Semua teks sudah dirakit di sisi Flutter (lihat lib/utils/widget_sync.dart)
/// dan disimpan lewat home_widget, jadi di sini tinggal ditempelkan.
class BeresWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val data = HomeWidgetPlugin.getData(context)

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.beres_widget)

            views.setTextViewText(R.id.w_range, data.getString("w_range", "") ?: "")
            views.setTextViewText(
                R.id.w_today_label,
                data.getString("w_today_label", "Hari ini") ?: "Hari ini"
            )
            views.setTextViewText(
                R.id.w_today,
                data.getString("w_today", "Buka aplikasinya dulu ya") ?: "Buka aplikasinya dulu ya"
            )
            views.setTextViewText(R.id.w_hint, data.getString("w_hint", "") ?: "")
            views.setTextViewText(R.id.w_shop, data.getString("w_shop", "") ?: "")

            // Baris hari berikutnya disembunyikan kalau tidak ada isinya, supaya
            // widget kecil tidak menyisakan baris kosong.
            val nextIds = intArrayOf(R.id.w_next0, R.id.w_next1, R.id.w_next2)
            for (i in nextIds.indices) {
                val text = data.getString("w_next$i", "") ?: ""
                views.setTextViewText(nextIds[i], text)
                views.setViewVisibility(
                    nextIds[i],
                    if (text.isEmpty()) View.GONE else View.VISIBLE
                )
            }

            // Ketuk widget untuk membuka aplikasi.
            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launch != null) {
                launch.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                val pending = PendingIntent.getActivity(
                    context,
                    0,
                    launch,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pending)
            }

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
