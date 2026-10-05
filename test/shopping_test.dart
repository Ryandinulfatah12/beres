import 'dart:io';

import 'package:beres/db/repo.dart';
import 'package:beres/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Aturan generate daftar belanja — jantung aplikasi. Dites di atas database
/// sungguhan (ffi), bukan mock, supaya SQL agregasinya ikut terbukti.
void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;

  late Directory dir;
  late Repo repo;
  late int weekId;

  /// Minggu khusus tes, sengaja jauh dari minggu berjalan yang diisi seed.
  final monday = DateTime(2030, 1, 7);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('beres_belanja');
    repo = await Repo.openAt('${dir.path}/beres.db', factory: factory);
    weekId = await repo.ensureWeek(monday, const []);
  });

  tearDown(() async {
    await repo.db.close();
    await dir.delete(recursive: true);
  });

  Future<int> buatMenu(String nama, List<DishIngredient> bahan) =>
      repo.saveDish(name: nama, category: 'lauk', ingredients: bahan);

  /// Pasang menu ke satu hari, lalu aktifkan harinya.
  Future<void> pasang(int dow, List<int> dishIds) async {
    final week = await repo.getWeek(weekId);
    await repo.addDishes(week.day(dow).id, dishIds);
  }

  Future<ShopItem> cari(String nama) async =>
      (await repo.listShopping(weekId)).firstWhere((i) => i.name == nama);

  test('bahan yang sama dengan satuan sama dijumlahkan', () async {
    final sate = await buatMenu('Sate', [DishIngredient(name: 'Dada ayam', qty: 500, unit: 'gr')]);
    final capcay = await buatMenu('Capcay', [DishIngredient(name: 'Dada ayam', qty: 200, unit: 'gr')]);
    await pasang(1, [sate]);
    await pasang(2, [capcay]);

    await repo.generateShopping(weekId);

    final ayam = await cari('Dada ayam');
    expect(ayam.qty, 700);
    expect(ayam.unit, 'gr');
    expect(ayam.sources, allOf(contains('Sate'), contains('Capcay')),
        reason: 'asal bahan menyebut kedua menu');
  });

  test('bahan sama dengan satuan berbeda tetap jadi dua baris', () async {
    final a = await buatMenu('Rendang', [DishIngredient(name: 'Daging', qty: 500, unit: 'gr')]);
    final b = await buatMenu('Semur', [DishIngredient(name: 'Daging', qty: 1, unit: 'kg')]);
    await pasang(1, [a, b]);

    await repo.generateShopping(weekId);

    final daging = (await repo.listShopping(weekId)).where((i) => i.name == 'Daging').toList();
    expect(daging.length, 2, reason: 'gr dan kg tidak boleh dijumlahkan mentah-mentah');
    expect(daging.map((i) => i.unit).toSet(), {'gr', 'kg'});
  });

  test('hari non-aktif tidak ikut dihitung', () async {
    final libur = await buatMenu('Soto', [DishIngredient(name: 'Ayam', qty: 1, unit: 'ekor')]);
    await pasang(3, [libur]);

    final week = await repo.getWeek(weekId);
    await repo.setDayActive(week.day(3).id, false);
    await repo.generateShopping(weekId);

    expect(await repo.listShopping(weekId), isEmpty);
  });

  test('nama bahan tidak peduli huruf besar-kecil', () async {
    final a = await buatMenu('Tumis', [DishIngredient(name: 'Bawang Merah', qty: 5, unit: 'siung')]);
    final b = await buatMenu('Sambal', [DishIngredient(name: 'bawang merah', qty: 6, unit: 'siung')]);
    await pasang(1, [a, b]);

    await repo.generateShopping(weekId);

    final bawang = (await repo.listShopping(weekId)).where((i) => i.unit == 'siung').toList();
    expect(bawang.length, 1, reason: 'harus dianggap satu bahan');
    expect(bawang.single.qty, 11);
  });

  test('generate ulang mempertahankan item manual', () async {
    final menu = await buatMenu('Goreng', [DishIngredient(name: 'Tahu', qty: 2, unit: 'bungkus')]);
    await pasang(1, [menu]);
    await repo.generateShopping(weekId);
    await repo.addManual(weekId, 'Tisu muka');

    await repo.generateShopping(weekId);

    final items = await repo.listShopping(weekId);
    expect(items.map((i) => i.name), contains('Tisu muka'));
    expect(items.firstWhere((i) => i.name == 'Tisu muka').manual, isTrue);
  });

  test('generate ulang mempertahankan centang dan harga, tapi memperbarui jumlah', () async {
    final sate = await buatMenu('Sate', [DishIngredient(name: 'Dada ayam', qty: 500, unit: 'gr')]);
    await pasang(1, [sate]);
    await repo.generateShopping(weekId);

    final sebelum = await cari('Dada ayam');
    await repo.setShopChecked(sebelum.id, true);
    await repo.setShopPrice(sebelum, 45000);

    // Menu kedua ditambahkan setelah belanja dimulai.
    final capcay = await buatMenu('Capcay', [DishIngredient(name: 'Dada ayam', qty: 200, unit: 'gr')]);
    await pasang(2, [capcay]);
    await repo.generateShopping(weekId);

    final sesudah = await cari('Dada ayam');
    expect(sesudah.id, sebelum.id, reason: 'baris yang sama dipakai ulang, bukan dibuat baru');
    expect(sesudah.checked, isTrue);
    expect(sesudah.price, 45000);
    expect(sesudah.qty, 700, reason: 'jumlahnya tetap diperbarui');
  });

  test('item dari menu yang belum dicentang dibangun ulang', () async {
    final menu = await buatMenu('Tumis', [DishIngredient(name: 'Buncis', qty: 300, unit: 'gr')]);
    await pasang(1, [menu]);
    await repo.generateShopping(weekId);
    expect((await repo.listShopping(weekId)).length, 1);

    // Menunya dibatalkan dari rencana.
    final week = await repo.getWeek(weekId);
    await repo.removePlanItem(week.day(1).items.single.id);
    await repo.generateShopping(weekId);

    expect(await repo.listShopping(weekId), isEmpty,
        reason: 'bahan yang menunya dibatalkan ikut hilang');
  });

  test('cara beli default bahan terbawa ke daftar belanja', () async {
    // Bahan yang tidak ada di data awal, supaya defaultnya benar-benar baru.
    final menu = await buatMenu('Semur', [DishIngredient(name: 'Kecap manis', qty: 1, unit: 'botol')]);
    await pasang(1, [menu]);
    await repo.generateShopping(weekId);

    final kecap = await cari('Kecap manis');
    expect(kecap.grosir, isFalse, reason: 'bahan baru default eceran');

    await repo.setShopBuyMode(kecap, 'grosir');
    await repo.generateShopping(weekId);

    expect((await cari('Kecap manis')).grosir, isTrue,
        reason: 'pilihan cara beli diingat untuk generate berikutnya');
  });

  test('bahan bawaan yang biasa dibeli banyak sudah bermode grosir', () async {
    final menu = await buatMenu('Rolade', [DishIngredient(name: 'Telur', qty: 3, unit: 'butir')]);
    await pasang(1, [menu]);
    await repo.generateShopping(weekId);

    expect((await cari('Telur')).grosir, isTrue,
        reason: 'Telur ada di data awal dengan cara beli grosir');
  });
}
