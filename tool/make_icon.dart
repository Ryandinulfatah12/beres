// Me-render ikon aplikasi dari maskot Si Beres, supaya ikonnya memakai gambar
// yang sama persis dengan yang dipakai di dalam aplikasi — bukan aset tempelan.
//
//   flutter test tool/make_icon.dart
//   dart run flutter_launcher_icons
//
// Menghasilkan dua berkas di assets/icon/:
//   beres_icon.png     latar penuh, dipakai untuk ikon biasa dan iOS
//   beres_icon_fg.png  latar transparan dengan pot lebih kecil, untuk lapisan
//                      depan adaptive icon Android (zona amannya cuma 66%)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:beres/theme.dart';
import 'package:beres/widgets/mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 1024.0;

Future<void> _render(WidgetTester tester, String path, Widget child) async {
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(const Size(_size, _size));
  await tester.pumpWidget(
    MediaQuery(
      // Mematikan animasi maskot supaya pumpAndSettle tidak menunggu selamanya,
      // sekaligus mengunci posenya ke keadaan diam.
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: SizedBox(width: _size, height: _size, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(data!.buffer.asUint8List());
    stdout.writeln('ditulis: $path');
  });
}

/// Si Beres versi ikon: panci kuning, mata senang, uap centang, dan diam.
Widget _mascot(double size) => Center(
      child: Mascot(
        size: size,
        steam: Steam.check,
        eyes: Eyes.happy,
        motion: Motion.still,
        body: BC.kunyit,
        dark: BC.kunyitDark,
      ),
    );

void main() {
  testWidgets('ikon utama', (tester) async {
    await _render(
      tester,
      'assets/icon/beres_icon.png',
      ColoredBox(color: BC.daun, child: _mascot(_size * 0.76)),
    );
  });

  testWidgets('lapisan depan adaptive icon', (tester) async {
    await _render(
      tester,
      'assets/icon/beres_icon_fg.png',
      // Hampir sepenuh kanvas: flutter_launcher_icons masih menambahkan inset
      // 16% sendiri, dan setelah itu maskotnya baru pas mengisi zona aman
      // adaptive icon (66% dari kanvas 108dp).
      _mascot(_size * 0.98),
    );
  });
}
