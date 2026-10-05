import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../theme.dart';
import 'common.dart';
import 'mascot.dart';

/// Jarak tarikan sampai refresh terpicu.
const _trigger = 120.0;

/// Tinggi area indikator saat sedang menyegarkan.
const _extent = 92.0;

/// Daftar yang bisa ditarik ke bawah untuk menyegarkan data, dengan Si Beres
/// sebagai indikatornya: pancinya mengintip naik sambil dimiringkan mengikuti
/// tarikan, uapnya berubah "?" → "✓" saat sudah cukup jauh, lalu berubah jadi
/// tanda putar dan pancinya melompat-lompat selagi data dimuat ulang.
///
/// Dipakai menggantikan ListView: cukup ganti nama widget-nya, `padding` dan
/// `children` tetap sama.
class BeresRefresh extends StatelessWidget {
  const BeresRefresh({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
    this.onRefresh,
  });

  final List<Widget> children;
  final EdgeInsets padding;

  /// Default-nya memuat ulang seluruh data lewat AppState.
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // BouncingScrollPhysics supaya tarikannya terasa di Android juga,
      // AlwaysScrollable supaya tetap bisa ditarik walau isinya sedikit.
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: _trigger,
          refreshIndicatorExtent: _extent,
          onRefresh: onRefresh ?? () => refreshAppData(context),
          builder: _indicator,
        ),
        SliverPadding(
          padding: padding,
          sliver: SliverList(delegate: SliverChildListDelegate(children)),
        ),
      ],
    );
  }
}

/// Memuat ulang semua DataBuilder yang sedang tampil. Jedanya disengaja supaya
/// animasinya sempat terbaca — database lokal hampir selalu selesai seketika.
Future<void> refreshAppData(BuildContext context) async {
  appOf(context).changed();
  await Future<void>.delayed(const Duration(milliseconds: 700));
}

Widget _indicator(
  BuildContext context,
  RefreshIndicatorMode mode,
  double pulled,
  double triggerExtent,
  double indicatorExtent,
) {
  final p = (pulled / triggerExtent).clamp(0.0, 1.0);
  final sibuk = mode == RefreshIndicatorMode.refresh;
  // Cukup jauh ditarik: pancinya berubah kuning sebagai tanda siap dilepas.
  final siap = p >= 1.0 || sibuk || mode == RefreshIndicatorMode.armed;

  final (String label, Steam steam, Eyes eyes, Motion motion) = switch (mode) {
    RefreshIndicatorMode.refresh => ('Sebentar, lagi diaduk…', Steam.swap, Eyes.happy, Motion.bob),
    RefreshIndicatorMode.armed => ('Lepas, biar diaduk!', Steam.check, Eyes.happy, Motion.jump),
    RefreshIndicatorMode.done => ('Beres!', Steam.check, Eyes.happy, Motion.still),
    _ => siap
        ? ('Lepas, biar diaduk!', Steam.check, Eyes.happy, Motion.still)
        : ('Tarik lagi ya…', Steam.question, Eyes.up, Motion.still),
  };

  // Saat ditarik pancinya miring sedikit, makin jauh makin tegak lagi.
  final miring = sibuk ? 0.0 : math.sin(p * math.pi) * 0.14;

  return ClipRect(
    child: Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: Opacity(
        opacity: p == 0 ? 0 : (p * 1.6).clamp(0.0, 1.0),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: miring,
                child: Mascot(
                  size: 38 + 24 * p,
                  steam: steam,
                  eyes: eyes,
                  motion: motion,
                  wave: siap,
                  body: siap ? BC.kunyit : BC.pandan,
                  dark: siap ? BC.kunyitDark : BC.daun,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: siap || sibuk ? BC.daun : BC.muted,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
