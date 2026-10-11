import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/mascot.dart';
import 'shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final AppState _app;
  late final TextEditingController _name;
  late final Set<int> _days;
  static const _calls = ['Bunda', 'Mama', 'Sayang', 'Nyonya'];

  @override
  void initState() {
    super.initState();
    _app = context.read<AppState>();
    _name = TextEditingController(text: _app.name);
    _days = {..._app.defaultDays};
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final name = _name.text.trim().isEmpty ? 'Sayang' : _name.text.trim();
    await _app.saveProfile(newName: name, days: _days.toList(), done: true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BR.pillR,
                        border: Border.all(color: BC.line),
                      ),
                      child: const Text('Halo! Aku Si Beres',
                          style: TextStyle(fontWeight: FontWeight.w600, color: BC.daun)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(child: Mascot(size: 150, wave: true)),
                  const SizedBox(height: 8),
                  Text('Kenalan dulu, yuk', textAlign: TextAlign.center, style: fredoka(30)),
                  const SizedBox(height: 6),
                  const Text(
                    'Aku bantu atur menu mingguan, daftar belanja, dan checklist dapur biar semua beres.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF3D4A41), fontWeight: FontWeight.w500, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text('Mau dipanggil apa?',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: BC.muted)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in _calls)
                        ChoiceChip(
                          label: Text(c),
                          selected: _name.text.trim() == c,
                          onSelected: (_) => setState(() => _name.text = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Biasanya masak hari apa?',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: BC.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (var d = 1; d <= 7; d++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _DayToggle(
                              label: dayShort[d - 1],
                              on: _days.contains(d),
                              onTap: () => setState(() => _days.contains(d) ? _days.remove(d) : _days.add(d)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(onPressed: _start, child: const Text('Mulai beresin dapur')),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: on,
      child: Material(
        color: on ? BC.greenSoft : Colors.white,
        borderRadius: BR.pillR,
        child: InkWell(
          borderRadius: BR.pillR,
          onTap: onTap,
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BR.pillR,
              border: Border.all(color: on ? BC.pandan : BC.line),
            ),
            child: Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? BC.daun : BC.muted)),
          ),
        ),
      ),
    );
  }
}
