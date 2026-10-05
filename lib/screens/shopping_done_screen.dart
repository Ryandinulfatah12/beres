import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

class ShoppingDoneScreen extends StatefulWidget {
  const ShoppingDoneScreen({super.key, required this.weekId});
  final int weekId;

  @override
  State<ShoppingDoneScreen> createState() => _ShoppingDoneScreenState();
}

class _ShoppingDoneScreenState extends State<ShoppingDoneScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
  List<ShopItem> _items = [];

  @override
  void initState() {
    super.initState();
    appOf(context).repo.listShopping(widget.weekId).then((v) {
      if (mounted) setState(() => _items = v);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!(MediaQuery.maybeOf(context)?.disableAnimations ?? false) && !_c.isAnimating) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _back(int tab) {
    appOf(context).setTab(tab);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final app = appOf(context);
    final bought = _items.where((i) => i.checked).toList();
    final byStore = <String, int>{};
    for (final i in bought) {
      final key = i.storeName ?? 'Lainnya';
      byStore[key] = (byStore[key] ?? 0) + (i.price ?? 0);
    }
    final total = byStore.values.fold<int>(0, (a, v) => a + v);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) => CustomPaint(painter: _ConfettiPainter(_c.value)),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Spacer(),
                  const Mascot(size: 170, steam: Steam.check, eyes: Eyes.happy, wave: true, motion: Motion.jump),
                  const SizedBox(height: 8),
                  Text('Belanja beres!', style: fredoka(38, weight: FontWeight.w700, color: BC.daun)),
                  const SizedBox(height: 6),
                  Text(
                    '${bought.length} item sudah masuk keranjang. Kerja bagus, ${app.name}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF3D4A41), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  if (byStore.isNotEmpty)
                    ListCard(children: [
                      for (final e in byStore.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text(rupiah(e.value), style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      Container(
                        color: const Color(0xFFF6FAF7),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Text('Total minggu ini', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const Spacer(),
                            Text(rupiah(total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                      ),
                    ]),
                  const Spacer(),
                  FilledButton(onPressed: () => _back(0), child: const Text('Kembali ke Beranda')),
                  const SizedBox(height: 10),
                  OutlinedButton(onPressed: () => _back(2), child: const Text('Lihat daftar belanja')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;

  static final List<(double, double, double, double)> _pieces = List.generate(22, (i) {
    final r = math.Random(i * 7 + 3);
    return (r.nextDouble(), r.nextDouble(), 0.6 + r.nextDouble() * 0.8, r.nextDouble() * math.pi);
  });
  static const _colors = [BC.kunyit, BC.pandan, BC.cabai, BC.steam, BC.blush];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _pieces.length; i++) {
      final (x, delay, speed, rot) = _pieces[i];
      final p = (t * speed + delay) % 1.0;
      final opacity = p < 0.85 ? 1.0 : (1 - p) / 0.15;
      final paint = Paint()..color = _colors[i % _colors.length].withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x * size.width, p * size.height * 0.7 - 20);
      canvas.rotate(rot + p * 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 10, height: 14), const Radius.circular(3)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
