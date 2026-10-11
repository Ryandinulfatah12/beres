import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/refresh.dart';
import '../widgets/mascot.dart';
import 'dish_detail_screen.dart';

class DishesScreen extends StatefulWidget {
  const DishesScreen({super.key});

  @override
  State<DishesScreen> createState() => _DishesScreenState();
}

class _DishesScreenState extends State<DishesScreen> {
  static const _cats = ['lauk', 'cemilan'];
  int _cat = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => DishDetailScreen(category: _cats[_cat]))),
        backgroundColor: BC.pandan,
        foregroundColor: Colors.white,
        shape: BR.pillShape,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Menu baru', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              eyebrow: 'Daftar menu tersimpan',
              title: 'Menu',
              trailing: Mascot(size: 56, eyes: Eyes.up, motion: Motion.tilt),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Cari menu'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Pills(labels: const ['Lauk', 'Cemilan'], index: _cat, onChanged: (i) => setState(() => _cat = i)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: DataBuilder<List<Dish>>(
                key: ValueKey(_cats[_cat]),
                load: (app) => app.repo.listDishes(_cats[_cat]),
                builder: (context, all) {
                  final q = _query.trim().toLowerCase();
                  final list = q.isEmpty ? all : all.where((d) => d.name.toLowerCase().contains(q)).toList();
                  if (list.isEmpty) {
                    return EmptyState(
                      title: q.isEmpty ? 'Belum ada menu' : 'Menu tidak ditemukan',
                      message: q.isEmpty
                          ? 'Simpan menu favorit beserta bahannya, nanti tinggal pilih.'
                          : 'Coba kata lain, atau buat menu baru.',
                    );
                  }
                  return BeresRefresh(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: [
                      ListCard(children: [
                        for (final d in list)
                          ListTile(
                            title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              [
                                d.ingredientCount == 0 ? 'belum ada bahan' : '${d.ingredientCount} bahan',
                                d.lastCooked == null
                                    ? 'belum pernah dimasak'
                                    : 'terakhir ${dayMonth(DateTime.parse(d.lastCooked!))}',
                              ].join(', '),
                              style: mutedText,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A968D)),
                            onTap: () => Navigator.push(
                                context, MaterialPageRoute(builder: (_) => DishDetailScreen(dishId: d.id))),
                          ),
                      ]),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
