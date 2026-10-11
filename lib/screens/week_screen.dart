import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/refresh.dart';
import '../widgets/mascot.dart';
import 'pick_dish_sheet.dart';

class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DataBuilder<WeekPlan>(
        load: (app) async => app.repo.getWeek(await app.weekId()),
        builder: (context, week) => _WeekBody(week),
      ),
    );
  }
}

class _WeekBody extends StatelessWidget {
  const _WeekBody(this.week);
  final WeekPlan week;

  Future<void> _generate(BuildContext context) async {
    final app = appOf(context);
    final n = await app.repo.generateShopping(week.id);
    app.changed();
    if (n > 0) app.setTab(2);
    if (!context.mounted) return;
    showSnack(
      context,
      n > 0
          ? '$n bahan sudah dijumlahkan dari menu minggu ini.'
          : 'Menu minggu ini belum punya bahan. Tambahkan bahannya di halaman Menu.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = appOf(context);
    final isThisWeek = sameDay(week.start, mondayOf(DateTime.now()));
    final ready = week.laukCount + week.cemilanCount > 0;
    return Column(
      children: [
        ScreenHeader(
          eyebrow: isThisWeek ? 'Minggu ini' : 'Rencana minggu',
          title: weekRange(week.start),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SquareIconButton(
                  icon: Icons.chevron_left_rounded, tooltip: 'Minggu sebelumnya', onPressed: () => app.shiftWeek(-1)),
              const SizedBox(width: 8),
              SquareIconButton(
                  icon: Icons.chevron_right_rounded, tooltip: 'Minggu berikutnya', onPressed: () => app.shiftWeek(1)),
            ],
          ),
        ),
        Expanded(
          child: BeresRefresh(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              FadeIn(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                  decoration: BoxDecoration(color: BC.greenSoft, borderRadius: BR.pillR),
                  child: Row(
                    children: [
                      Mascot(
                        size: 64,
                        steam: ready ? Steam.check : Steam.question,
                        eyes: ready ? Eyes.happy : Eyes.up,
                        wave: ready,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ready ? 'Menu minggu ini siap!' : 'Yuk, susun menu minggu ini',
                                style: fredoka(16, color: BC.daun)),
                            const SizedBox(height: 2),
                            Text(
                              '${week.activeDays} hari masak, ${week.laukCount} lauk, ${week.cemilanCount} cemilan',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BC.greenText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < week.days.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FadeIn(delay: 60 * i + 80, child: _DayCard(week: week, day: week.days[i])),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: FilledButton.icon(
            onPressed: () => _generate(context),
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Generate daftar belanja'),
          ),
        ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.week, required this.day});
  final WeekPlan week;
  final PlanDay day;

  @override
  Widget build(BuildContext context) {
    final app = appOf(context);
    final date = addDays(week.start, day.dow - 1);
    final isToday = sameDay(date, DateTime.now());
    final name = dayNames[day.dow - 1];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 8),
      decoration: BoxDecoration(
        color: day.active ? Colors.white : Colors.transparent,
        borderRadius: BR.cardR,
        border: Border.all(color: isToday ? BC.pandan : BC.line, width: isToday ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: day.active ? BC.arang : BC.muted,
                            )),
                        if (isToday) ...[const SizedBox(width: 8), const Tag('Hari ini', TagKind.lauk)],
                      ],
                    ),
                    Text(day.active ? dayMonth(date) : '${dayMonth(date)}, tidak masak', style: mutedText),
                  ],
                ),
              ),
              const Text('Masak', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: BC.muted)),
              Checkbox(
                value: day.active,
                onChanged: (v) async {
                  await app.repo.setDayActive(day.id, v ?? false);
                  app.changed();
                },
              ),
            ],
          ),
          if (day.active) ...[
            _ItemRow(label: 'Lauk', kind: TagKind.lauk, items: day.lauk),
            _ItemRow(label: 'Cemilan', kind: TagKind.cemilan, items: day.cemilan),
            TextButton.icon(
              onPressed: () => showPickDishSheet(context, dayId: day.id, dayLabel: '$name, ${dayMonth(date)}'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah menu'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.label, required this.kind, required this.items});
  final String label;
  final TagKind kind;
  final List<PlanItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final app = appOf(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Align(alignment: Alignment.centerLeft, child: Tag(label, kind)),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final it in items)
                  Container(
                    padding: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(color: BC.santan, borderRadius: BR.pillR),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(it.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                        IconButton(
                          tooltip: 'Hapus ${it.name}',
                          iconSize: 16,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close_rounded, color: BC.muted),
                          onPressed: () async {
                            await app.repo.removePlanItem(it.id);
                            app.changed();
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
