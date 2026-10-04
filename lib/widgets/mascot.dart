import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

enum Steam { question, check, none, swap }

enum Eyes { open, happy, up }

enum Motion { bob, jump, tilt, still }

/// Si Beres — panci dengan uap "?" yang berubah jadi "✓" saat semuanya beres.
class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    this.size = 120,
    this.steam = Steam.question,
    this.eyes = Eyes.open,
    this.wave = false,
    this.motion = Motion.bob,
    this.body = BC.pandan,
    this.dark = BC.daun,
  });

  final double size;
  final Steam steam;
  final Eyes eyes;
  final bool wave;
  final Motion motion;
  final Color body;
  final Color dark;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.steam == Steam.swap ? 3200 : 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _c.stop();
      _c.value = 0.25;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(
            size: Size.square(widget.size),
            painter: _MascotPainter(_c.value, widget),
          ),
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter(this.t, this.w);
  final double t;
  final Mascot w;

  Paint _stroke(Color c, double width) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint _fill(Color c) => Paint()..color = c;

  @override
  void paint(Canvas canvas, Size size) {
    final ph = t * 2 * math.pi;
    canvas.save();
    canvas.scale(size.width / 120);

    // Gerakan seluruh badan.
    double dy = 0, sx = 1, sy = 1, rot = 0;
    switch (w.motion) {
      case Motion.bob:
        dy = -4 * math.sin(ph);
      case Motion.jump:
        final j = math.sin(ph);
        if (j > 0) {
          dy = -14 * j;
        } else {
          sx = 1 - 0.06 * j;
          sy = 1 + 0.06 * j;
        }
      case Motion.tilt:
        rot = 0.09 * math.sin(ph);
      case Motion.still:
        break;
    }
    canvas.translate(60, 108 + dy);
    canvas.rotate(rot);
    canvas.scale(sx, sy);
    canvas.translate(-60, -108);

    // Uap: "?" atau "✓".
    var steam = w.steam;
    if (steam == Steam.swap) steam = t < 0.5 ? Steam.question : Steam.check;
    final puff = -2 * math.sin(ph * 2);
    if (steam == Steam.question) {
      final q = Path()
        ..moveTo(50, 12 + puff)
        ..cubicTo(50, 2 + puff, 69, 2 + puff, 69, 12 + puff)
        ..cubicTo(69, 19 + puff, 59.5, 19 + puff, 59.5, 26 + puff);
      canvas.drawPath(q, _stroke(BC.steam, 5));
      canvas.drawCircle(Offset(59.5, 33 + puff), 3.2, _fill(BC.steam));
    } else if (steam == Steam.check) {
      final c = Path()
        ..moveTo(46, 20 + puff)
        ..lineTo(56, 30 + puff)
        ..lineTo(74, 10 + puff);
      canvas.drawPath(c, _stroke(w.body == BC.kunyit ? Colors.white : BC.kunyit, 6));
    }

    // Tutup, gagang, badan.
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(53, 38, 14, 8), const Radius.circular(4)), _fill(w.dark));
    canvas.drawOval(Rect.fromCenter(center: const Offset(60, 49), width: 78, height: 14), _fill(w.dark));
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(12, 62, 16, 9), const Radius.circular(4.5)), _fill(w.dark));
    final body = Path()
      ..moveTo(24, 54)
      ..lineTo(96, 54)
      ..lineTo(96, 78)
      ..arcToPoint(const Offset(68, 106), radius: const Radius.circular(28))
      ..lineTo(52, 106)
      ..arcToPoint(const Offset(24, 78), radius: const Radius.circular(28))
      ..close();
    canvas.drawPath(body, _fill(w.body));

    // Tangan melambai atau gagang kanan.
    if (w.wave) {
      final a = t < 0.55 ? 0.3 * math.sin(t / 0.55 * 4 * math.pi) - 0.1 : 0.0;
      canvas.save();
      canvas.translate(94, 72);
      canvas.rotate(a);
      canvas.translate(-94, -72);
      final arm = Path()
        ..moveTo(94, 72)
        ..quadraticBezierTo(108, 70, 110, 54);
      canvas.drawPath(arm, _stroke(w.body, 8));
      canvas.drawCircle(const Offset(110, 52), 6, _fill(w.body));
      canvas.restore();
    } else {
      canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(92, 62, 16, 9), const Radius.circular(4.5)), _fill(w.dark));
    }

    // Mata.
    if (w.eyes == Eyes.happy) {
      final e = Path()
        ..moveTo(41, 71)
        ..quadraticBezierTo(47, 63, 53, 71)
        ..moveTo(67, 71)
        ..quadraticBezierTo(73, 63, 79, 71);
      canvas.drawPath(e, _stroke(Colors.white, 4));
    } else {
      final blink = (t > 0.9 && t < 0.95) ? 0.12 : 1.0;
      final up = w.eyes == Eyes.up;
      canvas.save();
      canvas.translate(0, 70);
      canvas.scale(1, blink);
      canvas.translate(0, -70);
      canvas.drawCircle(const Offset(47, 70), 7, _fill(Colors.white));
      canvas.drawCircle(const Offset(73, 70), 7, _fill(Colors.white));
      canvas.drawCircle(Offset(up ? 49 : 48, up ? 67 : 71), up ? 3.4 : 3.6, _fill(BC.arang));
      canvas.drawCircle(Offset(up ? 75 : 74, up ? 67 : 71), up ? 3.4 : 3.6, _fill(BC.arang));
      if (!up) {
        canvas.drawCircle(const Offset(49.5, 69.5), 1.2, _fill(Colors.white));
        canvas.drawCircle(const Offset(75.5, 69.5), 1.2, _fill(Colors.white));
      }
      canvas.restore();
    }

    // Pipi, mulut, lencana centang.
    canvas.drawCircle(const Offset(38, 82), 4.5, _fill(BC.blush));
    canvas.drawCircle(const Offset(82, 82), 4.5, _fill(BC.blush));
    if (w.eyes == Eyes.up) {
      canvas.drawCircle(const Offset(60, 84), 3.5, _fill(Colors.white));
    } else {
      final m = Path()
        ..moveTo(53, 82)
        ..quadraticBezierTo(60, 89, 67, 82);
      canvas.drawPath(m, _stroke(Colors.white, 3.5));
    }
    canvas.drawCircle(const Offset(60, 96), 7.5, _fill(w.body == BC.kunyit ? Colors.white : BC.kunyit));
    final badge = Path()
      ..moveTo(56.5, 96)
      ..lineTo(59.1, 98.6)
      ..lineTo(63.7, 93.4);
    canvas.drawPath(badge, _stroke(w.dark, 2.4));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) => old.t != t || old.w != w;
}
