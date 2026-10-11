import 'package:intl/intl.dart';

const dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const dayShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
DateTime mondayOf(DateTime d) => addDays(dateOnly(d), -(d.weekday - 1));
bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String isoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
String dayMonth(DateTime d) => DateFormat('d MMM', 'id_ID').format(d);
String fullDate(DateTime d) => DateFormat('EEEE, d MMMM', 'id_ID').format(d);
String monthName(DateTime d) => DateFormat('MMMM yyyy', 'id_ID').format(d);
String monthShort(DateTime d) => DateFormat('MMM', 'id_ID').format(d);

String weekRange(DateTime start) {
  final end = addDays(start, 6);
  final endText = DateFormat('d MMM yyyy', 'id_ID').format(end);
  if (start.month == end.month) return '${start.day} – $endText';
  return '${dayMonth(start)} – $endText';
}

final NumberFormat _rp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
String rupiah(int? v) => _rp.format(v ?? 0);

/// Rupiah ringkas untuk kartu statistik sempit: 1.250.000 -> "Rp 1,2jt".
String rupiahShort(int? v) {
  final n = v ?? 0;
  String trim(double x) {
    final s = x.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s.replaceAll('.', ',');
  }

  if (n >= 1000000) return 'Rp ${trim(n / 1000000)}jt';
  if (n >= 10000) return 'Rp ${n ~/ 1000}rb';
  return rupiah(n);
}

String qtyText(double? q, String unit) {
  if (q == null) return unit;
  final n = q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1).replaceAll('.', ',');
  return unit.isEmpty ? n : '$n $unit';
}

double? parseQty(String s) {
  final t = s.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 11) return 'Selamat pagi';
  if (h < 15) return 'Selamat siang';
  if (h < 18) return 'Selamat sore';
  return 'Selamat malam';
}
