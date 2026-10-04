class Store {
  Store({required this.id, required this.name});
  final int id;
  final String name;

  factory Store.fromMap(Map<String, Object?> m) =>
      Store(id: m['id'] as int, name: m['name'] as String);
}

class Dish {
  Dish({
    required this.id,
    required this.name,
    required this.category,
    this.note,
    this.ingredientCount = 0,
    this.lastCooked,
  });
  final int id;
  final String name;
  final String category; // 'lauk' | 'cemilan'
  final String? note;
  final int ingredientCount;
  final String? lastCooked; // yyyy-MM-dd

  factory Dish.fromMap(Map<String, Object?> m) => Dish(
        id: m['id'] as int,
        name: m['name'] as String,
        category: m['category'] as String,
        note: m['note'] as String?,
        ingredientCount: (m['ing_count'] as int?) ?? 0,
        lastCooked: m['last_cooked'] as String?,
      );
}

class DishIngredient {
  DishIngredient({required this.name, this.qty, this.unit = ''});
  final String name;
  final double? qty;
  final String unit;
}

class PlanItem {
  PlanItem({required this.id, required this.dishId, required this.name, required this.category});
  final int id;
  final int dishId;
  final String name;
  final String category;

  bool get isLauk => category == 'lauk';

  factory PlanItem.fromMap(Map<String, Object?> m) => PlanItem(
        id: m['id'] as int,
        dishId: m['dish_id'] as int,
        name: m['name'] as String,
        category: m['category'] as String,
      );
}

class PlanDay {
  PlanDay({required this.id, required this.dow, required this.active, required this.items});
  final int id;
  final int dow; // 1 = Senin ... 7 = Minggu
  final bool active;
  final List<PlanItem> items;

  List<PlanItem> get lauk => items.where((i) => i.isLauk).toList();
  List<PlanItem> get cemilan => items.where((i) => !i.isLauk).toList();
}

class WeekPlan {
  WeekPlan({required this.id, required this.start, required this.days, this.finishedAt});
  final int id;
  final DateTime start;
  final List<PlanDay> days;
  final String? finishedAt;

  PlanDay day(int dow) => days.firstWhere((d) => d.dow == dow);
  int get activeDays => days.where((d) => d.active).length;
  int get laukCount => days.where((d) => d.active).fold(0, (a, d) => a + d.lauk.length);
  int get cemilanCount => days.where((d) => d.active).fold(0, (a, d) => a + d.cemilan.length);
  List<String> get laukNames =>
      [for (final d in days.where((d) => d.active)) ...d.lauk.map((i) => i.name)];
}

class ShopItem {
  ShopItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.manual,
    required this.checked,
    this.ingredientId,
    this.qty,
    this.price,
    this.storeId,
    this.storeName,
    this.buyMode = 'eceran',
    this.sources,
  });
  final int id;
  final int? ingredientId;
  final String name;
  final double? qty;
  final String unit;
  final bool manual;
  final bool checked;
  final int? price;
  final int? storeId;
  final String? storeName;

  /// Cara beli item ini: 'eceran' atau 'grosir'. Melekat ke item, bukan ke toko,
  /// karena satu toko bisa melayani keduanya.
  final String buyMode;
  final String? sources;

  bool get grosir => buyMode == 'grosir';

  factory ShopItem.fromMap(Map<String, Object?> m) => ShopItem(
        id: m['id'] as int,
        ingredientId: m['ingredient_id'] as int?,
        name: m['name'] as String,
        qty: (m['qty'] as num?)?.toDouble(),
        unit: (m['unit'] as String?) ?? '',
        manual: m['is_manual'] == 1,
        checked: m['is_checked'] == 1,
        price: m['price'] as int?,
        storeId: m['store_id'] as int?,
        storeName: m['store_name'] as String?,
        buyMode: (m['buy_mode'] as String?) ?? 'eceran',
        sources: m['sources'] as String?,
      );
}

class WeekSummary {
  WeekSummary({required this.plan, this.total});
  final WeekPlan plan;
  final int? total;
}
