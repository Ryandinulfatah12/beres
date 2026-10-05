// Membuat database berisi riwayat beberapa minggu lintas bulan, untuk menilai
// tampilan layar Riwayat dan mengambil tangkapan layar.
//
// Dijalankan lewat flutter test karena memakai Repo, yang menarik Flutter:
//
//   flutter test tool/make_demo_db.dart --dart-define=OUT=/tmp/demo.db
//   adb push /tmp/demo.db /data/local/tmp/
//   adb shell "run-as com.ryan.beres cp /data/local/tmp/demo.db databases/beres.db"
import 'dart:io';
import 'dart:math';

import 'package:beres/db/repo.dart';
import 'package:beres/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

DateTime _mondayOf(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// Menu per minggu, dari yang paling lama ke paling baru.
const _plan = [
  ['Rendang', 'Sayur asem', 'Tempe orek', 'Pisang goreng'],
  ['Soto ayam', 'Perkedel', 'Tumis kangkung'],
  ['Ikan bakar', 'Sambal matah', 'Capcay', 'Klepon'],
  ['Opor ayam', 'Sambal goreng ati', 'Bihun goreng', 'Dadar gulung', 'Es cendol'],
  ['Sate taichan', 'Garang asem ayam', 'Balado terong'],
  ['Nasi goreng', 'Telor dadar'],
];

void main() => test('tulis database demo', _buat, timeout: const Timeout(Duration(minutes: 2)));

Future<void> _buat() async {
  const out = String.fromEnvironment('OUT', defaultValue: 'demo.db');
  final file = File(out);
  if (file.existsSync()) file.deleteSync();

  sqfliteFfiInit();
  final repo = await Repo.openAt(out, factory: databaseFactoryFfi);
  final rng = Random(7);

  await repo.setSetting('name', 'Bunda');
  await repo.setSetting('onboarded', '1');
  await repo.setSetting('default_days', '1,2,3,4,5');

  final senin = _mondayOf(DateTime.now());

  for (var i = 0; i < _plan.length; i++) {
    // Minggu paling lama lebih dulu; yang terakhir adalah minggu berjalan.
    final mulai = senin.subtract(Duration(days: 7 * (_plan.length - 1 - i)));
    final weekId = await repo.ensureWeek(mulai, const [1, 2, 3, 4, 5]);
    final week = await repo.getWeek(weekId);

    var hari = 1;
    for (final nama in _plan[i]) {
      final cemilan = nama.contains(RegExp(r'goreng$|Klepon|Dadar|cendol'));
      final dishId = await repo.saveDish(
        name: nama,
        category: cemilan ? 'cemilan' : 'lauk',
        ingredients: [
          DishIngredient(name: 'Bawang merah', qty: 5, unit: 'siung'),
          DishIngredient(name: 'Bawang putih', qty: 3, unit: 'siung'),
          DishIngredient(name: cemilan ? 'Tepung terigu' : 'Ayam potong', qty: 500, unit: 'gr'),
        ],
      );
      await repo.addDishes(week.day(hari).id, [dishId]);
      hari = hari % 5 + 1;
    }

    await repo.generateShopping(weekId);

    // Minggu berjalan sengaja dibiarkan belum belanja.
    if (i == _plan.length - 1) continue;

    for (final item in await repo.listShopping(weekId)) {
      await repo.setShopChecked(item.id, true);
      await repo.setShopPrice(item, (rng.nextInt(26) + 8) * 2500);
    }
    await repo.finishWeek(weekId);
  }

  await repo.db.close();
  stdout.writeln('Database demo ditulis ke $out (${_plan.length} minggu)');
}
