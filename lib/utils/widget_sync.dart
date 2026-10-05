import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../db/repo.dart';
import '../models.dart';
import 'format.dart';

/// Mengirim ringkasan minggu berjalan ke widget home screen.
///
/// Widget-nya hanya bisa membaca teks yang sudah jadi, jadi semua perakitan
/// kalimat dilakukan di sini — sisi Android cukup menempelkannya ke layout.
class WidgetSync {
  static const _androidName = 'BeresWidgetProvider';
  static const _iosName = 'BeresWidget';

  /// Nama hari pendek untuk baris "hari berikutnya".
  static String _short(int dow) => dayShort[dow - 1];

  static String _menuHari(PlanDay day) {
    if (!day.active) return 'Libur masak';
    if (day.items.isEmpty) return 'Belum ada menu';
    final lauk = day.lauk.map((i) => i.name).toList();
    final cemilan = day.cemilan.map((i) => i.name).toList();
    return [...lauk, ...cemilan].join(', ');
  }

  /// Dipanggil saat aplikasi dibuka dan tiap kali data berubah.
  /// Kegagalan di sini tidak boleh mengganggu aplikasi.
  static Future<void> update(Repo repo, List<int> defaultDays) async {
    try {
      final weekId = await repo.ensureWeek(mondayOf(DateTime.now()), defaultDays);
      final week = await repo.getWeek(weekId);
      final belanja = await repo.listShopping(weekId);

      final now = DateTime.now();
      final today = week.day(now.weekday);
      final belum = belanja.where((i) => !i.checked).length;
      final kosong = week.laukCount + week.cemilanCount == 0;

      // Sampai tiga hari ke depan yang masih ada isinya.
      final berikut = <String>[];
      for (var d = now.weekday + 1; d <= 7 && berikut.length < 3; d++) {
        final day = week.day(d);
        if (!day.active || day.items.isEmpty) continue;
        berikut.add('${_short(d)} · ${_menuHari(day)}');
      }

      await HomeWidget.saveWidgetData('w_range', weekRange(week.start));
      await HomeWidget.saveWidgetData('w_today_label', 'Hari ini, ${dayNames[now.weekday - 1]}');
      await HomeWidget.saveWidgetData('w_today', _menuHari(today));
      await HomeWidget.saveWidgetData(
          'w_hint',
          kosong
              ? 'Minggu ini belum disusun — yuk isi menunya'
              : '${week.activeDays} hari masak · ${week.laukCount} lauk · ${week.cemilanCount} cemilan');
      for (var i = 0; i < 3; i++) {
        await HomeWidget.saveWidgetData('w_next$i', i < berikut.length ? berikut[i] : '');
      }
      await HomeWidget.saveWidgetData(
          'w_shop',
          belanja.isEmpty
              ? 'Daftar belanja masih kosong'
              : (belum == 0
                  ? 'Belanja sudah beres '
                  : '$belum item belum dibeli'));

      await HomeWidget.updateWidget(name: _androidName, iOSName: _iosName);
    } catch (e) {
      // Widget belum dipasang, atau platform tidak mendukung — abaikan.
      debugPrint('WidgetSync gagal: $e');
    }
  }
}
