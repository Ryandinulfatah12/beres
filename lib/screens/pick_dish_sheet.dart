import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

Future<void> showPickDishSheet(BuildContext context, {required int dayId, required String dayLabel}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(BR.card))),
    builder: (_) => _PickDishSheet(dayId: dayId, dayLabel: dayLabel),
  );
}

class _PickDishSheet extends StatefulWidget {
  const _PickDishSheet({required this.dayId, required this.dayLabel});
  final int dayId;
  final String dayLabel;

  @override
  State<_PickDishSheet> createState() => _PickDishSheetState();
}

class _PickDishSheetState extends State<_PickDishSheet> {
  static const _cats = ['lauk', 'cemilan'];
  int _cat = 0;
  String _query = '';
  final Set<int> _selected = {};
  Map<String, List<Dish>> _dishes = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appOf(context).repo;
    final lauk = await repo.listDishes('lauk');
    final cemilan = await repo.listDishes('cemilan');
    if (!mounted) return;
    setState(() {
      _dishes = {'lauk': lauk, 'cemilan': cemilan};
      _loading = false;
    });
  }

  Future<void> _createQuick() async {
    final app = appOf(context);
    final id = await app.repo.saveDish(name: _query, category: _cats[_cat], ingredients: []);
    _selected.add(id);
    await _load();
  }

  Future<void> _submit() async {
    final app = appOf(context);
    await app.repo.addDishes(widget.dayId, _selected.toList());
    app.changed();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final all = _dishes[_cats[_cat]] ?? [];
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty ? all : all.where((d) => d.name.toLowerCase().contains(q)).toList();
    final exact = all.any((d) => d.name.toLowerCase() == q);
    final firstDay = widget.dayLabel.split(',').first;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  const Mascot(size: 48, eyes: Eyes.up, motion: Motion.tilt),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$firstDay mau masak apa?', style: fredoka(22)),
                        Text(widget.dayLabel,
                            style: const TextStyle(fontSize: 13, color: BC.muted, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Pills(labels: const ['Lauk', 'Cemilan'], index: _cat, onChanged: (i) => setState(() => _cat = i)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Cari atau ketik menu baru',
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        if (q.isNotEmpty && !exact)
                          ListTile(
                            shape: BR.innerShape,
                            leading: const Icon(Icons.add_circle_outline_rounded, color: BC.pandan),
                            title: Text('Buat menu baru "${_query.trim()}"',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: BC.pandan)),
                            subtitle: const Text('Bahannya bisa dilengkapi nanti di halaman Menu'),
                            onTap: _createQuick,
                          ),
                        for (final d in list)
                          CheckboxListTile(
                            value: _selected.contains(d.id),
                            onChanged: (v) => setState(() => v == true ? _selected.add(d.id) : _selected.remove(d.id)),
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: BR.innerShape,
                            tileColor: _selected.contains(d.id) ? BC.greenSoft : null,
                            title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              d.ingredientCount == 0 ? 'Belum ada bahan' : '${d.ingredientCount} bahan',
                              style: mutedText,
                            ),
                          ),
                        if (list.isEmpty && q.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Belum ada menu di kategori ini. Ketik nama menu untuk membuatnya.',
                                textAlign: TextAlign.center, style: TextStyle(color: BC.muted)),
                          ),
                      ],
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton(
                  onPressed: _selected.isEmpty ? null : _submit,
                  child: Text(_selected.isEmpty ? 'Pilih menu dulu' : 'Tambahkan ${_selected.length} menu'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
