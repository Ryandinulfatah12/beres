# Berkontribusi ke Beres?

Terima kasih sudah mampir. Proyek ini kecil dan santai — issue, saran fitur, dan pull request semuanya diterima.

## Menyiapkan lingkungan

```bash
git clone <url-repo-ini>
cd beres
flutter pub get
flutter run
```

Butuh Flutter 3.24 atau lebih baru. Folder `android/` dan `ios/` sudah ikut di repo — jangan menjalankan `flutter create` di dalamnya, karena perintah itu menimpa `lib/main.dart`, `pubspec.yaml`, `analysis_options.yaml`, `test/widget_test.dart`, `README.md`, dan `.gitignore` dengan file bawaan.

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
3. Sebutkan perubahannya di deskripsi PR.

## Commit

Pesan commit singkat dan deskriptif, boleh bahasa Indonesia atau Inggris. Contoh:

```
tambah filter toko di mode belanja
fix: total belanja tidak ikut item manual
```

## Melaporkan bug

Sertakan versi Flutter (`flutter --version`), perangkat/OS, langkah untuk mereproduksi, serta apa yang diharapkan versus apa yang terjadi. Tangkapan layar sangat membantu.
