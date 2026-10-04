# Beres?

> Dari menu sampai belanja, semua beres.

[![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)](#menjalankan)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Aplikasi Flutter offline untuk menyusun menu lauk dan cemilan mingguan, membuat daftar belanja otomatis dari bahan menu (eceran/grosir), lalu checklist dan catat harga saat belanja.

Semua data tersimpan di perangkat memakai SQLite. Tidak ada akun, tidak ada server, tidak ada data yang dikirim ke mana pun.

**Alurnya satu putaran:** susun menu seminggu → generate daftar belanja → belanja sambil centang dan catat harga → riwayat dan total pengeluaran → minggu depan tinggal salin.

---

## Daftar isi

- [Menjalankan](#menjalankan)
- [Alur pemakaian](#alur-pemakaian)
- [Fitur](#fitur)
  - [Splash dan onboarding](#splash-dan-onboarding)
  - [Beranda](#beranda)
  - [Minggu Ini](#minggu-ini)
  - [Pilih menu (bottom sheet)](#pilih-menu-bottom-sheet)
  - [Daftar belanja](#daftar-belanja)
  - [Mode belanja](#mode-belanja)
  - [Belanja beres!](#belanja-beres)
  - [Menu](#menu)
  - [Riwayat](#riwayat)
  - [Pengaturan](#pengaturan)
- [Aturan generate daftar belanja](#aturan-generate-daftar-belanja)
- [Model data](#model-data)
- [Struktur proyek](#struktur-proyek)
- [Desain dan maskot](#desain-dan-maskot)
- [Teknologi](#teknologi)
- [Pengembangan](#pengembangan)
- [Batasan saat ini](#batasan-saat-ini)
- [Berikutnya](#berikutnya)
- [Privasi](#privasi)
- [Berkontribusi](#berkontribusi)
- [Lisensi](#lisensi)

---

## Menjalankan

```bash
git clone <url-repo-ini>
cd beres
flutter pub get
flutter run
```

Butuh Flutter 3.24 atau lebih baru (Dart SDK `>=3.4.0 <4.0.0`); diuji dengan Flutter 3.32.6 di Android dan iOS.

Folder `android/` dan `ios/` sudah ikut di repo, jadi tidak perlu `flutter create` lagi. Nama aplikasi (`Beres?`) dan izin `INTERNET` — dipakai `google_fonts` untuk mengunduh Fredoka dan Plus Jakarta Sans sekali di awal lalu di-cache — sudah terpasang di `android/app/src/main/AndroidManifest.xml`.

## Alur pemakaian

```
Splash ──► Onboarding (sekali) ──► Shell (5 tab)
                                     │
   ┌─────────────────────────────────┴───────────────────────────────┐
   │                                                                 │
Beranda        Minggu Ini          Belanja           Menu        Riwayat
  │              │                   │                 │            │
  │   pilih menu per hari    generate dari menu    master menu   minggu lalu
  │              └──────────────────►│                 │            │
  │                                  │                 │            │
  │                          Mode belanja ──► Belanja beres!        │
  │                        (centang + harga)   (ringkasan toko)     │
  └───────────────── aksi cepat, salin minggu lalu ─────────────────┘
```

Lima tab di `NavigationBar` bawah (`lib/screens/shell.dart`): **Beranda**, **Minggu Ini**, **Belanja**, **Menu**, **Riwayat**. Tab dijaga hidup lewat `IndexedStack`, jadi posisi scroll tiap tab tidak hilang saat berpindah.

---

## Fitur

### Splash dan onboarding

`lib/screens/splash_screen.dart`, `lib/screens/onboarding_screen.dart`

- Splash hijau pandan dengan maskot **Si Beres** yang berganti ekspresi tiap 1,1 detik, lalu transisi fade (±2,6 detik) ke tujuan berikutnya.
- Tujuan ditentukan oleh flag `onboarded` di tabel `settings`: belum pernah → Onboarding, sudah → Shell.
- Onboarding menanyakan dua hal saja:
  - **Mau dipanggil apa?** — kolom teks bebas plus chip cepat: Bunda, Mama, Sayang, Nyonya. Kosong berarti "Sayang".
  - **Biasanya masak hari apa?** — tujuh toggle Sen–Min, default Senin–Jumat.
- Kedua jawaban disimpan ke `settings` (`name`, `default_days`) dan jadi dasar pembuatan minggu baru.

### Beranda

`lib/screens/home_screen.dart`

Satu layar untuk menjawab "hari ini masak apa, belanja masih kurang apa":

| Bagian                          | Isi                                                                                                                                   |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Sapaan                          | `greeting()` menyesuaikan jam — pagi (<11), siang (<15), sore (<18), malam — plus nama panggilan dan tanggal lengkap bahasa Indonesia |
| Balon ucapan maskot             | Teks menyesuaikan kondisi: hari libur masak, menu belum diisi, atau menyebut nama lauk pertama hari ini                               |
| Kartu **Menu hari ini**         | Kartu hijau tua: daftar lauk, baris cemilan, tombol ke tab Minggu Ini                                                                 |
| Kartu **Belanja minggu ini**    | "N item lagi", "x dari y sudah dibeli", progress bar beranimasi; ditekan → tab Belanja                                                |
| Kartu **Pengeluaran bulan ini** | Total rupiah item yang dicentang pada minggu-minggu bulan berjalan + jumlah kali belanja; ditekan → tab Riwayat                       |
| Kartu **Besok**                 | Menu hari berikutnya, atau "Libur masak" / "Belum ada menu"                                                                           |
| Aksi cepat                      | Menu baru · Belanja · Salin minggu lalu · Riwayat                                                                                     |
| Kartu ide                       | Muncul otomatis kalau ada hari ke depan yang masih kosong: "Kamis masih kosong — Mau masak apa?" dengan tombol **Isi menu**           |

"Salin minggu lalu" mencari minggu H-7, minta konfirmasi karena menu minggu ini akan ditimpa, lalu menyalin hari aktif beserta isinya.

Beranda selalu membaca **minggu kalender saat ini** (`thisWeekId()`), berbeda dari tab Minggu Ini/Belanja yang mengikuti minggu yang sedang kamu buka.

### Minggu Ini

`lib/screens/week_screen.dart`

- Judul berupa rentang tanggal (`weekRange`), misal `6 – 12 Okt 2026`, dengan eyebrow "Minggu ini" atau "Rencana minggu".
- Tombol `‹` dan `›` menggeser minggu tujuh hari — bisa menyusun menu minggu depan atau mengoreksi minggu lalu. Minggu yang belum ada dibuat otomatis memakai hari masak default.
- Kartu ringkasan: "N hari masak, N lauk, N cemilan", dengan ekspresi maskot berubah begitu menunya terisi.
- Tujuh **kartu hari**:
  - Checkbox **Masak** mematikan hari (misal hari ke luar kota). Hari non-aktif jadi transparan dan bahannya tidak ikut dihitung saat generate belanja.
  - Hari ini diberi border hijau dan tag "Hari ini".
  - Lauk dan cemilan tampil sebagai chip terpisah, masing-masing punya tombol × untuk hapus.
  - Tombol **Tambah menu** membuka bottom sheet pemilih.
- Tombol utama **Generate daftar belanja** menjumlahkan bahan, memberi tahu jumlah bahan yang dihasilkan, lalu pindah ke tab Belanja. Kalau menunya belum punya bahan, muncul pesan yang mengarahkan ke halaman Menu.

### Pilih menu (bottom sheet)

`lib/screens/pick_dish_sheet.dart`

- Terbuka setinggi 82% layar, judulnya menyebut harinya: "Kamis mau masak apa?".
- Pills **Lauk / Cemilan**, kolom cari, dan daftar menu tersimpan beserta jumlah bahannya.
- **Pilih banyak sekaligus** — tombol bawah berubah jadi "Tambahkan 3 menu".
- Mengetik nama yang belum ada memunculkan baris **Buat menu baru "…"**; menu langsung dibuat (bahan bisa dilengkapi nanti) dan otomatis tercentang.
- Menambahkan menu ke hari non-aktif otomatis mengaktifkan hari itu.

### Daftar belanja

`lib/screens/shopping_screen.dart`

- Dua kelompok: **Dari menu** (hasil generate) dan **Tambahan** (item manual seperti tisu atau sabun).
- Pills filter dengan hitungan langsung: `Semua 24` · `Eceran 18` · `Grosir 6`.
- Tiap baris menampilkan nama bahan, tag toko, dan **asal bahan** — nama menu yang memakainya (kolom `sources`), jadi jelas kenapa item itu ada di daftar.
- **Stepper jumlah** dengan langkah pintar: 50 untuk satuan `gr` dan `ml`, 1 untuk satuan lain. Menekan angkanya membuka dialog untuk mengisi jumlah dan satuan bebas.
- Mengetuk tag toko membuka pemilih toko per item.
- **Geser ke kiri untuk hapus** (`Dismissible`); item hilang seketika tanpa menunggu database.
- **Generate ulang** aman dipakai kapan saja — lihat [aturannya](#aturan-generate-daftar-belanja).
- Ikon bagikan menyusun teks daftar belanja yang dikelompokkan per toko, siap dikirim ke WhatsApp:

  ```
  Daftar belanja Beres? · 6 – 12 Okt 2026

  *Super Indo (Eceran)*
  ☐ Dada ayam — 1000 gr
  ☑ Bawang merah — 11 siung

  *Toko Grosir (Grosir)*
  ☐ Telur — 13 butir
  ```

- Daftar kosong menampilkan empty state dengan tombol **Generate dari menu**.

### Mode belanja

`lib/screens/shopping_mode_screen.dart`

Layar fokus untuk dipakai sambil berdiri di toko:

- Header hijau tua dengan progres "7 dari 24 item diambil" dan **progress bar bertroli** — ikon troli kuning berjalan mengikuti progres.
- Checkbox diperbesar 1,2× dan seluruh baris bisa diketuk, plus getaran halus (`HapticFeedback`) tiap kali mencentang.
- Kolom **harga per item** (angka saja, prefix `Rp`). Total di bawah dijumlahkan dari item yang dicentang dan beranimasi saat berubah.
- Harga yang diisi juga disimpan sebagai `last_price` bahan tersebut, jadi tersedia untuk pengembangan perkiraan harga.
- Chip filter per toko muncul otomatis kalau item tersebar di lebih dari satu toko — belanja satu toko dulu, lalu pindah.
- Item yang sudah dicentang turun ke bawah daftar supaya yang belum diambil tetap di atas.
- **Selesai** memberi peringatan kalau masih ada item belum dicentang, lalu menandai minggu itu selesai (`finished_at`) dan membuka layar perayaan.
- Semua perubahan ditulis ke database saat itu juga, jadi aman kalau aplikasi tertutup di tengah belanja.

### Belanja beres!

`lib/screens/shopping_done_screen.dart`

- Confetti (`CustomPainter`, 22 potong, lima warna palet) dan maskot melompat. Animasi otomatis dimatikan kalau pengguna mengaktifkan "reduce motion" di perangkatnya.
- Pesan personal: "24 item sudah masuk keranjang. Kerja bagus, Bunda."
- Ringkasan **total per toko** plus total minggu ini.
- Dua jalan keluar: kembali ke Beranda, atau lihat daftar belanja.

### Menu

`lib/screens/dishes_screen.dart`, `lib/screens/dish_detail_screen.dart`

Master menu yang dipakai berulang:

- Pills **Lauk / Cemilan**, kolom cari, dan FAB **Menu baru**.
- Setiap baris menunjukkan jumlah bahan dan **terakhir dimasak** — dihitung dari rencana mingguan yang tanggalnya sudah lewat, bukan field terpisah, jadi selalu akurat.
- Halaman detail: nama, kategori, catatan, dan daftar bahan dengan tiga kolom (nama · jumlah · satuan) yang bisa ditambah atau dihapus barisnya.
- Nama bahan dinormalkan ke tabel `ingredients` dengan pencocokan tanpa peduli huruf besar-kecil, sehingga "Bawang Merah" dan "bawang merah" tetap satu bahan dan ikut dijumlahkan saat generate.
- Menghapus menu juga menghapusnya dari rencana mingguan mana pun yang memakainya (`ON DELETE CASCADE`), dan dikonfirmasi lebih dulu.

### Riwayat

`lib/screens/history_screen.dart`

- Kartu atas: total belanja bulan berjalan dan berapa kali belanja.
- Daftar sampai 40 minggu terakhir (minggu tanpa menu dilewati), masing-masing menampilkan rentang tanggal, "N hari, N lauk, N cemilan", pratinjau nama lauk (maksimal 4 lalu "+3 lainnya"), dan total belanja atau "Belum belanja".
- **Salin ke minggu ini** mengambil seluruh pola minggu itu — hari aktif dan isinya — ke minggu berjalan, dengan konfirmasi karena menimpa.
- **Lihat** membuka minggu tersebut di tab Minggu Ini.

### Pengaturan

`lib/screens/settings_screen.dart`

- **Profil**: ubah nama panggilan.
- **Hari masak**: chip Sen–Min. Hanya berlaku untuk minggu baru; minggu yang sudah ada tidak berubah.
- **Tempat belanja**: tambah, ubah, hapus toko, masing-masing bertipe **eceran** atau **grosir**. Tipe inilah yang menggerakkan filter dan pengelompokan di seluruh aplikasi.
- **Cadangkan data**: membagikan file `beres.db` apa adanya lewat share sheet — ke Drive, WhatsApp, atau penyimpanan lain.
- **Bagikan daftar belanja**: teks daftar belanja minggu ini.

---

## Aturan generate daftar belanja

`Repo.generateShopping` (`lib/db/repo.dart`) berjalan dalam satu transaksi:

1. Ambil semua bahan dari seluruh menu di **hari yang aktif** pada minggu tersebut.
2. Kelompokkan per **bahan + satuan**, lalu jumlahkan `qty`-nya. Dada ayam 500 gr (sate taichan) + 200 gr (capcay) menjadi satu baris **700 gr**. Bahan yang sama dengan satuan berbeda tetap jadi dua baris supaya tidak salah hitung.
3. Isi kolom `sources` dengan nama menu asal, dipakai sebagai keterangan di tiap baris.
4. Toko diambil dari `default_store_id` bahan tersebut.
5. **Yang tidak terhapus saat generate ulang:**
   - item **manual** (tambahan kamu sendiri),
   - item yang sudah **dicentang** — jumlah dan asalnya diperbarui, tetapi status centang dan harganya dipertahankan.

   Yang dihapus dan dibangun ulang hanya item dari menu yang belum dicentang. Jadi aman menekan "Generate ulang" di tengah-tengah belanja setelah menambah satu menu.

## Model data

SQLite, delapan tabel, `PRAGMA foreign_keys = ON`:

```
settings          key/value: name, default_days, onboarded
stores            nama toko + type ('eceran' | 'grosir')
ingredients       nama unik (NOCASE), satuan default, harga terakhir, toko default
dishes            menu: nama, kategori ('lauk' | 'cemilan'), catatan
dish_ingredients  dishes ✕ ingredients, dengan qty dan unit
week_plans        satu baris per minggu (week_start unik), finished_at
plan_days         7 baris per minggu, day_of_week 1–7, is_active
plan_items        menu yang dipasang pada satu hari, dengan sort_order
shopping_items    hasil generate + item manual: qty, unit, toko, harga, dicentang, sources
```

Relasinya:

```
week_plans 1──n plan_days 1──n plan_items n──1 dishes n──n ingredients
     │                                                        │
     └── 1──n shopping_items ──────────────────────────────────┘
                   └── n──1 stores ──1──n ingredients.default_store_id
```

Minggu diidentifikasi dari tanggal Senin-nya (`week_start`, format `yyyy-MM-dd`), dibuat sesuai kebutuhan oleh `ensureWeek` beserta tujuh `plan_days`-nya.

Database baru langsung terisi data awal: tiga toko (Super Indo, Pasar, Toko Grosir), 13 menu beserta perkiraan bahannya, dan rencana Senin–Jumat minggu berjalan. Bahan yang biasanya dibeli grosir (telur, gula pasir, tepung tapioka, beras, minyak goreng) otomatis diarahkan ke toko grosir. Semuanya bisa diedit di halaman Menu dan Pengaturan.

## Struktur proyek

```
lib/
  main.dart                      init locale id_ID, buka database, pasang provider
  theme.dart                     palet BC + tema Material 3 (Fredoka / Plus Jakarta Sans)
  models.dart                    Store, Dish, DishIngredient, PlanItem, PlanDay,
                                 WeekPlan, ShopItem, WeekSummary
  db/repo.dart                   skema SQLite, seed, dan SEMUA query
  state/app_state.dart           ChangeNotifier: profil, minggu aktif, tab, versi data
  utils/format.dart              tanggal/rupiah/jumlah bahasa Indonesia, mondayOf, greeting
  utils/share_text.dart          teks daftar belanja per toko untuk WhatsApp
  widgets/mascot.dart            Si Beres — CustomPainter beranimasi, ekspresi bisa diatur
  widgets/common.dart            DataBuilder, Pills, Tag, BoxCard, ListCard, ScreenHeader,
                                 EmptyState, FadeIn, showSnack, confirm
  screens/
    splash_screen.dart           maskot + rute ke onboarding atau shell
    onboarding_screen.dart       nama panggilan + hari masak
    shell.dart                   NavigationBar 5 tab di atas IndexedStack
    home_screen.dart             beranda
    week_screen.dart             rencana 7 hari
    pick_dish_sheet.dart         bottom sheet pemilih menu
    shopping_screen.dart         daftar belanja
    shopping_mode_screen.dart    mode belanja di toko
    shopping_done_screen.dart    perayaan + ringkasan per toko
    dishes_screen.dart           master menu
    dish_detail_screen.dart      editor menu dan bahan
    history_screen.dart          riwayat minggu
    settings_screen.dart         pengaturan
test/
  widget_test.dart               unit test util tanggal dan jumlah
```

Dua aturan yang menjaga kode tetap rapi:

- **Semua SQL ada di `db/repo.dart`.** Tidak ada query yang ditulis dari dalam screen.
- **Pemuatan data lewat `DataBuilder`.** Widget ini menyatakan apa yang dibutuhkannya dan memuat ulang otomatis tiap kali `AppState.version` berubah, jadi tidak perlu `setState` manual setelah mengubah data — cukup `app.changed()`.

## Desain dan maskot

- **Palet dapur** di `theme.dart`: pandan (`#2E6A4C`), daun (`#1F4D36`), kunyit (`#F5C24C`), cabai (`#C8622A`), santan (`#F3F5F1`), arang (`#1B2A21`).
- **Huruf**: Fredoka untuk judul, Plus Jakarta Sans untuk teks, lewat `google_fonts`.
- **Si Beres** digambar sepenuhnya dengan `CustomPainter` — tanpa aset gambar. Bentuknya bisa diatur: `Steam` (tanda tanya, centang, tukar), `Eyes` (terbuka, senang, melihat ke atas), dan `Motion` (mengambang, melompat, miring, diam). Maskot yang sama dipakai dengan ekspresi berbeda di splash, onboarding, beranda, pemilih menu, dan layar perayaan.
- Seluruh teks UI berbahasa Indonesia; tanggal dan rupiah diformat dengan locale `id_ID`.

## Teknologi

| Paket              | Peran                                                 |
| ------------------ | ----------------------------------------------------- |
| `sqflite` + `path` | penyimpanan lokal SQLite                              |
| `provider`         | satu `ChangeNotifier` (`AppState`) untuk state global |
| `intl`             | format tanggal dan rupiah locale `id_ID`              |
| `share_plus`       | bagikan teks daftar belanja dan file cadangan         |
| `google_fonts`     | Fredoka dan Plus Jakarta Sans                         |
| `flutter_lints`    | aturan lint (`analysis_options.yaml`)                 |

Tanpa code generation, tanpa ORM, tanpa state management berlapis — Material 3 bawaan Flutter plus satu ChangeNotifier.

## Pengembangan

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Yang perlu diketahui sebelum menyentuh kode:

- Database dibuka sekali di `main()` sebelum `runApp`, jadi `Repo` selalu siap pakai dan tidak ada state "loading database" di dalam widget.
- `AppState.weekId()` memakai minggu yang sedang dibuka; `thisWeekId()` selalu minggu kalender saat ini. Beranda dan Riwayat memakai yang kedua.
- Skema masih `version: 1` dan belum punya langkah migrasi. Kalau kamu mengubah tabel, naikkan versinya dan tambahkan migrasi — lihat [CONTRIBUTING.md](CONTRIBUTING.md).

## Batasan saat ini

Jujur soal apa yang belum ada:

- **Belum ada pemulihan dari file cadangan.** Cadangkan sudah bisa (file `.db` dibagikan), tetapi mengembalikannya masih harus manual.
- **Belum ada migrasi database.** Mengubah skema saat ini berarti data lama perlu penanganan tersendiri.
- Font diunduh sekali saat pertama dijalankan, jadi tampilan pertama butuh internet sebelum ikut di-cache.
- Satu profil per perangkat; belum ada sinkronisasi antar perangkat.
- Rencana mingguan dipasang per hari, belum per waktu makan (sarapan/siang/malam).

## Berikutnya

- Widget home screen (`home_widget` + Jetpack Glance): kecil 2×2 dan sedang 4×2 dulu.
- Pengingat susun menu dan belanja (`flutter_local_notifications`).
- Pulihkan dari file cadangan (`file_picker`).
- Bundel font sebagai asset agar 100% offline sejak instalasi pertama.
- Perkiraan harga dari `last_price` bahan, supaya total belanja bisa diperkirakan sebelum ke toko.

## Privasi

Beres? bekerja sepenuhnya offline. Database SQLite berada di penyimpanan privat aplikasi dan hanya keluar dari perangkat kalau kamu sendiri menekan "Cadangkan data" atau membagikan daftar belanja. Satu-satunya akses jaringan adalah unduhan font sekali di awal lewat `google_fonts`.

## Berkontribusi

Issue dan pull request diterima. Baca [CONTRIBUTING.md](CONTRIBUTING.md) untuk cara menyiapkan lingkungan, menjalankan `flutter analyze` dan `flutter test`, serta aturan saat mengubah skema database. Riwayat perubahan ada di [CHANGELOG.md](CHANGELOG.md).

## Lisensi

[MIT](LICENSE) © Dinul Fatah Ryan
