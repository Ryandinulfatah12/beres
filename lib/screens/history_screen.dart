import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class _HistoryData {
  _HistoryData(this.weeks, this.month);
  final List<WeekSummary> weeks;
  final (int, int) month;
}

/// Satu bulan beserta minggu-minggunya, terbaru di atas.
class _Month {
  _Month(this.start);
  final DateTime start;
  final List<WeekSummary> weeks = [];

  /// Hanya menjumlahkan minggu yang sudah ada belanjanya.
  int get total => weeks.fold(0, (a, w) => a + (w.total ?? 0));
  int get shopped => weeks.where((w) => w.total != null).length;
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DataBuilder<_HistoryData>(
        load: (app) async =>
            _HistoryData(await app.repo.weekSummaries(), await app.repo.monthSpend(DateTime.now())),
        builder: (context, d) => _body(context, d),
      ),
    );
  }

  Future<void> _copy(BuildContext context, WeekSummary w) async {
    final app = appOf(context);
    final ok = await confirm(context,
        title: 'Salin ke minggu ini?',
        message: 'Menu minggu ini akan diganti dengan menu ${weekRange(w.plan.start)}.',
        ok: 'Salin');
    if (!ok) return;
    await app.repo.copyWeek(w.plan.id, await app.thisWeekId());
    app.changed();
    if (context.mounted) showSnack(context, 'Menu sudah disalin ke minggu ini.');
  }

  /// Kelompokkan minggu per bulan, urutan dari weekSummaries dipertahankan.
  List<_Month> _byMonth(List<WeekSummary> weeks) {
    final out = <_Month>[];
    for (final w in weeks) {
      final first = DateTime(w.plan.start.year, w.plan.start.month);
      if (out.isEmpty || out.last.start != first) out.add(_Month(first));
      out.last.weeks.add(w);
    }
    return out;
  }

  Widget _body(BuildContext context, _HistoryData d) {
    final app = appOf(context);
    final thisMonday = mondayOf(DateTime.now());
    final months = _byMonth(d.weeks);

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const ScreenHeader(eyebrow: 'Minggu-minggu sebelumnya', title: 'Riwayat'),
        _MonthHero(total: d.month.$1, times: d.month.$2),
        if (months.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: EmptyState(
              title: 'Belum ada riwayat',
              message: 'Setelah kamu menyusun menu dan belanja, minggunya tersimpan di sini.',
            ),
          ),
        for (var m = 0; m < months.length; m++)
          FadeIn(
            delay: 70 * m,
            child: _MonthSection(
              month: months[m],
              thisMonday: thisMonday,
              onCopy: (w) => _copy(context, w),
              onOpen: (w) => app.goToWeek(w.plan.start),
            ),
          ),
      ],
    );
  }
}

/// Kartu hijau di atas: pengeluaran bulan berjalan.
class _MonthHero extends StatelessWidget {
  const _MonthHero({required this.total, required this.times});
  final int total;
  final int times;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: BC.daun, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Belanja ${monthName(DateTime.now())}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFCFE3D6))),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(rupiah(total),
                      style: fredoka(26, weight: FontWeight.w700, color: Colors.white)),
                ),
                Text(times == 0 ? 'Belum belanja bulan ini' : '$times kali belanja',
                    style: const TextStyle(fontSize: 13, color: Color(0xFFE7F1EA))),
              ],
            ),
          ),
          const Icon(Icons.schedule_rounded, color: BC.kunyit, size: 48),
        ],
      ),
    );
  }
}

/// Judul bulan + totalnya, lalu satu kartu berisi baris-baris minggu.
class _MonthSection extends StatelessWidget {
  const _MonthSection({
    required this.month,
    required this.thisMonday,
    required this.onCopy,
    required this.onOpen,
  });
  final _Month month;
  final DateTime thisMonday;
  final void Function(WeekSummary) onCopy;
  final void Function(WeekSummary) onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(monthName(month.start), style: fredoka(16)),
                ),
                if (month.shopped > 0)
                  Text(rupiah(month.total),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800, color: BC.muted)),
              ],
            ),
          ),
          ListCard(children: [
            for (final w in month.weeks)
              _WeekRow(
                summary: w,
                isCurrent: sameDay(w.plan.start, thisMonday),
                onCopy: () => onCopy(w),
                onOpen: () => onOpen(w),
              ),
          ]),
        ],
      ),
    );
  }
}

/// Satu minggu. Seluruh baris bisa diketuk untuk membuka minggunya;
/// menyalin cukup satu ikon kecil, bukan tombol penuh seperti sebelumnya.
class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.summary,
    required this.isCurrent,
    required this.onCopy,
    required this.onOpen,
  });
  final WeekSummary summary;
  final bool isCurrent;
  final VoidCallback onCopy;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = summary.plan;
    final names = p.laukNames;
    final shown = names.take(3).toList();
    final rest = names.length - shown.length;
    final belum = summary.total == null;

    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(weekRange(p.start),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            const Tag('Minggu ini', TagKind.lauk),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text('${p.activeDays} hari · ${p.laukCount} lauk · ${p.cemilanCount} cemilan',
                          style: mutedText),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(belum ? 'Belum belanja' : rupiah(summary.total),
                      style: TextStyle(
                        fontSize: belum ? 12 : 15,
                        fontWeight: belum ? FontWeight.w600 : FontWeight.w800,
                        color: belum ? BC.muted : BC.arang,
                      )),
                ),
                // Satu kontrol kecil di ujung, bukan tombol penuh per baris.
                SizedBox(
                  width: 36,
                  height: 36,
                  child: isCurrent
                      ? null
                      : IconButton(
                          tooltip: 'Salin ke minggu ini',
                          onPressed: onCopy,
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          color: BC.pandan,
                          icon: const Icon(Icons.copy_rounded),
                        ),
                ),
              ],
            ),
            if (shown.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final n in shown) _MenuChip(n),
                    if (rest > 0) _MenuChip('+$rest lainnya', quiet: true),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Nama lauk sebagai chip kecil — lebih mudah dipindai daripada satu
/// kalimat panjang dipisah koma.
class _MenuChip extends StatelessWidget {
  const _MenuChip(this.text, {this.quiet = false});
  final String text;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: quiet ? Colors.transparent : BC.santan,
        borderRadius: BorderRadius.circular(99),
        border: quiet ? Border.all(color: BC.line) : null,
      ),
      child: Text(text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: quiet ? BC.muted : const Color(0xFF3D4A41),
          )),
    );
  }
}
