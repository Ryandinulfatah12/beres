import 'dart:io';

import 'package:beres/db/repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Skema v1 apa adanya, disalin dari rilis sebelum eceran/grosir pindah jadi
/// cara beli per item. Jangan diubah — ini yang ada di perangkat pengguna lama.
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

void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;

  late Directory dir;
  late String path;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('beres_migrasi');
    path = '${dir.path}/beres.db';
  });

  tearDown(() async => dir.delete(recursive: true));

  /// Bikin database v1 berisi data seperti milik pengguna lama.
  Future<void> seedV1() async {
    final db = await factory.openDatabase(path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            for (final sql in _v1Schema) {
              await db.execute(sql);
            }
          },
        ));
    final eceran = await db.insert('stores', {'name': 'Super Indo', 'type': 'eceran'});
    final grosir = await db.insert('stores', {'name': 'Toko Grosir', 'type': 'grosir'});

    await db.insert('ingredients',
        {'name': 'Dada ayam', 'default_unit': 'gr', 'default_store_id': eceran});
    await db.insert('ingredients',
        {'name': 'Telur', 'default_unit': 'butir', 'default_store_id': grosir});

    final weekId = await db.insert('week_plans',
        {'week_start': '2026-09-28', 'created_at': DateTime.now().toIso8601String()});
    for (var d = 1; d <= 7; d++) {
      await db.insert('plan_days', {'week_plan_id': weekId, 'day_of_week': d, 'is_active': 1});
    }
    await db.insert('shopping_items', {
      'week_plan_id': weekId,
      'name': 'Dada ayam',
      'qty': 700.0,
      'unit': 'gr',
      'is_manual': 0,
      'is_checked': 1,
      'price': 45000,
      'store_id': eceran,
    });
    await db.insert('shopping_items', {
      'week_plan_id': weekId,
      'name': 'Telur',
      'qty': 13.0,
      'unit': 'butir',
      'is_manual': 0,
      'is_checked': 0,
      'store_id': grosir,
    });
    await db.close();
  }

  test('database v1 naik ke v2 tanpa kehilangan data', () async {
    await seedV1();
    final repo = await Repo.openAt(path, factory: factory);

    final version = (await repo.db.rawQuery('PRAGMA user_version')).first.values.first;
    expect(version, Repo.schemaVersion);

    final stores = await repo.listStores();
    expect(stores.map((s) => s.name), ['Super Indo', 'Toko Grosir']);

    final items = await repo.listShopping(1);
    expect(items.length, 2);

    final ayam = items.firstWhere((i) => i.name == 'Dada ayam');
    expect(ayam.qty, 700);
    expect(ayam.checked, isTrue, reason: 'status centang harus bertahan');
    expect(ayam.price, 45000, reason: 'harga yang sudah dicatat harus bertahan');

    await repo.db.close();
  });

  test('item tetap menunjuk ke tokonya setelah tabel stores dibangun ulang', () async {
    await seedV1();
    final repo = await Repo.openAt(path, factory: factory);

    final items = await repo.listShopping(1);
    expect(items.firstWhere((i) => i.name == 'Dada ayam').storeName, 'Super Indo');
    expect(items.firstWhere((i) => i.name == 'Telur').storeName, 'Toko Grosir');

    final ings = await repo.db.query('ingredients', orderBy: 'name');
    expect(ings.every((i) => i['default_store_id'] != null), isTrue,
        reason: 'toko default bahan tidak boleh ikut hilang');

    await repo.db.close();
  });

  test('tipe toko lama diwarisi jadi cara beli per item', () async {
    await seedV1();
    final repo = await Repo.openAt(path, factory: factory);

    final items = await repo.listShopping(1);
    expect(items.firstWhere((i) => i.name == 'Dada ayam').grosir, isFalse);
    expect(items.firstWhere((i) => i.name == 'Telur').grosir, isTrue,
        reason: 'item dari toko bertipe grosir jadi cara beli grosir');

    final ings = await repo.db.query('ingredients', orderBy: 'name');
    expect(ings.firstWhere((i) => i['name'] == 'Telur')['default_buy_mode'], 'grosir');
    expect(ings.firstWhere((i) => i['name'] == 'Dada ayam')['default_buy_mode'], 'eceran');

    await repo.db.close();
  });

  test('kolom type dibuang dari tabel stores', () async {
    await seedV1();
    final repo = await Repo.openAt(path, factory: factory);

    final cols = await repo.db.rawQuery('PRAGMA table_info(stores)');
    expect(cols.map((c) => c['name']), ['id', 'name']);

    await repo.db.close();
  });

  test('migrasi tidak jalan dua kali kalau dibuka ulang', () async {
    await seedV1();
    final first = await Repo.openAt(path, factory: factory);
    await first.db.close();

    final second = await Repo.openAt(path, factory: factory);
    final items = await second.listShopping(1);
    expect(items.length, 2, reason: 'data tidak boleh terduplikasi');
    expect(items.firstWhere((i) => i.name == 'Telur').grosir, isTrue);
    await second.db.close();
  });

  test('database baru langsung v2 dan terisi data awal', () async {
    final repo = await Repo.openAt(path, factory: factory);

    final stores = await repo.listStores();
    expect(stores.map((s) => s.name), ['Super Indo', 'Pasar']);

    final lauk = await repo.listDishes('lauk');
    expect(lauk, isNotEmpty);

    final cols = await repo.db.rawQuery('PRAGMA table_info(shopping_items)');
    expect(cols.map((c) => c['name']), contains('buy_mode'));

    await repo.db.close();
  });
}
