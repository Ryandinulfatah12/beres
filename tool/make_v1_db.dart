// Membuat file database skema v1 berisi data contoh, untuk menguji migrasi
// di perangkat sungguhan:
//
//   dart run tool/make_v1_db.dart /tmp/v1.db
//   adb push /tmp/v1.db /data/local/tmp/
//   adb shell "run-as com.ryan.beres cp /data/local/tmp/v1.db databases/beres.db"
//
// Lalu buka aplikasinya — Repo akan menaikkannya ke v2.
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Skema v1 apa adanya, sama seperti di test/migration_test.dart.
const _v1Schema = [
  'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT)',
  "CREATE TABLE stores (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, "
      "type TEXT NOT NULL DEFAULT 'eceran')",
  "CREATE TABLE ingredients (id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "name TEXT NOT NULL UNIQUE COLLATE NOCASE, default_unit TEXT NOT NULL DEFAULT '', "
      "last_price INTEGER, default_store_id INTEGER REFERENCES stores(id) ON DELETE SET NULL)",
  "CREATE TABLE dishes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, "
      "category TEXT NOT NULL CHECK (category IN ('lauk','cemilan')), note TEXT, created_at TEXT NOT NULL)",
  "CREATE TABLE dish_ingredients (id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "dish_id INTEGER NOT NULL REFERENCES dishes(id) ON DELETE CASCADE, "
      "ingredient_id INTEGER NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE, "
      "qty REAL, unit TEXT NOT NULL DEFAULT '')",
  'CREATE TABLE week_plans (id INTEGER PRIMARY KEY AUTOINCREMENT, week_start TEXT NOT NULL UNIQUE, '
      'note TEXT, finished_at TEXT, created_at TEXT NOT NULL)',
  'CREATE TABLE plan_days (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'week_plan_id INTEGER NOT NULL REFERENCES week_plans(id) ON DELETE CASCADE, '
      'day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7), '
      'is_active INTEGER NOT NULL DEFAULT 1, UNIQUE (week_plan_id, day_of_week))',
  'CREATE TABLE plan_items (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'plan_day_id INTEGER NOT NULL REFERENCES plan_days(id) ON DELETE CASCADE, '
      'dish_id INTEGER NOT NULL REFERENCES dishes(id) ON DELETE CASCADE, '
      'sort_order INTEGER NOT NULL DEFAULT 0)',
  "CREATE TABLE shopping_items (id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "week_plan_id INTEGER NOT NULL REFERENCES week_plans(id) ON DELETE CASCADE, "
      "ingredient_id INTEGER REFERENCES ingredients(id) ON DELETE SET NULL, "
      "name TEXT NOT NULL, qty REAL, unit TEXT NOT NULL DEFAULT '', "
      "is_manual INTEGER NOT NULL DEFAULT 0, is_checked INTEGER NOT NULL DEFAULT 0, "
      "price INTEGER, store_id INTEGER REFERENCES stores(id) ON DELETE SET NULL, sources TEXT)",
];

DateTime _mondayOf(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Future<void> main(List<String> args) async {
  final out = args.isEmpty ? 'v1.db' : args.first;
  final file = File(out);
  if (file.existsSync()) file.deleteSync();

  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(out,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          for (final sql in _v1Schema) {
            await db.execute(sql);
          }
        },
      ));

  final now = DateTime.now().toIso8601String();
  final superIndo = await db.insert('stores', {'name': 'Super Indo', 'type': 'eceran'});
  final tokoGrosir = await db.insert('stores', {'name': 'Toko Grosir', 'type': 'grosir'});

  final ayamId = await db.insert('ingredients',
      {'name': 'Dada ayam', 'default_unit': 'gr', 'default_store_id': superIndo});
  final telurId = await db.insert('ingredients',
      {'name': 'Telur', 'default_unit': 'butir', 'default_store_id': tokoGrosir});

  final sate = await db
      .insert('dishes', {'name': 'Sate taichan', 'category': 'lauk', 'created_at': now});
  await db.insert('dish_ingredients',
      {'dish_id': sate, 'ingredient_id': ayamId, 'qty': 500.0, 'unit': 'gr'});
  final rolade =
      await db.insert('dishes', {'name': 'Rolade', 'category': 'lauk', 'created_at': now});
  await db.insert('dish_ingredients',
      {'dish_id': rolade, 'ingredient_id': telurId, 'qty': 3.0, 'unit': 'butir'});

  final weekId = await db.insert(
      'week_plans', {'week_start': _iso(_mondayOf(DateTime.now())), 'created_at': now});
  final dayIds = <int>[];
  for (var d = 1; d <= 7; d++) {
    dayIds.add(await db.insert('plan_days',
        {'week_plan_id': weekId, 'day_of_week': d, 'is_active': d <= 5 ? 1 : 0}));
  }
  await db.insert('plan_items', {'plan_day_id': dayIds[0], 'dish_id': sate, 'sort_order': 0});
  await db.insert('plan_items', {'plan_day_id': dayIds[1], 'dish_id': rolade, 'sort_order': 0});

  // Satu item sudah dicentang dengan harga — ini yang wajib selamat.
  await db.insert('shopping_items', {
    'week_plan_id': weekId,
    'ingredient_id': ayamId,
    'name': 'Dada ayam',
    'qty': 500.0,
    'unit': 'gr',
    'is_manual': 0,
    'is_checked': 1,
    'price': 45000,
    'store_id': superIndo,
    'sources': 'Sate taichan',
  });
  await db.insert('shopping_items', {
    'week_plan_id': weekId,
    'ingredient_id': telurId,
    'name': 'Telur',
    'qty': 3.0,
    'unit': 'butir',
    'is_manual': 0,
    'is_checked': 0,
    'store_id': tokoGrosir,
    'sources': 'Rolade',
  });
  await db.insert('shopping_items', {
    'week_plan_id': weekId,
    'name': 'Tisu muka',
    'qty': 1.0,
    'unit': 'pak',
    'is_manual': 1,
    'is_checked': 0,
    'store_id': superIndo,
  });

  await db.insert('settings', {'key': 'name', 'value': 'Bunda'});
  await db.insert('settings', {'key': 'onboarded', 'value': '1'});
  await db.insert('settings', {'key': 'default_days', 'value': '1,2,3,4,5'});

  await db.close();
  stdout.writeln('Database v1 ditulis ke $out');
}
