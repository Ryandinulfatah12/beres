import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../utils/share_text.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final app = appOf(context);
    final c = TextEditingController(text: app.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text('Mau dipanggil apa?', style: fredoka(20)),
        content: TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true) await app.saveProfile(newName: c.text);
    c.dispose();
  }

  Future<void> _editStore(BuildContext context, {Store? store}) async {
    final app = appOf(context);
    final c = TextEditingController(text: store?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(store == null ? 'Tempat belanja baru' : 'Ubah tempat belanja', style: fredoka(20)),
          content: TextField(
            controller: c,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nama toko'),
          ),
          actions: [
            if (store != null)
              TextButton(
                onPressed: () => Navigator.pop(d, 'delete'),
                style: TextButton.styleFrom(foregroundColor: BC.cabai),
                child: const Text('Hapus'),
              ),
            TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
            TextButton(onPressed: () => Navigator.pop(d, 'save'), child: const Text('Simpan')),
          ],
      ),
    );
    if (result == 'save' && c.text.trim().isNotEmpty) {
      await app.repo.saveStore(id: store?.id, name: c.text);
      app.changed();
    } else if (result == 'delete' && store != null) {
      await app.repo.deleteStore(store.id);
      app.changed();
    }
    c.dispose();
  }

  Future<void> _exportShopping(BuildContext context) async {
    final app = appOf(context);
    final id = await app.thisWeekId();
    final items = await app.repo.listShopping(id);
    if (!context.mounted) return;
    if (items.isEmpty) {
      showSnack(context, 'Daftar belanja minggu ini masih kosong.');
      return;
    }
    await Share.share(shoppingShareText(mondayOf(DateTime.now()), items));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            decoration: BoxDecoration(color: BC.pandan, borderRadius: BR.cardR),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: BC.kunyit, borderRadius: BR.pillR),
                  alignment: Alignment.center,
                  child: const Mascot(size: 54, steam: Steam.none, motion: Motion.still),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.name, style: fredoka(22, color: Colors.white)),
                      const Text('Pengelola dapur',
                          style: TextStyle(fontSize: 13, color: Color(0xFFD7E8DC), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _editName(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.white24),
                  child: const Text('Ubah'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionLabel('Hari masak'),
          BoxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var d = 1; d <= 7; d++)
                      FilterChip(
                        label: Text(dayShort[d - 1]),
                        selected: app.defaultDays.contains(d),
                        onSelected: (on) {
                          final days = {...app.defaultDays};
                          on ? days.add(d) : days.remove(d);
                          app.saveProfile(days: days.toList());
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Dipakai untuk minggu baru. Minggu yang sudah ada tidak berubah.', style: mutedText),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionLabel('Tempat belanja'),
          DataBuilder<List<Store>>(
            load: (a) => a.repo.listStores(),
            builder: (context, stores) => ListCard(children: [
              for (final s in stores)
                ListTile(
                  leading: const Icon(Icons.storefront_outlined, color: BC.daun),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A968D)),
                  onTap: () => _editStore(context, store: s),
                ),
              ListTile(
                leading: const Icon(Icons.add_rounded, color: BC.pandan),
                title: const Text('Tambah tempat belanja',
                    style: TextStyle(fontWeight: FontWeight.w700, color: BC.pandan)),
                onTap: () => _editStore(context),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          const SectionLabel('Data'),
          ListCard(children: [
            ListTile(
              leading: const Icon(Icons.download_rounded, color: BC.daun),
              title: const Text('Cadangkan data', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Kirim file database ke Drive, WhatsApp, atau penyimpanan', style: mutedText),
              onTap: () => Share.shareXFiles([XFile(app.repo.path)], text: 'Cadangan data Beres?'),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share_rounded, color: BC.daun),
              title: const Text('Bagikan daftar belanja', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Minggu ini, sebagai teks', style: mutedText),
              onTap: () => _exportShopping(context),
            ),
          ]),
          const SizedBox(height: 24),
          const Center(
            child: Column(
              children: [
                Wordmark(size: 22),
                SizedBox(height: 2),
                // Samakan dengan `version:` di pubspec.yaml setiap rilis.
                Text('versi 1.1.0', style: mutedText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
