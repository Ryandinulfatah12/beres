# Changelog

Semua perubahan penting pada proyek ini dicatat di file ini.
Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.1.0/),
dan proyek ini memakai [Semantic Versioning](https://semver.org/lang/id/).

## [Belum dirilis]

### Diubah
- **Eceran/grosir jadi cara beli per item, bukan jenis toko** (skema database v2). Sebelumnya `stores.type` memaksa satu toko hanya melayani salah satu, sehingga "beli telur grosir di pasar yang sama" mustahil dinyatakan tanpa membuat toko duplikat. Sekarang `shopping_items.buy_mode` diatur per baris lewat chip di daftar belanja, dan `ingredients.default_buy_mode` mengingatnya untuk generate berikutnya. Toko cukup punya nama.
- Data awal: toko tinggal Super Indo dan Pasar; bahan yang biasanya dibeli banyak diberi cara beli grosir, bukan diarahkan ke "Toko Grosir".
- Minimum Flutter naik dari 3.24 ke 3.27 (Dart 3.6) karena memakai `Color.withValues`.

### Migrasi
- Database v1 naik ke v2 otomatis: nilai `stores.type` lama diwarisi jadi cara beli tiap bahan dan item belanja, lalu tabel `stores` dibangun ulang tanpa kolom itu.

### Rencana
- Widget home screen (`home_widget` + Jetpack Glance): ukuran 2×2 dan 4×2.
- Pengingat susun menu dan belanja (`flutter_local_notifications`).
- Pulihkan data dari file cadangan (`file_picker`).
- Bundel font Fredoka dan Plus Jakarta Sans sebagai asset agar offline sejak instalasi pertama.

## [1.0.0] - 2026-10-04

Rilis MVP pertama.

### Ditambahkan
- Splash dan onboarding dengan maskot Si Beres, nama panggilan, dan hari masak default.
- Beranda: sapaan sesuai jam, menu hari ini dan besok, progres belanja, pengeluaran bulan ini, aksi cepat, pengingat hari kosong.
- Minggu Ini: 7 hari dengan hari opsional, tambah lauk/cemilan lewat bottom sheet, navigasi antar minggu.
- Daftar belanja: bahan dijumlahkan otomatis per bahan + satuan, filter Semua/Eceran/Grosir, ubah jumlah, pilih toko per item, item tambahan manual, geser untuk hapus, bagikan ke WhatsApp.
- Mode belanja: checklist besar, isi harga per item, total otomatis, filter per toko.
- Layar "Belanja beres!" dengan ringkasan per toko.
- Menu: master menu dan bahan (jumlah, satuan), catatan, terakhir dimasak.
- Riwayat: minggu sebelumnya, total belanja, salin menu ke minggu ini.
- Pengaturan: nama, hari masak, tempat belanja eceran/grosir, cadangkan database, bagikan daftar belanja.
- Penyimpanan lokal SQLite penuh offline, dengan data awal menu dan rencana minggu berjalan.
