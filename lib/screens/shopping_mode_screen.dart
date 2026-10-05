import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'shopping_done_screen.dart';

/// Layar fokus saat di toko: centang item dan catat harga.
class ShoppingModeScreen extends StatefulWidget {
  const ShoppingModeScreen({super.key, required this.weekId});
  final int weekId;

  @override
  State<ShoppingModeScreen> createState() => _ShoppingModeScreenState();
}

class _ShoppingModeScreenState extends State<ShoppingModeScreen> {
  late final AppState _app;
  List<ShopItem> _items = [];
  bool _loading = true;
  int? _store; // null = semua toko
  final Map<int, TextEditingController> _ctrl = {};
  final Map<int, bool> _checked = {};
  final Map<int, int?> _price = {};

  @override
  void initState() {
    super.initState();
    _app = appOf(context);
    _load();
  }

  Future<void> _load() async {
    final items = await _app.repo.listShopping(widget.weekId);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
      for (final i in items) {
        _checked[i.id] = i.checked;
        _price[i.id] = i.price;
        _ctrl[i.id] = TextEditingController(text: i.price?.toString() ?? '');
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    Future.microtask(_app.changed);
    super.dispose();
  }

  void _toggle(ShopItem i) {
    final v = !(_checked[i.id] ?? false);
    setState(() => _checked[i.id] = v);
    HapticFeedback.lightImpact();
    _app.repo.setShopChecked(i.id, v);
  }

  void _setPrice(ShopItem i, String text) {
    final p = int.tryParse(text);
    setState(() => _price[i.id] = p);
    _app.repo.setShopPrice(i, p);
  }

  Future<void> _finish() async {
    final left = _items.where((i) => !(_checked[i.id] ?? false)).length;
    if (left > 0) {
      final ok = await confirm(context,
          title: 'Masih ada $left item',
          message: 'Belum semua item dicentang. Selesaikan belanja sekarang?',
          ok: 'Selesai');
      if (!ok) return;
    }
    await _app.repo.finishWeek(widget.weekId);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ShoppingDoneScreen(weekId: widget.weekId)));
  }

  @override
  Widget build(BuildContext context) {
    final done = _items.where((i) => _checked[i.id] ?? false).length;
    final total = _items.fold<int>(0, (a, i) => a + ((_checked[i.id] ?? false) ? (_price[i.id] ?? 0) : 0));
    final progress = _items.isEmpty ? 0.0 : done / _items.length;

    final stores = <int, String>{};
    for (final i in _items) {
      if (i.storeId != null) stores[i.storeId!] = i.storeName ?? '';
    }
    final visible = _items.where((i) => _store == null || i.storeId == _store).toList()
      ..sort((a, b) {
        final ca = (_checked[a.id] ?? false) ? 1 : 0;
        final cb = (_checked[b.id] ?? false) ? 1 : 0;
        return ca - cb;
      });

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: BC.daun,
            padding: EdgeInsets.fromLTRB(8, MediaQuery.paddingOf(context).top + 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Kembali',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mode belanja',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFCFE3D6))),
                        Text(_store == null ? 'Semua toko' : stores[_store] ?? '',
                            style: fredoka(20, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 0, 0),
                  child: Text('$done dari ${_items.length} item diambil',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE7F1EA))),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 26, 0, 0),
                  child: _RiderBar(value: progress),
                ),
              ],
            ),
          ),
          if (stores.length > 1)
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                        label: const Text('Semua'), selected: _store == null, onSelected: (_) => setState(() => _store = null)),
                  ),
                  for (final e in stores.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: _store == e.key,
                        onSelected: (_) => setState(() => _store = e.key),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    children: [for (final i in visible) _tile(i)],
                  ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: BC.line)),
            ),
            padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.paddingOf(context).bottom),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total belanja',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BC.muted)),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: total.toDouble()),
                      duration: const Duration(milliseconds: 400),
                      builder: (_, v, __) => Text(rupiah(v.round()), style: fredoka(24, weight: FontWeight.w700)),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _finish,
                  style: FilledButton.styleFrom(minimumSize: const Size(128, 52)),
                  child: const Text('Selesai'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(ShopItem i) {
    final done = _checked[i.id] ?? false;
    final meta = [qtyText(i.qty, i.unit), if (i.storeName != null) i.storeName!].where((s) => s.isNotEmpty).join(', ');
    return AnimatedContainer(
      key: ValueKey(i.id),
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: done ? BC.lineSoft : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: done ? BC.lineSoft : BC.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _toggle(i),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(value: done, onChanged: (_) => _toggle(i)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: done ? BC.muted : BC.arang,
                                decoration: done ? TextDecoration.lineThrough : null,
                              )),
                          if (meta.isNotEmpty) Text(meta, style: mutedText),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 116,
              child: TextField(
                controller: _ctrl[i.id],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  isDense: true,
                  prefixText: 'Rp ',
                  hintText: 'Harga',
                  fillColor: done ? Colors.white : const Color(0xFFF9FAF8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                onChanged: (v) => _setPrice(i, v),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress bar dengan troli kecil yang ikut bergerak.
class _RiderBar extends StatelessWidget {
  const _RiderBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (_, v, __) => LayoutBuilder(
        builder: (_, c) {
          final x = (c.maxWidth * v.clamp(0.0, 1.0)) - 13;
          return SizedBox(
            height: 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: c.maxWidth * v.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                Positioned(
                  left: x.clamp(-13.0, c.maxWidth - 13),
                  top: -28,
                  child: const Icon(Icons.shopping_cart_rounded, color: BC.kunyit, size: 26),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
