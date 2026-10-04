import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models.dart';
import '../utils/format.dart';

/// Semua akses database Beres? ada di sini.
class Repo {
  Repo(this.db, this.path);
  final Database db;
  final String path;

  static Future<Repo> open() async {
    final path = p.join(await getDatabasesPath(), 'beres.db');
    final db = await openDatabase(
      path,
      version: 2,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        for (final sql in _schema) {
          await db.execute(sql);
        }
        await _seed(db);
      },
      onUpgrade: _upgrade,
    );
    return Repo(db, path);
  }

  static const _schema = [
    'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT)',
    'CREATE TABLE stores (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)',
    "CREATE TABLE ingredients (id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "name TEXT NOT NULL UNIQUE COLLATE NOCASE, default_unit TEXT NOT NULL DEFAULT '', "
        "last_price INTEGER, default_store_id INTEGER REFERENCES stores(id) ON DELETE SET NULL, "
        "default_buy_mode TEXT NOT NULL DEFAULT 'eceran' CHECK (default_buy_mode IN ('eceran','grosir')))",
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
        "price INTEGER, store_id INTEGER REFERENCES stores(id) ON DELETE SET NULL, sources TEXT, "
        "buy_mode TEXT NOT NULL DEFAULT 'eceran' CHECK (buy_mode IN ('eceran','grosir')))",
    'CREATE INDEX idx_plan_items_day ON plan_items(plan_day_id)',
    'CREATE INDEX idx_shop_week ON shopping_items(week_plan_id)',
  ];

  // ---------------------------------------------------------------- migrasi

  /// v1 -> v2: eceran/grosir pindah dari sifat toko jadi cara beli per item.
  /// Nilai lama di stores.type dipakai sebagai tebakan awal, lalu kolomnya dibuang.
  static Future<void> _upgrade(Database db, int from, int to) async {
    if (from < 2) {
      await db.execute(
          "ALTER TABLE ingredients ADD COLUMN default_buy_mode TEXT NOT NULL DEFAULT 'eceran'");
      await db.execute(
          "ALTER TABLE shopping_items ADD COLUMN buy_mode TEXT NOT NULL DEFAULT 'eceran'");

      // Warisi mode beli dari tipe toko yang lama.
      await db.execute("""
        UPDATE ingredients SET default_buy_mode = 'grosir'
        WHERE default_store_id IN (SELECT id FROM stores WHERE type = 'grosir')
      """);
      await db.execute("""
        UPDATE shopping_items SET buy_mode = 'grosir'
        WHERE store_id IN (SELECT id FROM stores WHERE type = 'grosir')
      """);

      // SQLite lama tidak punya DROP COLUMN, jadi tabel stores dibangun ulang.
      await db.execute('PRAGMA foreign_keys = OFF');
      await db.transaction((txn) async {
        await txn.execute(
            'CREATE TABLE stores_new (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)');
        await txn.execute('INSERT INTO stores_new (id, name) SELECT id, name FROM stores');
        await txn.execute('DROP TABLE stores');
        await txn.execute('ALTER TABLE stores_new RENAME TO stores');
      });
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  // ---------------------------------------------------------------- seed

  static Future<void> _seed(Database db) async {
    final now = DateTime.now().toIso8601String();
    final superIndo = await db.insert('stores', {'name': 'Super Indo'});
    final pasar = await db.insert('stores', {'name': 'Pasar'});
    // Bahan yang biasanya dibeli sekalian banyak — modenya bisa diubah per item.
    const grosirItems = {'Telur', 'Gula pasir', 'Tepung tapioka', 'Beras', 'Minyak goreng'};

    // Menu dari catatan mingguan (bahan bisa diedit di halaman Menu).
    final dishes = <String, (String, List<(String, double?, String)>)>{
      'Sate taichan': ('lauk', [('Dada ayam', 500, 'gr'), ('Jeruk nipis', 2, 'buah'), ('Cabai rawit', 10, 'buah'), ('Bawang putih', 3, 'siung')]),
      'Capcay': ('lauk', [('Brokoli', 1, 'bonggol'), ('Wortel', 2, 'buah'), ('Sawi putih', 1, 'ikat'), ('Dada ayam', 200, 'gr'), ('Bawang putih', 4, 'siung')]),
      'Rolade': ('lauk', [('Daging giling', 200, 'gr'), ('Telur', 3, 'butir'), ('Tepung tapioka', 50, 'gr'), ('Bawang putih', 2, 'siung')]),
      'Garang asem ayam': ('lauk', [('Ayam potong', 1, 'ekor'), ('Belimbing wuluh', 5, 'buah'), ('Tomat hijau', 2, 'buah'), ('Cabai rawit', 8, 'buah'), ('Bawang merah', 6, 'siung'), ('Bawang putih', 3, 'siung')]),
      'Balado terong': ('lauk', [('Terong', 3, 'buah'), ('Cabai merah', 8, 'buah'), ('Bawang merah', 5, 'siung'), ('Bawang putih', 2, 'siung')]),
      'Telor dadar': ('lauk', [('Telur', 4, 'butir'), ('Daun bawang', 1, 'batang')]),
      'Ayam suwir sambal embe': ('lauk', [('Dada ayam', 300, 'gr'), ('Cabai rawit', 10, 'buah'), ('Bawang merah', 6, 'siung'), ('Bawang putih', 3, 'siung')]),
      'Tahu kotak': ('lauk', [('Tahu kotak', 1, 'bungkus')]),
      'QQ ball Taiwan': ('cemilan', [('Ubi ungu', 300, 'gr'), ('Tepung tapioka', 150, 'gr'), ('Gula pasir', 50, 'gr')]),
      'Brownies ubi': ('cemilan', [('Ubi ungu', 300, 'gr'), ('Cokelat bubuk', 50, 'gr'), ('Telur', 2, 'butir'), ('Gula pasir', 100, 'gr')]),
      'Martabak telor': ('cemilan', [('Kulit lumpia', 1, 'pak'), ('Telur', 4, 'butir'), ('Daging giling', 100, 'gr'), ('Daun bawang', 2, 'batang')]),
      'Bubur ketan kacang hijau': ('cemilan', [('Kacang hijau', 250, 'gr'), ('Ketan hitam', 100, 'gr'), ('Santan', 1, 'bungkus'), ('Gula merah', 100, 'gr')]),
      'Kentang telor mozarella': ('cemilan', [('Kentang', 4, 'buah'), ('Telur', 2, 'butir'), ('Keju mozarella', 100, 'gr')]),
    };

    final ids = <String, int>{};
    for (final e in dishes.entries) {
      final dishId = await db.insert('dishes', {'name': e.key, 'category': e.value.$1, 'created_at': now});
      ids[e.key] = dishId;
      for (final ing in e.value.$2) {
        final bulk = grosirItems.contains(ing.$1);
        final ingId = await _ensureIng(db, ing.$1, ing.$3,
            storeId: bulk ? pasar : superIndo, buyMode: bulk ? 'grosir' : 'eceran');
        await db.insert('dish_ingredients',
            {'dish_id': dishId, 'ingredient_id': ingId, 'qty': ing.$2, 'unit': ing.$3});
      }
    }

    final weekId = await _ensureWeekOn(db, mondayOf(DateTime.now()), [1, 2, 3, 4, 5]);
    const plan = {
      1: ['Sate taichan', 'QQ ball Taiwan'],
      2: ['Capcay', 'Rolade', 'Brownies ubi'],
      3: ['Garang asem ayam', 'Martabak telor'],
      4: ['Balado terong', 'Telor dadar', 'Bubur ketan kacang hijau'],
      5: ['Ayam suwir sambal embe', 'Tahu kotak', 'Kentang telor mozarella'],
    };
    for (final e in plan.entries) {
      final day = await db.query('plan_days',
          columns: ['id'], where: 'week_plan_id = ? AND day_of_week = ?', whereArgs: [weekId, e.key]);
      final dayId = day.first['id'] as int;
      var order = 0;
      for (final name in e.value) {
        await db.insert('plan_items', {'plan_day_id': dayId, 'dish_id': ids[name], 'sort_order': order++});
      }
    }
  }

  static Future<int> _ensureIng(DatabaseExecutor db, String name, String unit,
      {int? storeId, String buyMode = 'eceran'}) async {
    final rows = await db.query('ingredients',
        columns: ['id'], where: 'name = ? COLLATE NOCASE', whereArgs: [name.trim()]);
    if (rows.isNotEmpty) return rows.first['id'] as int;
    return db.insert('ingredients', {
      'name': name.trim(),
      'default_unit': unit.trim(),
      'default_store_id': storeId,
      'default_buy_mode': buyMode,
    });
  }

  static Future<int?> _defaultStore(DatabaseExecutor db) async {
    final rows = await db.query('stores', columns: ['id'], orderBy: 'id', limit: 1);
    return rows.isEmpty ? null : rows.first['id'] as int;
  }

  // ---------------------------------------------------------------- settings

  Future<String?> getSetting(String key) async {
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) =>
      db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);

  // ---------------------------------------------------------------- stores

  Future<List<Store>> listStores() async =>
      (await db.query('stores', orderBy: 'id')).map(Store.fromMap).toList();

  Future<int> saveStore({int? id, required String name}) async {
    final data = {'name': name.trim()};
    if (id == null) return db.insert('stores', data);
    await db.update('stores', data, where: 'id = ?', whereArgs: [id]);
    return id;
  }

  Future<void> deleteStore(int id) => db.delete('stores', where: 'id = ?', whereArgs: [id]);

  Future<int?> defaultStore() => _defaultStore(db);

  // ---------------------------------------------------------------- dishes

  Future<List<Dish>> listDishes(String category) async {
    final rows = await db.rawQuery('''
      SELECT d.*,
        (SELECT COUNT(*) FROM dish_ingredients di WHERE di.dish_id = d.id) AS ing_count,
        (SELECT MAX(date(w.week_start, '+' || (pd.day_of_week - 1) || ' days'))
           FROM plan_items pi
           JOIN plan_days pd ON pd.id = pi.plan_day_id
           JOIN week_plans w ON w.id = pd.week_plan_id
          WHERE pi.dish_id = d.id AND pd.is_active = 1
            AND date(w.week_start, '+' || (pd.day_of_week - 1) || ' days') <= date('now', 'localtime')
        ) AS last_cooked
      FROM dishes d WHERE d.category = ? ORDER BY d.name COLLATE NOCASE
    ''', [category]);
    return rows.map(Dish.fromMap).toList();
  }

  Future<Dish?> getDish(int id) async {
    final rows = await db.query('dishes', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Dish.fromMap(rows.first);
  }

  Future<List<DishIngredient>> dishIngredients(int dishId) async {
    final rows = await db.rawQuery('''
      SELECT i.name, di.qty, di.unit FROM dish_ingredients di
      JOIN ingredients i ON i.id = di.ingredient_id
      WHERE di.dish_id = ? ORDER BY di.id
    ''', [dishId]);
    return rows
        .map((r) => DishIngredient(
              name: r['name'] as String,
              qty: (r['qty'] as num?)?.toDouble(),
              unit: (r['unit'] as String?) ?? '',
            ))
        .toList();
  }

  Future<int> saveDish({
    int? id,
    required String name,
    required String category,
    String? note,
    required List<DishIngredient> ingredients,
  }) {
    return db.transaction((txn) async {
      final data = {'name': name.trim(), 'category': category, 'note': note};
      int dishId;
      if (id == null) {
        dishId = await txn.insert('dishes', {...data, 'created_at': DateTime.now().toIso8601String()});
      } else {
        dishId = id;
        await txn.update('dishes', data, where: 'id = ?', whereArgs: [id]);
        await txn.delete('dish_ingredients', where: 'dish_id = ?', whereArgs: [id]);
      }
      final store = await _defaultStore(txn);
      for (final ing in ingredients) {
        if (ing.name.trim().isEmpty) continue;
        final ingId = await _ensureIng(txn, ing.name, ing.unit, storeId: store);
        await txn.insert('dish_ingredients',
            {'dish_id': dishId, 'ingredient_id': ingId, 'qty': ing.qty, 'unit': ing.unit.trim()});
      }
      return dishId;
    });
  }

  Future<void> deleteDish(int id) => db.delete('dishes', where: 'id = ?', whereArgs: [id]);

  // ---------------------------------------------------------------- weeks

  Future<int> ensureWeek(DateTime monday, List<int> defaultDays) => _ensureWeekOn(db, monday, defaultDays);

  static Future<int> _ensureWeekOn(DatabaseExecutor db, DateTime monday, List<int> defaultDays) async {
    final key = isoDate(monday);
    final rows = await db.query('week_plans', columns: ['id'], where: 'week_start = ?', whereArgs: [key]);
    if (rows.isNotEmpty) return rows.first['id'] as int;
    final id = await db.insert('week_plans', {'week_start': key, 'created_at': DateTime.now().toIso8601String()});
    for (var d = 1; d <= 7; d++) {
      await db.insert('plan_days',
          {'week_plan_id': id, 'day_of_week': d, 'is_active': defaultDays.contains(d) ? 1 : 0});
    }
    return id;
  }

  Future<int?> findWeekId(DateTime monday) async {
    final rows = await db.query('week_plans',
        columns: ['id'], where: 'week_start = ?', whereArgs: [isoDate(monday)]);
    return rows.isEmpty ? null : rows.first['id'] as int;
  }

  Future<WeekPlan> getWeek(int id) async {
    final w = (await db.query('week_plans', where: 'id = ?', whereArgs: [id])).first;
    final days = await db.query('plan_days', where: 'week_plan_id = ?', whereArgs: [id], orderBy: 'day_of_week');
    final items = await db.rawQuery('''
      SELECT pi.id, pi.plan_day_id, d.id AS dish_id, d.name, d.category
      FROM plan_items pi
      JOIN dishes d ON d.id = pi.dish_id
      JOIN plan_days pd ON pd.id = pi.plan_day_id
      WHERE pd.week_plan_id = ?
      ORDER BY pi.sort_order, pi.id
    ''', [id]);
    return WeekPlan(
      id: id,
      start: DateTime.parse(w['week_start'] as String),
      finishedAt: w['finished_at'] as String?,
      days: [
        for (final d in days)
          PlanDay(
            id: d['id'] as int,
            dow: d['day_of_week'] as int,
            active: d['is_active'] == 1,
            items: items.where((i) => i['plan_day_id'] == d['id']).map(PlanItem.fromMap).toList(),
          ),
      ],
    );
  }

  Future<void> setDayActive(int dayId, bool active) =>
      db.update('plan_days', {'is_active': active ? 1 : 0}, where: 'id = ?', whereArgs: [dayId]);

  Future<void> addDishes(int dayId, List<int> dishIds) {
    return db.transaction((txn) async {
      final r = await txn.rawQuery(
          'SELECT COALESCE(MAX(sort_order), -1) AS m FROM plan_items WHERE plan_day_id = ?', [dayId]);
      var order = (r.first['m'] as int) + 1;
      for (final id in dishIds) {
        await txn.insert('plan_items', {'plan_day_id': dayId, 'dish_id': id, 'sort_order': order++});
      }
      await txn.update('plan_days', {'is_active': 1}, where: 'id = ?', whereArgs: [dayId]);
    });
  }

  Future<void> removePlanItem(int id) => db.delete('plan_items', where: 'id = ?', whereArgs: [id]);

  /// Salin menu (hari aktif + isi) dari satu minggu ke minggu lain.
  Future<void> copyWeek(int fromId, int toId) async {
    final from = await getWeek(fromId);
    final to = await getWeek(toId);
    await db.transaction((txn) async {
      for (final d in to.days) {
        await txn.delete('plan_items', where: 'plan_day_id = ?', whereArgs: [d.id]);
      }
      for (final d in from.days) {
        final target = to.day(d.dow);
        await txn.update('plan_days', {'is_active': d.active ? 1 : 0}, where: 'id = ?', whereArgs: [target.id]);
        var order = 0;
        for (final it in d.items) {
          await txn.insert('plan_items', {'plan_day_id': target.id, 'dish_id': it.dishId, 'sort_order': order++});
        }
      }
    });
  }

  Future<void> finishWeek(int weekId) => db.update('week_plans',
      {'finished_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [weekId]);

  Future<List<WeekSummary>> weekSummaries() async {
    final weeks = await db.query('week_plans', columns: ['id'], orderBy: 'week_start DESC', limit: 40);
    final out = <WeekSummary>[];
    for (final w in weeks) {
      final plan = await getWeek(w['id'] as int);
      if (plan.laukCount + plan.cemilanCount == 0) continue;
      final t = await db.rawQuery(
          'SELECT SUM(price) AS t FROM shopping_items WHERE week_plan_id = ? AND is_checked = 1', [plan.id]);
      out.add(WeekSummary(plan: plan, total: t.first['t'] as int?));
    }
    return out;
  }

  /// Total belanja (item dicentang) untuk minggu-minggu yang dimulai di bulan [month].
  Future<(int total, int weeks)> monthSpend(DateTime month) async {
    final key = isoDate(month).substring(0, 7);
    final r = await db.rawQuery('''
      SELECT COALESCE(SUM(s.price), 0) AS total, COUNT(DISTINCT w.id) AS weeks
      FROM shopping_items s JOIN week_plans w ON w.id = s.week_plan_id
      WHERE s.is_checked = 1 AND s.price IS NOT NULL AND substr(w.week_start, 1, 7) = ?
    ''', [key]);
    return ((r.first['total'] as int?) ?? 0, (r.first['weeks'] as int?) ?? 0);
  }

  // ---------------------------------------------------------------- shopping

  /// Jumlahkan bahan dari semua menu di hari aktif. Item manual dan item yang
  /// sudah dicentang tidak dihapus. Mengembalikan jumlah bahan hasil generate.
  Future<int> generateShopping(int weekId) {
    return db.transaction((txn) async {
      final agg = await txn.rawQuery('''
        SELECT i.id AS ingredient_id, i.name, di.unit,
               SUM(di.qty) AS qty, COUNT(di.qty) AS qn,
               i.default_store_id AS store_id, i.default_buy_mode AS buy_mode,
               GROUP_CONCAT(DISTINCT d.name) AS sources
        FROM plan_items pi
        JOIN plan_days pd ON pd.id = pi.plan_day_id AND pd.is_active = 1
        JOIN dishes d ON d.id = pi.dish_id
        JOIN dish_ingredients di ON di.dish_id = d.id
        JOIN ingredients i ON i.id = di.ingredient_id
        WHERE pd.week_plan_id = ?
        GROUP BY i.id, di.unit
        ORDER BY i.name COLLATE NOCASE
      ''', [weekId]);
      final kept = await txn.query('shopping_items',
          where: 'week_plan_id = ? AND is_manual = 0 AND is_checked = 1', whereArgs: [weekId]);
      final keptKeys = {for (final k in kept) '${k['ingredient_id']}|${k['unit']}': k['id'] as int};
      await txn.delete('shopping_items',
          where: 'week_plan_id = ? AND is_manual = 0 AND is_checked = 0', whereArgs: [weekId]);
      for (final r in agg) {
        final key = '${r['ingredient_id']}|${r['unit']}';
        final qty = (r['qn'] as int) > 0 ? (r['qty'] as num?)?.toDouble() : null;
        final values = {'qty': qty, 'sources': r['sources']};
        final keptId = keptKeys[key];
        if (keptId != null) {
          await txn.update('shopping_items', values, where: 'id = ?', whereArgs: [keptId]);
        } else {
          await txn.insert('shopping_items', {
            ...values,
            'week_plan_id': weekId,
            'ingredient_id': r['ingredient_id'],
            'name': r['name'],
            'unit': r['unit'] ?? '',
            'is_manual': 0,
            'is_checked': 0,
            'store_id': r['store_id'],
            'buy_mode': r['buy_mode'] ?? 'eceran',
          });
        }
      }
      return agg.length;
    });
  }

  Future<List<ShopItem>> listShopping(int weekId) async {
    final rows = await db.rawQuery('''
      SELECT s.*, st.name AS store_name
      FROM shopping_items s LEFT JOIN stores st ON st.id = s.store_id
      WHERE s.week_plan_id = ?
      ORDER BY s.is_manual, s.name COLLATE NOCASE
    ''', [weekId]);
    return rows.map(ShopItem.fromMap).toList();
  }

  Future<void> addManual(int weekId, String name,
          {double? qty, String unit = '', int? storeId, String buyMode = 'eceran'}) =>
      db.insert('shopping_items', {
        'week_plan_id': weekId,
        'name': name.trim(),
        'qty': qty,
        'unit': unit,
        'is_manual': 1,
        'is_checked': 0,
        'store_id': storeId,
        'buy_mode': buyMode,
      });

  Future<void> updateShopQty(int id, double? qty, String unit) =>
      db.update('shopping_items', {'qty': qty, 'unit': unit.trim()}, where: 'id = ?', whereArgs: [id]);

  Future<void> setShopStore(int id, int? storeId) =>
      db.update('shopping_items', {'store_id': storeId}, where: 'id = ?', whereArgs: [id]);

  /// Ubah cara beli satu item. Pilihannya diingat sebagai default bahan itu
  /// supaya generate minggu berikutnya tidak perlu diatur ulang.
  Future<void> setShopBuyMode(ShopItem item, String mode) async {
    await db.update('shopping_items', {'buy_mode': mode}, where: 'id = ?', whereArgs: [item.id]);
    if (item.ingredientId != null) {
      await db.update('ingredients', {'default_buy_mode': mode},
          where: 'id = ?', whereArgs: [item.ingredientId]);
    }
  }

  Future<void> setShopChecked(int id, bool checked) =>
      db.update('shopping_items', {'is_checked': checked ? 1 : 0}, where: 'id = ?', whereArgs: [id]);

  Future<void> setShopPrice(ShopItem item, int? price) async {
    await db.update('shopping_items', {'price': price}, where: 'id = ?', whereArgs: [item.id]);
    if (price != null && item.ingredientId != null) {
      await db.update('ingredients', {'last_price': price}, where: 'id = ?', whereArgs: [item.ingredientId]);
    }
  }

  Future<void> deleteShopItem(int id) => db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
}
