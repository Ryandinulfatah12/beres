import '../models.dart';
import 'format.dart';

/// Teks daftar belanja untuk dibagikan ke WhatsApp, dikelompokkan per toko.
String shoppingShareText(DateTime weekStart, List<ShopItem> items) {
  final groups = <String, List<ShopItem>>{};
  for (final i in items) {
    final key = i.storeName ?? 'Lainnya';
    groups.putIfAbsent(key, () => []).add(i);
  }
  final b = StringBuffer('Daftar belanja Beres? · ${weekRange(weekStart)}\n');
  for (final e in groups.entries) {
    b.writeln();
    b.writeln('*${e.key}*');
    for (final i in e.value) {
      final q = qtyText(i.qty, i.unit);
      final mode = i.grosir ? ' (grosir)' : '';
      b.writeln('${i.checked ? '☑' : '☐'} ${i.name}${q.isEmpty ? '' : ' — $q'}$mode');
    }
  }
  return b.toString();
}
