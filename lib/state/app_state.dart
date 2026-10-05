import 'dart:async';

import 'package:flutter/foundation.dart';

import '../db/repo.dart';
import '../utils/format.dart';
import '../utils/widget_sync.dart';

/// State global ringan. Setiap perubahan data memanggil [changed] sehingga
/// layar yang memakai DataBuilder memuat ulang datanya.
class AppState extends ChangeNotifier {
  AppState(this.repo);
  final Repo repo;

  String name = 'Sayang';
  List<int> defaultDays = [1, 2, 3, 4, 5];
  bool onboarded = false;
  DateTime weekStart = mondayOf(DateTime.now());
  int version = 0;
  int tab = 0;

  Future<void> load() async {
    name = await repo.getSetting('name') ?? 'Sayang';
    onboarded = (await repo.getSetting('onboarded')) == '1';
    final days = await repo.getSetting('default_days');
    if (days != null && days.isNotEmpty) {
      defaultDays = days.split(',').map(int.parse).toList();
    }
  }

  void changed() {
    version++;
    notifyListeners();
    // Widget home screen ikut diperbarui, tapi tidak ditunggu — kegagalannya
    // tidak boleh menahan UI.
    unawaited(WidgetSync.update(repo, defaultDays));
  }

  /// Dipanggil sekali saat aplikasi dibuka.
  Future<void> syncWidget() => WidgetSync.update(repo, defaultDays);

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void shiftWeek(int delta) {
    weekStart = addDays(weekStart, 7 * delta);
    changed();
  }

  void goToWeek(DateTime monday) {
    weekStart = monday;
    tab = 1;
    changed();
  }

  /// Minggu yang sedang dibuka di tab Minggu Ini / Belanja.
  Future<int> weekId() => repo.ensureWeek(weekStart, defaultDays);

  /// Minggu kalender saat ini (untuk Beranda).
  Future<int> thisWeekId() => repo.ensureWeek(mondayOf(DateTime.now()), defaultDays);

  Future<void> saveProfile({String? newName, List<int>? days, bool? done}) async {
    if (newName != null && newName.trim().isNotEmpty) {
      name = newName.trim();
      await repo.setSetting('name', name);
    }
    if (days != null) {
      defaultDays = [...days]..sort();
      await repo.setSetting('default_days', defaultDays.join(','));
    }
    if (done != null) {
      onboarded = done;
      await repo.setSetting('onboarded', done ? '1' : '0');
    }
    changed();
  }
}
