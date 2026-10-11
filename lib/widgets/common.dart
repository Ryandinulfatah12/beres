import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'mascot.dart';

/// Memuat data lewat [load] dan memuat ulang setiap kali AppState.changed()
/// dipanggil. Data lama tetap tampil selama data baru dimuat (tanpa kedip).
class DataBuilder<T> extends StatefulWidget {
  const DataBuilder({super.key, required this.load, required this.builder});
  final Future<T> Function(AppState app) load;
  final Widget Function(BuildContext context, T data) builder;

  @override
  State<DataBuilder<T>> createState() => _DataBuilderState<T>();
}

class _DataBuilderState<T> extends State<DataBuilder<T>> {
  int? _ver;
  T? _data;
  bool _hasData = false;
  Object? _error;

  void _fetch(AppState app) {
    final v = app.version;
    _ver = v;
    widget.load(app).then<void>((d) {
      if (!mounted || _ver != v) return;
      setState(() {
        _data = d;
        _hasData = true;
        _error = null;
      });
    }, onError: (Object e) {
      if (mounted) setState(() => _error = e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (_ver != app.version) _fetch(app);
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Data gagal dimuat: $_error', textAlign: TextAlign.center),
        ),
      );
    }
    if (!_hasData) return const Center(child: CircularProgressIndicator());
    return widget.builder(context, _data as T);
  }
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 26, this.color = BC.daun, this.mark = BC.cabai});
  final double size;
  final Color color;
  final Color mark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Beres?',
      child: ExcludeSemantics(
        child: Text.rich(TextSpan(
          text: 'Beres',
          style: fredoka(size, weight: FontWeight.w700, color: color),
          children: [TextSpan(text: '?', style: fredoka(size, weight: FontWeight.w700, color: mark))],
        )),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.eyebrow, required this.title, this.trailing});
  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eyebrow,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: BC.muted)),
                const SizedBox(height: 4),
                Text(title, style: fredoka(26)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SquareIconButton extends StatelessWidget {
  const SquareIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: BC.arang,
        fixedSize: const Size(44, 44),
        side: const BorderSide(color: BC.line),
        shape: BR.pillShape,
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: BC.muted)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

enum TagKind { lauk, cemilan, eceran, grosir, toko }

class Tag extends StatelessWidget {
  const Tag(this.text, this.kind, {super.key});
  final String text;
  final TagKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      TagKind.lauk || TagKind.eceran => (BC.greenSoft, BC.greenText),
      TagKind.cemilan || TagKind.grosir => (BC.orangeSoft, BC.orangeText),
      TagKind.toko => (BC.pill, BC.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BR.pillR),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

/// Kartu putih dengan garis tipis.
class BoxCard extends StatelessWidget {
  const BoxCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = Colors.white,
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = BR.cardR;
    return Material(
      color: color,
      borderRadius: r,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(borderRadius: r, border: Border.all(color: BC.line)),
          child: child,
        ),
      ),
    );
  }
}

/// Daftar baris di dalam satu kartu, dipisah garis tipis.
class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BR.cardR,
        border: Border.all(color: BC.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: BC.lineSoft),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Pilihan segmented (Lauk/Cemilan, Semua/Eceran/Grosir).
class Pills extends StatelessWidget {
  const Pills({super.key, required this.labels, required this.index, required this.onChanged});
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: BC.pill, borderRadius: BR.pillR),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                selected: i == index,
                button: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BR.pillR,
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == index ? Colors.white : Colors.transparent,
                        borderRadius: BR.pillR,
                        boxShadow: i == index
                            ? const [BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1))]
                            : null,
                      ),
                      child: Text(labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: i == index ? BC.arang : BC.muted,
                          )),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message, this.actionLabel, this.onAction});
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(size: 130, eyes: Eyes.up, motion: Motion.tilt),
            const SizedBox(height: 16),
            Text(title, style: fredoka(22), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: BC.muted, fontWeight: FontWeight.w500, height: 1.4)),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ikon di dalam kotak membulat berwarna lembut — dipakai sebagai "aset" ikon
/// di seluruh aplikasi supaya ikonografinya seragam dan lebih berkarakter
/// daripada ikon telanjang.
class SoftIcon extends StatelessWidget {
  const SoftIcon(
    this.icon, {
    super.key,
    this.bg = BC.greenSoft,
    this.fg = BC.greenText,
    this.size = 40,
    this.radius = BR.pill,
  });

  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius)),
      child: Icon(icon, size: size * 0.52, color: fg),
    );
  }
}

/// Maskot di dalam lingkaran lembut — dipakai sebagai avatar di sapaan Beranda.
class MascotAvatar extends StatelessWidget {
  const MascotAvatar({super.key, this.size = 46});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: BC.mint, shape: BoxShape.circle),
      child: Mascot(size: size * 0.78, steam: Steam.none, eyes: Eyes.happy, motion: Motion.still),
    );
  }
}

/// Kartu statistik ringkas: label kecil, angka besar, keterangan, dan garis
/// warna di bawahnya. Tiga buah berjajar muat di layar paling sempit.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.accent,
    this.progress,
    this.onTap,
  });

  final String label;
  final String value;
  final String sub;
  final Color accent;

  /// 0..1. Bila null kartunya memang tidak punya "sekian dari sekian", jadi
  /// yang digambar hanya setrip aksen pendek — bukan bar penuh yang terbaca
  /// seolah-olah sudah 100%.
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = BR.cardR;
    return Material(
      color: Colors.white,
      borderRadius: r,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(11, 11, 11, 12),
          decoration: BoxDecoration(borderRadius: r, border: Border.all(color: BC.line)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: BC.muted)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, maxLines: 1, style: fredoka(19, weight: FontWeight.w600, color: BC.ink)),
              ),
              const SizedBox(height: 2),
              Text(sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: BC.muted, fontWeight: FontWeight.w500)),
              const SizedBox(height: 9),
              if (progress == null)
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 5,
                      decoration: BoxDecoration(color: accent, borderRadius: BR.pillR),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(color: BC.lineSoft, borderRadius: BR.pillR),
                      ),
                    ),
                  ],
                )
              else
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress!.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BR.pillR,
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 5,
                      color: accent,
                      backgroundColor: BC.lineSoft,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol teks berbentuk pil dengan ikon — aksi cepat yang ringan secara visual.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Hijau pekat untuk aksi utama, putih bergaris untuk aksi pendukung.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : BC.ink;
    return Material(
      color: filled ? BC.pandan : Colors.white,
      borderRadius: BR.pillR,
      child: InkWell(
        borderRadius: BR.pillR,
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BR.pillR,
            border: Border.all(color: filled ? BC.pandan : BC.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 7),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animasi masuk sekali (fade + geser naik). Menghormati "kurangi gerakan".
class FadeIn extends StatefulWidget {
  const FadeIn({super.key, required this.child, this.delay = 0});
  final Widget child;
  final int delay;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _c.value = 1;
    } else {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(_a),
        child: widget.child,
      ),
    );
  }
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<bool> confirm(BuildContext context,
    {required String title, required String message, String ok = 'Ya'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: fredoka(20)),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(ok)),
      ],
    ),
  );
  return r ?? false;
}

/// AppState tanpa listen — aman dipanggil di dalam build maupun callback.
AppState appOf(BuildContext context) => Provider.of<AppState>(context, listen: false);
