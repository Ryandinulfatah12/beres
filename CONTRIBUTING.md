# Berkontribusi ke Beres?

Terima kasih sudah mampir. Proyek ini kecil dan santai — issue, saran fitur, dan pull request semuanya diterima.

## Menyiapkan lingkungan

```bash
git clone <url-repo-ini>
cd beres
flutter pub get
flutter run
```

Butuh Flutter 3.27 atau lebih baru. Folder `android/` dan `ios/` sudah ikut di repo — jangan menjalankan `flutter create` di dalamnya, karena perintah itu menimpa `lib/main.dart`, `pubspec.yaml`, `analysis_options.yaml`, `test/widget_test.dart`, `README.md`, dan `.gitignore` dengan file bawaan.

## Sebelum membuka pull request

```bash
dart format .
flutter analyze
flutter test
```

Pastikan ketiganya bersih. `flutter analyze` memakai `flutter_lints` lewat `analysis_options.yaml`.

## Gaya kode

- Ikuti gaya yang sudah ada di sekitar kode yang kamu ubah: penamaan, kerapatan komentar, dan idiom yang sama.
- Semua akses database lewat `lib/db/repo.dart`. Jangan menulis query SQL dari dalam screen.
- State aplikasi lewat `AppState` (`lib/state/app_state.dart`). Widget cukup `watch`/`read`.
- Teks UI memakai bahasa Indonesia. Nama variabel dan komentar kode memakai bahasa Inggris bila sudah begitu di file yang bersangkutan.
- Satu PR satu topik. PR besar yang mencampur beberapa fitur lebih sulit direview.

## Mengubah skema database

Skema ada di `lib/db/repo.dart`. Kalau kamu menambah atau mengubah tabel/kolom:

1. Naikkan versi database.
2. Tambahkan langkah migrasi untuk pengguna lama — jangan menghapus data mereka.
3. Tulis tesnya di `test/migration_test.dart` — periksa juga **relasi antar tabel**, bukan cuma isi kolomnya.
4. Sebutkan perubahannya di deskripsi PR.

Untuk menguji migrasi di perangkat sungguhan, `tool/make_v1_db.dart` membuat file database skema lama berisi data contoh:

```bash
dart run tool/make_v1_db.dart /tmp/v1.db
adb push /tmp/v1.db /data/local/tmp/
adb shell "run-as com.ryan.beres cp /data/local/tmp/v1.db databases/beres.db"
```

Lalu buka aplikasinya. Satu jebakan yang sudah pernah menggigit: `sqflite` menjalankan `onUpgrade` di dalam transaksi, dan SQLite **mengabaikan tanpa error** `PRAGMA foreign_keys = OFF` di dalam transaksi — jadi `DROP TABLE` pada tabel induk tetap memicu `ON DELETE SET NULL` dan mengosongkan kolom relasi di tabel lain.

## Commit

Pesan commit singkat dan deskriptif, boleh bahasa Indonesia atau Inggris. Contoh:

```
tambah filter toko di mode belanja
fix: total belanja tidak ikut item manual
```

## Melaporkan bug

Sertakan versi Flutter (`flutter --version`), perangkat/OS, langkah untuk mereproduksi, serta apa yang diharapkan versus apa yang terjadi. Tangkapan layar sangat membantu.
