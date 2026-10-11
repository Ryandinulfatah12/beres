import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/refresh.dart';
import '../widgets/mascot.dart';
import 'dish_detail_screen.dart';
import 'pick_dish_sheet.dart';
import 'settings_screen.dart';

class _HomeData {
  _HomeData(this.week, this.shop, this.month, this.tomorrow);
  final WeekPlan week;
  final List<ShopItem> shop;
  final (int, int) month;

  /// Hari esok — di hari Minggu diambil dari minggu berikutnya, supaya Beranda
  /// tidak kehilangan pengingatnya persis saat menu baru perlu disiapkan.
  final PlanDay? tomorrow;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: DataBuilder<_HomeData>(
        load: (app) async {
          final now = DateTime.now();
          final id = await app.thisWeekId();
          final week = await app.repo.getWeek(id);
          PlanDay? tomorrow;
          if (now.weekday < 7) {
            tomorrow = week.day(now.weekday + 1);
          } else {
            final nextId = await app.repo.ensureWeek(addDays(mondayOf(now), 7), app.defaultDays);
            tomorrow = (await app.repo.getWeek(nextId)).day(1);
          }
          return _HomeData(
            week,
            await app.repo.listShopping(id),
            await app.repo.monthSpend(now),
            tomorrow,
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

    final checked = d.shop.where((s) => s.checked).length;
    final total = d.shop.length;
    final activeDays = d.week.activeDays;
    final filledDays = d.week.days.where((x) => x.active && x.items.isNotEmpty).length;

    PlanDay? empty;
    for (final day in d.week.days) {
      if (day.dow > now.weekday && day.active && day.items.isEmpty) {
        empty = day;
        break;
      }
    }

    return BeresRefresh(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        // --- Sapaan: maskot sebagai avatar, nama, lalu pintasan pengaturan. ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
          child: Row(
            children: [
              const MascotAvatar(size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting(now),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BC.muted)),
                    const SizedBox(height: 1),
                    Text(app.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: fredoka(19, weight: FontWeight.w600, color: BC.ink)),
                  ],
                ),
              ),
              SquareIconButton(
                icon: Icons.settings_outlined,
                tooltip: 'Pengaturan',
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
        ),

        // --- Judul besar: satu-satunya tempat tanggal disebut. ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullDate(now).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800, color: BC.pandan, letterSpacing: 1.1)),
              const SizedBox(height: 6),
              Text('Menu hari ini', style: fredoka(30, weight: FontWeight.w600, color: BC.ink)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        FadeIn(delay: 80, child: _TodayCard(day: today)),

        const SizedBox(height: 12),
        FadeIn(
          delay: 160,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Belanja',
                      value: total == 0 ? 'Kosong' : '${total - checked} item',
                      sub: total == 0 ? 'Buat dari menu' : '$checked/$total dibeli',
                      accent: BC.cabai,
                      progress: total == 0 ? 0 : checked / total,
                      onTap: () => app.setTab(2),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: StatTile(
                      label: 'Menu minggu',
                      value: '$filledDays/$activeDays',
                      sub: 'hari terisi',
                      accent: BC.pandan,
                      progress: activeDays == 0 ? 0 : filledDays / activeDays,
                      onTap: () => app.goToWeek(mondayOf(now)),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: StatTile(
                      label: 'Bulan ${monthShort(now)}',
                      value: rupiahShort(d.month.$1),
                      sub: '${d.month.$2}x belanja',
                      accent: BC.kunyitDark,
                      onTap: () => app.setTab(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (d.tomorrow != null) ...[
          const SizedBox(height: 12),
          FadeIn(
            delay: 220,
            child: _TomorrowCard(
              day: d.tomorrow!,
              // Minggu: "besok" ada di minggu berikutnya, jadi ketukannya pun
              // harus mendarat di sana.
              weekStart: now.weekday < 7 ? mondayOf(now) : addDays(mondayOf(now), 7),
            ),
          ),
        ],

        const SizedBox(height: 12),
        FadeIn(
          delay: 280,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // Wrap, bukan Row: di layar sempit tombolnya turun ke baris kedua
            // daripada teksnya terpotong.
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                PillButton(
                  icon: Icons.add_rounded,
                  label: 'Menu baru',
                  filled: true,
                  onTap: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DishDetailScreen())),
                ),
                PillButton(
                  icon: Icons.copy_rounded,
                  label: 'Salin minggu lalu',
                  onTap: () => _copyLastWeek(context),
                ),
              ],
            ),
          ),
        ),

        if (empty != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _IdeaCard(day: empty, weekStart: d.week.start),
          ),
        ],
      ],
    );
  }
}

