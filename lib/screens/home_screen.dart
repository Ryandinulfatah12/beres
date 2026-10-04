import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import 'dish_detail_screen.dart';
import 'pick_dish_sheet.dart';
import 'settings_screen.dart';

class _HomeData {
  _HomeData(this.week, this.shop, this.month);
  final WeekPlan week;
  final List<ShopItem> shop;
  final (int, int) month;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DataBuilder<_HomeData>(
        load: (app) async {
          final id = await app.thisWeekId();
          return _HomeData(
            await app.repo.getWeek(id),
            await app.repo.listShopping(id),
            await app.repo.monthSpend(DateTime.now()),
          );
        },
        builder: (context, d) => _HomeBody(d),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody(this.d);
  final _HomeData d;

  Future<void> _copyLastWeek(BuildContext context) async {
    final app = appOf(context);
    final prevId = await app.repo.findWeekId(addDays(mondayOf(DateTime.now()), -7));
    if (!context.mounted) return;
    if (prevId == null) {
      showSnack(context, 'Belum ada menu minggu lalu untuk disalin.');
      return;
    }
    final ok = await confirm(context,
        title: 'Salin menu minggu lalu?',
        message: 'Menu minggu ini akan diganti dengan menu minggu lalu.',
        ok: 'Salin');
    if (!ok) return;
    await app.repo.copyWeek(prevId, d.week.id);
    app.changed();
    if (context.mounted) showSnack(context, 'Menu minggu lalu sudah disalin.');
  }

  @override
  Widget build(BuildContext context) {
    final app = appOf(context);
    final now = DateTime.now();
    final today = d.week.day(now.weekday);
    final tomorrow = now.weekday < 7 ? d.week.day(now.weekday + 1) : null;
    final checked = d.shop.where((s) => s.checked).length;
    final total = d.shop.length;

    PlanDay? empty;
    for (final day in d.week.days) {
      if (day.dow > now.weekday && day.items.isEmpty) {
        empty = day;
        break;
      }
    }

    final lauk = today.lauk;
    final String bubble;
    if (!today.active) {
      bubble = 'Hari ini libur masak, santai dulu ya.';
    } else if (lauk.isEmpty) {
      bubble = 'Hari ini belum ada menu, mau isi sekarang?';
    } else {
      bubble = 'Hari ini ${lauk.first.name.toLowerCase()}, semangat masaknya!';
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
          child: Row(
            children: [
              const Wordmark(size: 26),
              const Spacer(),
              SquareIconButton(
                icon: Icons.settings_outlined,
                tooltip: 'Pengaturan',
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullDate(now),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: BC.muted)),
                    const SizedBox(height: 4),
                    Text('${greeting(now)}, ${app.name}!', style: fredoka(26)),
                    const SizedBox(height: 2),
                    const Text('Dapur siap, perut juga siap.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF3D4A41), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Mascot(size: 84, wave: true),
            ],
          ),
        ),
        FadeIn(
          delay: 250,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 56, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: BC.line),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: Text(bubble,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: BC.daun)),
              ),
            ),
          ),
        ),
        FadeIn(delay: 120, child: _TodayCard(day: today)),
        const SizedBox(height: 12),
        FadeIn(
          delay: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: BoxCard(
                      onTap: () => app.setTab(2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Belanja minggu ini',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: BC.muted)),
                          const SizedBox(height: 4),
                          Text(total == 0 ? 'Belum ada' : '${total - checked} item lagi',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          Text(total == 0 ? 'Generate dari menu' : '$checked dari $total sudah dibeli',
                              style: mutedText),
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: total == 0 ? 0 : checked / total),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutBack,
                            builder: (_, v, __) => LinearProgressIndicator(
                              value: v.clamp(0, 1),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(99),
                              color: BC.cabai,
                              backgroundColor: BC.lineSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BoxCard(
                      onTap: () => app.setTab(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pengeluaran ${monthShort(now)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: BC.muted)),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(rupiah(d.month.$1),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          ),
                          Text('${d.month.$2} kali belanja', style: mutedText),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (tomorrow != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionLabel('Besok, ${dayNames[tomorrow.dow - 1]}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BoxCard(
              onTap: () => app.goToWeek(mondayOf(now)),
              child: !tomorrow.active
                  ? const Text('Libur masak', style: TextStyle(color: BC.muted, fontWeight: FontWeight.w600))
                  : tomorrow.items.isEmpty
                      ? const Text('Belum ada menu', style: TextStyle(color: BC.muted, fontWeight: FontWeight.w600))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tomorrow.lauk.isNotEmpty)
                              _MenuLine(kind: TagKind.lauk, label: 'Lauk', items: tomorrow.lauk),
                            if (tomorrow.cemilan.isNotEmpty)
                              _MenuLine(kind: TagKind.cemilan, label: 'Cemilan', items: tomorrow.cemilan),
                          ],
                        ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuickAction(
                icon: Icons.add_rounded,
                label: 'Menu baru',
                green: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DishDetailScreen())),
              ),
              _QuickAction(icon: Icons.shopping_cart_outlined, label: 'Belanja', onTap: () => app.setTab(2)),
              _QuickAction(
                  icon: Icons.copy_rounded, label: 'Salin minggu lalu', green: true, onTap: () => _copyLastWeek(context)),
              _QuickAction(icon: Icons.history_rounded, label: 'Riwayat', onTap: () => app.setTab(4)),
            ],
          ),
        ),
        if (empty != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _IdeaCard(day: empty, weekStart: d.week.start),
          ),
        ],
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.day});
  final PlanDay day;

  @override
  Widget build(BuildContext context) {
    final app = appOf(context);
    final lauk = day.lauk.map((i) => i.name).join(', ');
    final cemilan = day.cemilan.map((i) => i.name).join(', ');
    final title = !day.active ? 'Libur masak' : (lauk.isEmpty ? 'Belum ada menu' : lauk);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: BC.daun, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Menu hari ini',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFCFE3D6))),
                const SizedBox(height: 4),
                Text(title, style: fredoka(20, color: Colors.white)),
                if (cemilan.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Cemilan: $cemilan', style: const TextStyle(fontSize: 13, color: Color(0xFFE7F1EA))),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => app.goToWeek(mondayOf(DateTime.now())),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('Lihat minggu ini'), SizedBox(width: 4), Icon(Icons.chevron_right_rounded, size: 18)],
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: BC.daun,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Mascot(size: 84, steam: Steam.check, eyes: Eyes.happy, body: BC.kunyit, dark: BC.kunyitDark),
        ],
      ),
    );
  }
}

class _MenuLine extends StatelessWidget {
  const _MenuLine({required this.kind, required this.label, required this.items});
  final TagKind kind;
  final String label;
  final List<PlanItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 76, child: Align(alignment: Alignment.centerLeft, child: Tag(label, kind))),
          Expanded(
            child: Text(items.map((i) => i.name).join(', '),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap, this.green = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: green ? BC.greenSoft : BC.orangeSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: green ? BC.daun : BC.orangeText),
              ),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.day, required this.weekStart});
  final PlanDay day;
  final DateTime weekStart;

  @override
  Widget build(BuildContext context) {
    final name = dayNames[day.dow - 1];
    final date = addDays(weekStart, day.dow - 1);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3DBD0), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: BC.orangeText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name masih kosong', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text(day.active ? 'Mau masak apa?' : 'Mau masak di hari ini?', style: mutedText),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => showPickDishSheet(context, dayId: day.id, dayLabel: '$name, ${dayMonth(date)}'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 14)),
            child: const Text('Isi menu'),
          ),
        ],
      ),
    );
  }
}
