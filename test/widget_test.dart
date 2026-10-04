import 'package:beres/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mondayOf mengembalikan hari Senin', () {
    expect(mondayOf(DateTime(2026, 10, 8)), DateTime(2026, 10, 5)); // Kamis -> Senin
    expect(mondayOf(DateTime(2026, 10, 11)), DateTime(2026, 10, 5)); // Minggu -> Senin
    expect(mondayOf(DateTime(2026, 10, 5)), DateTime(2026, 10, 5));
  });

  test('qtyText dan parseQty', () {
    expect(qtyText(200, 'gr'), '200 gr');
    expect(qtyText(1.5, 'kg'), '1,5 kg');
    expect(qtyText(null, ''), '');
    expect(parseQty('1,5'), 1.5);
    expect(parseQty(''), isNull);
  });
}
