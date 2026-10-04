import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import 'onboarding_screen.dart';
import 'shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checked = false;
  Timer? _go;
  Timer? _flip;

  @override
  void initState() {
    super.initState();
    _flip = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (mounted) setState(() => _checked = !_checked);
    });
    _go = Timer(const Duration(milliseconds: 2600), _next);
  }

  void _next() {
    if (!mounted) return;
    final app = context.read<AppState>();
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => app.onboarded ? const Shell() : const OnboardingScreen(),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    ));
  }

  @override
  void dispose() {
    _go?.cancel();
    _flip?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BC.pandan,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: const Mascot(
                size: 170,
                steam: Steam.swap,
                wave: true,
                body: BC.kunyit,
                dark: BC.kunyitDark,
              ),
            ),
            const SizedBox(height: 18),
            Semantics(
              label: 'Beres?',
              child: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Beres', style: fredoka(64, weight: FontWeight.w700, color: Colors.white)),
                    SizedBox(
                      width: 44,
                      height: 76,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: _checked
                            ? const Icon(Icons.check_rounded, key: ValueKey('c'), size: 54, color: BC.kunyit)
                            : Text('?',
                                key: const ValueKey('q'),
                                style: fredoka(64, weight: FontWeight.w700, color: BC.kunyit)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dari menu sampai belanja, semua beres.',
              style: TextStyle(color: Color(0xFFD7E8DC), fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
