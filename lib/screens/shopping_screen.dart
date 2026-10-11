import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../utils/share_text.dart';
import '../widgets/common.dart';
import '../widgets/refresh.dart';
import 'shopping_mode_screen.dart';

class _ShopData {
  _ShopData(this.weekId, this.start, this.items, this.stores);
  final int weekId;
  final DateTime start;
  final List<ShopItem> items;
  final List<Store> stores;
}

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  int _filter = 0; // 0 semua, 1 eceran, 2 grosir
  final _add = TextEditingController();
  final Set<int> _hidden = {};

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  Future<void> _generate(int weekId) async {
    final app = appOf(context);
    final n = await app.repo.generateShopping(weekId);
    app.changed();
    if (!mounted) return;
    showSnack(context,
        n > 0 ? '$n bahan sudah dijumlahkan.' : 'Menu minggu ini belum punya bahan. Lengkapi di halaman Menu.');
  }

  Future<void> _addManual(_ShopData d) async {
    final name = _add.text.trim();
    if (name.isEmpty) return;
    final app = appOf(context);
    final store = await app.repo.defaultStore();
    await app.repo.addManual(d.weekId, name,
        storeId: store, buyMode: _filter == 2 ? 'grosir' : 'eceran');
    _add.clear();
    app.changed();
  }

  Future<void> _delete(ShopItem item) async {
    setState(() => _hidden.add(item.id));
    final app = appOf(context);
    await app.repo.deleteShopItem(item.id);
    app.changed();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DataBuilder<_ShopData>(
        load: (app) async {
          final id = await app.weekId();
          final w = await app.repo.getWeek(id);
          return _ShopData(id, w.start, await app.repo.listShopping(id), await app.repo.listStores());
        },
        builder: (context, d) => _body(context, d),
      ),
    );
  }

  /// Mengelompokkan item per toko, supaya nama toko disebut sekali sebagai
  /// judul grup dan tidak diulang sebagai chip di setiap baris — di daftar 28
  /// item, chip "Super Indo" yang sama muncul 28 kali tanpa memberi informasi.
  List<Widget> _byStore(List<ShopItem> list, _ShopData d) {
    if (list.isEmpty) return const [];
    final groups = <String, List<ShopItem>>{};
    for (final i in list) {
      groups.putIfAbsent(i.storeName ?? 'Belum ada toko', () => []).add(i);
    }
    final out = <Widget>[];
    for (final g in groups.entries) {
      if (out.isNotEmpty) out.add(const SizedBox(height: 10));
      out.add(_StoreHeader(name: g.key, count: g.value.length));
      out.add(ListCard(children: [
        for (final i in g.value) _ShopRow(item: i, stores: d.stores, onDelete: () => _delete(i)),
      ]));
    }
    return out;
  }

  Widget _body(BuildContext context, _ShopData d) {
    final items = d.items.where((i) => !_hidden.contains(i.id)).toList();
    final header = ScreenHeader(
      eyebrow: 'Belanja, ${weekRange(d.start)}',
      title: 'Daftar belanja',
      trailing: items.isEmpty
          ? null
          : SquareIconButton(
              icon: Icons.ios_share_rounded,
              tooltip: 'Bagikan daftar belanja',
              onPressed: () => Share.share(shoppingShareText(d.start, items)),
            ),
    );
    if (items.isEmpty) {
      return Column(
        children: [
          header,
          Expanded(
            child: EmptyState(
              title: 'Belum ada daftar belanja',
              message: 'Susun menu minggu ini dulu, nanti bahannya kujumlahkan otomatis.',
              actionLabel: 'Generate dari menu',
              onAction: () => _generate(d.weekId),
            ),
          ),
        ],
      );
    }

    bool match(ShopItem i) => _filter == 0 || (_filter == 2 ? i.grosir : !i.grosir);
    final fromMenu = items.where((i) => !i.manual && match(i)).toList();
    final manual = items.where((i) => i.manual && match(i)).toList();
    final grosirCount = items.where((i) => i.grosir).length;

    return Column(
      children: [
        header,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Pills(
            labels: ['Semua ${items.length}', 'Eceran ${items.length - grosirCount}', 'Grosir $grosirCount'],
            index: _filter,
            onChanged: (i) => setState(() => _filter = i),
          ),
        ),
        Expanded(
          child: BeresRefresh(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            children: [
              SectionLabel(
                'Dari menu (${fromMenu.length})',
                trailing: TextButton(onPressed: () => _generate(d.weekId), child: const Text('Generate ulang')),
              ),
              if (fromMenu.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: Text('Tidak ada bahan di pilihan ini.', style: TextStyle(color: BC.muted)),
                )
              else
                ..._byStore(fromMenu, d),
              const SizedBox(height: 18),
              SectionLabel('Tambahan (${manual.length})'),
              ..._byStore(manual, d),
              if (manual.isNotEmpty) const SizedBox(height: 10),
              ListCard(children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _add,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _addManual(d),
                          decoration: const InputDecoration(
                            hintText: 'Tambah item, mis. tisu muka',
                            isDense: true,
                            fillColor: Color(0xFFF9FAF8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SquareIconButton(icon: Icons.add_rounded, tooltip: 'Tambah item', onPressed: () => _addManual(d)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              const Text('Ketuk item untuk pindah toko · geser ke kiri untuk menghapus.',
                  textAlign: TextAlign.center, style: mutedText),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: FilledButton.icon(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ShoppingModeScreen(weekId: d.weekId))),
            icon: const Icon(Icons.checklist_rounded),
            label: Text('Mulai belanja, ${items.length} item'),
          ),
        ),
      ],
    );
  }
}

/// Judul grup toko di daftar belanja.
class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.name, required this.count});
  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
      child: Row(
        children: [
          const Icon(Icons.storefront_rounded, size: 15, color: BC.pandan),
          const SizedBox(width: 6),
          Flexible(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: BC.greenText)),
          ),
          const SizedBox(width: 6),
          Text('$count item', style: mutedText),
        ],
      ),
    );
  }
}

