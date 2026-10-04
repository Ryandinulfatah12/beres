import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

class _IngRow {
  _IngRow({String name = '', String qty = '', String unit = ''})
      : name = TextEditingController(text: name),
        qty = TextEditingController(text: qty),
        unit = TextEditingController(text: unit);
  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController unit;

  void dispose() {
    name.dispose();
    qty.dispose();
    unit.dispose();
  }
}

class DishDetailScreen extends StatefulWidget {
  const DishDetailScreen({super.key, this.dishId, this.category = 'lauk'});
  final int? dishId;
  final String category;

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  final _name = TextEditingController();
  final _note = TextEditingController();
  final List<_IngRow> _rows = [];
  late String _category = widget.category;
  bool _loading = true;

  bool get _isNew => widget.dishId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isNew) {
      _rows.add(_IngRow());
      setState(() => _loading = false);
      return;
    }
    final repo = appOf(context).repo;
    final dish = await repo.getDish(widget.dishId!);
    final ings = await repo.dishIngredients(widget.dishId!);
    if (!mounted || dish == null) return;
    setState(() {
      _name.text = dish.name;
      _note.text = dish.note ?? '';
      _category = dish.category;
      for (final i in ings) {
        _rows.add(_IngRow(name: i.name, qty: i.qty == null ? '' : qtyText(i.qty, ''), unit: i.unit));
      }
      if (_rows.isEmpty) _rows.add(_IngRow());
      _loading = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showSnack(context, 'Nama menu belum diisi.');
      return;
    }
    final app = appOf(context);
    await app.repo.saveDish(
      id: widget.dishId,
      name: name,
      category: _category,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      ingredients: [
        for (final r in _rows)
          if (r.name.text.trim().isNotEmpty)
            DishIngredient(name: r.name.text, qty: parseQty(r.qty.text), unit: r.unit.text),
      ],
    );
    app.changed();
    if (!mounted) return;
    showSnack(context, 'Menu "$name" tersimpan.');
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await confirm(context,
        title: 'Hapus menu ini?',
        message: 'Menu juga akan dihapus dari rencana mingguan yang memakainya.',
        ok: 'Hapus');
    if (!ok || !mounted) return;
    final app = appOf(context);
    await app.repo.deleteDish(widget.dishId!);
    app.changed();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Menu baru' : 'Detail menu'),
        actions: [
          if (!_isNew)
            IconButton(tooltip: 'Hapus menu', onPressed: _delete, icon: const Icon(Icons.delete_outline_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Pills(
                        labels: const ['Lauk', 'Cemilan'],
                        index: _category == 'lauk' ? 0 : 1,
                        onChanged: (i) => setState(() => _category = i == 0 ? 'lauk' : 'cemilan'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Mascot(size: 56, steam: Steam.question, eyes: Eyes.open),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  style: fredoka(22),
                  decoration: const InputDecoration(hintText: 'Nama menu, mis. Opor ayam'),
                ),
                const SizedBox(height: 18),
                SectionLabel('Bahan (${_rows.where((r) => r.name.text.trim().isNotEmpty).length})'),
                ListCard(children: [
                  for (var i = 0; i < _rows.length; i++)
                    Padding(
                      key: ObjectKey(_rows[i]),
                      padding: const EdgeInsets.fromLTRB(10, 8, 2, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _rows[i].name,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(isDense: true, hintText: 'Bahan'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 64,
                            child: TextField(
                              controller: _rows[i].qty,
                              textAlign: TextAlign.right,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(isDense: true, hintText: 'Jml'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 74,
                            child: TextField(
                              controller: _rows[i].unit,
                              decoration: const InputDecoration(isDense: true, hintText: 'gr/buah'),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hapus bahan',
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF8A968D)),
                            onPressed: () {
                              final removed = _rows.removeAt(i);
                              setState(() {});
                              WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
                            },
                          ),
                        ],
                      ),
                    ),
                  InkWell(
                    onTap: () => setState(() => _rows.add(_IngRow())),
                    child: const SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: BC.pandan),
                          SizedBox(width: 6),
                          Text('Tambah bahan', style: TextStyle(fontWeight: FontWeight.w700, color: BC.pandan)),
                        ],
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Pakai satuan yang sama untuk bahan yang sama (mis. bawang selalu "siung") supaya daftar belanja bisa dijumlahkan.',
                    style: mutedText,
                  ),
                ),
                const SizedBox(height: 18),
                const SectionLabel('Catatan'),
                TextField(
                  controller: _note,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Mis. anak suka kuahnya banyak'),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(onPressed: _loading ? null : _save, child: const Text('Simpan menu')),
        ),
      ),
    );
  }
}