/// Kartu utama Beranda: menu hari ini dengan gradasi hijau, bulatan hias, dan
/// Si Beres di sampingnya.
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.day});
  final PlanDay day;

  @override
  Widget build(BuildContext context) {
    final app = appOf(context);
    final now = DateTime.now();
    final lauk = day.lauk;
    final cemilan = day.cemilan;
    final kosong = day.active && lauk.isEmpty && cemilan.isEmpty;

    final title = !day.active
        ? 'Libur masak'
        : kosong
            ? 'Belum ada menu'
            : lauk.isEmpty
                ? cemilan.map((i) => i.name).join(', ')
                : lauk.map((i) => i.name).join(', ');

    final (chipText, chipIcon) = !day.active
        ? ('Hari santai', Icons.weekend_rounded)
        : kosong
            ? ('Masih kosong', Icons.edit_calendar_rounded)
            : ('Siap dimasak', Icons.local_fire_department_rounded);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BR.cardR,
          boxShadow: softShadow,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BC.heroFrom, BC.heroTo],
          ),
        ),
        child: Stack(
          children: [
            // Bulatan hias — memberi kedalaman tanpa gambar tambahan.
            Positioned(
              right: -34,
              top: -46,
              child: _Blob(size: 150, color: Colors.white.withValues(alpha: 0.07)),
            ),
            Positioned(
              right: 56,
              bottom: -52,
              child: _Blob(size: 110, color: Colors.white.withValues(alpha: 0.05)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
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
                            Container(
                              padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BR.pillR,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(chipIcon, size: 13, color: BC.kunyit),
                                  const SizedBox(width: 5),
                                  Text(chipText,
                                      style: const TextStyle(
                                          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: fredoka(22, color: Colors.white)),
                            if (day.active && cemilan.isNotEmpty && lauk.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.cookie_rounded, size: 13, color: Color(0xFFBFD9C9)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(cemilan.map((i) => i.name).join(', '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFD7E7DD),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Mascot(
                        size: 86,
                        steam: kosong ? Steam.question : Steam.check,
                        eyes: Eyes.happy,
                        body: BC.kunyit,
                        dark: BC.kunyitDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  kosong
                      ? _HeroButton(
                          label: 'Isi menu hari ini',
                          icon: Icons.add_rounded,
                          onTap: () => showPickDishSheet(context,
                              dayId: day.id, dayLabel: '${dayNames[day.dow - 1]}, ${dayMonth(now)}'),
                        )
                      : _HeroButton(
                          label: 'Lihat minggu ini',
                          icon: Icons.chevron_right_rounded,
                          onTap: () => app.goToWeek(mondayOf(now)),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Isi kartu di-stack, jadi tombolnya butuh ruang sendiri di bawah konten.
class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BR.pillR,
        child: InkWell(
          borderRadius: BR.pillR,
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: BC.daun)),
                const SizedBox(width: 4),
                Icon(icon, size: 18, color: BC.daun),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Baris ringkas "besok masak apa" — satu-satunya pengingat ke depan di Beranda.
class _TomorrowCard extends StatelessWidget {
  const _TomorrowCard({required this.day, required this.weekStart});
  final PlanDay day;
  final DateTime weekStart;

  @override
  Widget build(BuildContext context) {
    final app = appOf(context);
    final names = day.items.map((i) => i.name).join(', ');
    final text = !day.active ? 'Libur masak' : (names.isEmpty ? 'Belum ada menu' : names);
    final kosong = day.active && day.items.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BoxCard(
        padding: const EdgeInsets.all(12),
        onTap: () => app.goToWeek(weekStart),
        child: Row(
          children: [
            SoftIcon(
              kosong ? Icons.event_busy_rounded : Icons.wb_twilight_rounded,
              bg: kosong ? BC.orangeSoft : BC.mint,
              fg: kosong ? BC.orangeText : BC.greenText,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Besok, ${dayNames[day.dow - 1]}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: BC.muted)),
                  const SizedBox(height: 2),
                  Text(text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: BC.ink)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: BC.muted),
          ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BC.mint,
        borderRadius: BR.cardR,
        border: Border.all(color: BC.mintLine),
      ),
      child: Row(
        children: [
          const SoftIcon(Icons.lightbulb_rounded, bg: BC.kunyitSoft, fg: BC.kunyitText, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name masih kosong',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: BC.ink)),
                const Text('Isi sekarang biar nanti tidak bingung.', style: mutedText),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => showPickDishSheet(context, dayId: day.id, dayLabel: '$name, ${dayMonth(date)}'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Isi'),
          ),
        ],
      ),
    );
  }
}
