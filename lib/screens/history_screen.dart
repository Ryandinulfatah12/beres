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

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DataBuilder<_HistoryData>(
        load: (app) async => _HistoryData(await app.repo.weekSummaries(), await app.repo.monthSpend(DateTime.now())),
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

  Widget _body(BuildContext context, _HistoryData d) {
    final app = appOf(context);
    final thisMonday = mondayOf(DateTime.now());
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const ScreenHeader(eyebrow: 'Minggu-minggu sebelumnya', title: 'Riwayat'),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: BC.daun, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Belanja ${monthName(DateTime.now())}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFCFE3D6))),
                    const SizedBox(height: 4),
                    Text(rupiah(d.month.$1), style: fredoka(26, weight: FontWeight.w700, color: Colors.white)),
                    Text('${d.month.$2} kali belanja',
                        style: const TextStyle(fontSize: 13, color: Color(0xFFE7F1EA))),
                  ],
                ),
              ),
              const Icon(Icons.schedule_rounded, color: BC.kunyit, size: 48),
            ],
          ),
        ),
        if (d.weeks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text('Riwayat akan muncul setelah kamu menyusun menu.',
                textAlign: TextAlign.center, style: TextStyle(color: BC.muted)),
          ),
        for (var i = 0; i < d.weeks.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: FadeIn(
              delay: 80 * i,
              child: _WeekCard(
                summary: d.weeks[i],
                isCurrent: sameDay(d.weeks[i].plan.start, thisMonday),
                onCopy: () => _copy(context, d.weeks[i]),
                onOpen: () => app.goToWeek(d.weeks[i].plan.start),
              ),
            ),
          ),
      ],
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.summary, required this.isCurrent, required this.onCopy, required this.onOpen});
  final WeekSummary summary;
  final bool isCurrent;
  final VoidCallback onCopy;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = summary.plan;
    final names = p.laukNames;
    final preview = names.length > 4 ? '${names.take(4).join(', ')}, +${names.length - 4} lainnya' : names.join(', ');
    return BoxCard(
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
                        Text(weekRange(p.start), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        if (isCurrent) ...[const SizedBox(width: 8), const Tag('Minggu ini', TagKind.lauk)],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${p.activeDays} hari, ${p.laukCount} lauk, ${p.cemilanCount} cemilan', style: mutedText),
                  ],
                ),
              ),
              Text(summary.total == null ? 'Belum belanja' : rupiah(summary.total),
                  style: TextStyle(
                    fontSize: summary.total == null ? 12 : 15,
                    fontWeight: FontWeight.w800,
                    color: summary.total == null ? BC.muted : BC.arang,
                  )),
            ],
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(preview, style: const TextStyle(fontSize: 13, color: Color(0xFF3D4A41), height: 1.4)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (!isCurrent) ...[
                FilledButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Salin ke minggu ini'),
                  style: FilledButton.styleFrom(
                    backgroundColor: BC.greenSoft,
                    foregroundColor: BC.daun,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              OutlinedButton(
                onPressed: onOpen,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lihat'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