class _ShopRow extends StatelessWidget {
  const _ShopRow({required this.item, required this.stores, required this.onDelete});
  final ShopItem item;
  final List<Store> stores;
  final VoidCallback onDelete;

  double get _step => (item.unit == 'gr' || item.unit == 'ml') ? 50 : 1;

  Future<void> _changeQty(BuildContext context, double delta) async {
    final app = appOf(context);
    final current = item.qty ?? 0;
    final next = (current + delta).clamp(0, 99999).toDouble();
    await app.repo.updateShopQty(item.id, next == 0 ? null : next, item.unit);
    app.changed();
  }

  Future<void> _editQty(BuildContext context) async {
    final qty = TextEditingController(text: item.qty == null ? '' : qtyText(item.qty, ''));
    final unit = TextEditingController(text: item.unit);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(item.name, style: fredoka(20)),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: qty,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Jumlah'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: unit, decoration: const InputDecoration(labelText: 'Satuan'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final app = appOf(context);
      await app.repo.updateShopQty(item.id, parseQty(qty.text), unit.text);
      app.changed();
    }
    qty.dispose();
    unit.dispose();
  }

  Future<void> _toggleBuyMode(BuildContext context) async {
    final app = appOf(context);
    await app.repo.setShopBuyMode(item, item.grosir ? 'eceran' : 'grosir');
    app.changed();
  }

  Future<void> _pickStore(BuildContext context) async {
    final app = appOf(context);
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Beli ${item.name} di mana?', style: fredoka(20)),
            ),
            for (final s in stores)
              ListTile(
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                selected: s.id == item.storeId,
                onTap: () => Navigator.pop(c, s.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await app.repo.setShopStore(item.id, picked);
    app.changed();
  }

  @override
  Widget build(BuildContext context) {
    final sub = item.manual ? 'tambahan' : (item.sources ?? '').replaceAll(',', ', ');
    return Dismissible(
      key: ValueKey('shop-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFFFBE3DA),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: BC.cabai),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _pickStore(context),
                borderRadius: BR.innerR,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: item.checked ? BC.muted : BC.arang,
                              decoration: item.checked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (item.checked) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle_rounded, size: 16, color: BC.pandan),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        InkWell(
                          borderRadius: BR.pillR,
                          onTap: () => _toggleBuyMode(context),
                          child: Tag(item.grosir ? 'Grosir' : 'Eceran',
                              item.grosir ? TagKind.grosir : TagKind.eceran),
                        ),
                        if (sub.isNotEmpty) ...[
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: mutedText),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: BC.santan, borderRadius: BR.pillR),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Kurangi',
                    iconSize: 18,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 44),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.remove_rounded),
                    onPressed: () => _changeQty(context, -_step),
                  ),
                  InkWell(
                    onTap: () => _editQty(context),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 56, minHeight: 44),
                      child: Center(
                        child: Text(
                          item.qty == null && item.unit.isEmpty ? 'atur' : qtyText(item.qty, item.unit),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tambah',
                    iconSize: 18,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 44),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () => _changeQty(context, _step),
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
