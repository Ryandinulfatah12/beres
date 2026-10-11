import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'dishes_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'shopping_screen.dart';
import 'week_screen.dart';

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      body: IndexedStack(
        index: app.tab,
        children: const [HomeScreen(), WeekScreen(), ShoppingScreen(), DishesScreen(), HistoryScreen()],
      ),
      bottomNavigationBar: BeresNavBar(index: app.tab, onSelect: app.setTab),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.active, this.label);
  final IconData icon;
  final IconData active;
  final String label;
}

const _items = [
  _NavItem(Icons.home_outlined, Icons.home_rounded, 'Beranda'),
  _NavItem(Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Minggu'),
  _NavItem(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, 'Belanja'),
  _NavItem(Icons.menu_book_outlined, Icons.menu_book_rounded, 'Menu'),
  _NavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Riwayat'),
];

/// Bilah navigasi melayang: kapsul gelap, ikon bulat, dan hanya tab terpilih
/// yang memperlihatkan namanya di dalam pil putih.
class BeresNavBar extends StatelessWidget {
  const BeresNavBar({super.key, required this.index, required this.onSelect});
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            // Hijau pekat, bukan primary: bilah ini chrome yang harus mundur,
            // sementara tombol utama (pandan) perlu maju di atasnya.
            color: BC.daun,
            borderRadius: BR.pillR,
            boxShadow: navShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _items.length; i++)
                _NavButton(
                  item: _items[i],
                  selected: i == index,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BR.pillR,
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              height: 46,
              padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 11),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BR.pillR,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selected ? item.active : item.icon,
                      size: 21, color: selected ? BC.daun : Colors.white.withValues(alpha: 0.82)),
                  if (selected) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(item.label,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style:
                              const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: BC.daun)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Hanya tab terpilih yang lentur: tab lain cukup selebar ikonnya, sehingga
    // sisa ruang jatuh ke pil berlabel dan labelnya tidak terpotong.
    return selected ? Flexible(child: button) : button;
  }
}
