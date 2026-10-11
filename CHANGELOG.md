# Changelog

Semua perubahan penting pada proyek ini dicatat di file ini.
Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.1.0/),
dan proyek ini memakai [Semantic Versioning](https://semver.org/lang/id/).

## [Belum dirilis]

### Rencana
- Pengingat susun menu dan belanja (`flutter_local_notifications`).
- Pulihkan data dari file cadangan (`file_picker`).
- Bundel font Fredoka dan Plus Jakarta Sans sebagai asset agar offline sejak instalasi pertama.
- Keystore rilis sendiri; `flutter build apk --release` saat ini masih ditandatangani kunci debug bawaan template.

## [1.1.0] - 2026-10-11

### Ditambahkan
- Komponen bersama baru: `StatTile`, `PillButton`, `SoftIcon`, `MascotAvatar`, dan token `BR` untuk sudut.
- `rupiahShort()` — nominal ringkas (`Rp 1,2jt`) agar muat di kartu statistik yang sempit.
- **Ikon aplikasi Beres?**, menggantikan logo Flutter bawaan. Di-render dari widget `Mascot` yang sama dengan yang dipakai di dalam aplikasi, lalu disebar ke semua ukuran Android (termasuk adaptive icon) dan iOS.
- **Widget home screen** (Android): menu hari ini, sampai tiga hari berikutnya, ringkasan minggu, dan sisa item belanja — diketuk untuk membuka aplikasi, dan ikut diperbarui tiap kali data berubah. Memakai `AppWidgetProvider` + `RemoteViews` klasik, bukan Jetpack Glance, supaya tidak menyeret Jetpack Compose.
- **Tarik ke bawah untuk menyegarkan**, dengan Si Beres sebagai indikatornya: pancinya mengintip naik dan miring mengikuti tarikan, uap "?" berubah jadi "✓" dan badannya menguning saat sudah cukup jauh, lalu uapnya jadi tanda putar sambil melompat-lompat selagi data dimuat ulang — "Tarik lagi ya…" → "Lepas, biar diaduk!" → "Sebentar, lagi diaduk…". Aktif di Beranda, Minggu Ini, Belanja, Menu, dan Riwayat. Dibangun di atas `CupertinoSliverRefreshControl` bawaan Flutter, tanpa menambah dependensi.

### Diperbaiki
- **Kartu "besok masak apa" hilang setiap hari Minggu.** Hari esok dihitung sebagai `weekday + 1`, yang di hari Minggu jatuh ke luar batas minggu — persis di hari orang menyiapkan menu. Kini diambil dari Senin minggu berikutnya.
- **Nama tab terpotong jadi "Be".** Kelima tab lentur sehingga ruang terbagi rata lima dan pil berlabel tidak kebagian; sekarang hanya tab terpilih yang lentur.
- **Kartu pengeluaran menampilkan bar penuh padahal nilainya Rp 0**, terbaca seperti meter 100%. Kartu tanpa rasio kini hanya menggambar setrip aksen pendek.
- **`UNIQUE constraint failed: week_plans.week_start` saat berpindah minggu.** `ensureWeek` melakukan SELECT lalu INSERT tanpa penjagaan, padahal layar Minggu Ini dan Belanja hidup bersamaan di `IndexedStack` dan memanggilnya berbarengan untuk minggu yang sama. Keduanya kini memakai `INSERT OR IGNORE`, jadi pemanggil kedua ikut memakai baris buatan yang pertama.

### Diubah
- **Beranda didesain ulang, dan informasi kembarnya dibuang.** Menu hari ini sebelumnya disebut tiga kali di satu layar — di tagline, di gelembung ucapan maskot, dan di kartu menu. Sekarang sekali. Ikut hilang: baris "Dapur siap, perut juga siap.", gelembung ucapan, baris wordmark terpisah, serta aksi cepat Belanja dan Riwayat yang sudah punya dua pintu lain. Sebagai gantinya: sapaan dengan maskot sebagai avatar, judul besar bertanggal, kartu utama bergradasi, tiga kartu statistik bergaris warna, dan baris "besok masak apa" yang ringkas.
- **Satu bahasa sudut untuk seluruh aplikasi.** Radius yang tadinya tersebar di sepuluh nilai berbeda (6, 9, 10, 12, 14, 16, 18, 20, 28, 99) kini mengacu ke tiga token di `BR`: `pill` untuk semua kontrol, `card` untuk semua permukaan, `inner` untuk baris padat dan kotak isian.
- **Bilah navigasi jadi kapsul melayang** berwarna hijau pekat, hanya tab terpilih yang memperlihatkan namanya di dalam pil putih. Hijau pekat dipilih supaya tombol utama (pandan) yang duduk tepat di atasnya tetap menonjol.
- **Daftar belanja dikelompokkan per toko.** Nama toko disebut sekali sebagai judul grup, bukan diulang sebagai chip di tiap baris — di daftar 28 item, chip "Super Indo" yang sama muncul 28 kali tanpa memberi informasi. Memindahkan toko sebuah item kini lewat ketukan pada barisnya. Ruang yang dibebaskan dipakai kolom sumber menu, yang tadinya terpotong jadi tiga huruf.
- Di Mode Belanja, nama toko tidak lagi ditulis di tiap baris saat daftarnya sudah disaring ke satu toko.
- **Layar Riwayat didesain ulang.** Dari kartu-kartu melayang yang masing-masing membawa dua tombol besar, jadi daftar terkelompok per bulan: satu kartu per bulan berisi baris-baris minggu, total per bulan di header, seluruh baris diketuk untuk membuka, dan menyalin cukup satu ikon kecil. Nama lauk tampil sebagai chip (maksimal 3 + sisanya), bukan satu kalimat panjang dipisah koma.
- **Eceran/grosir jadi cara beli per item, bukan jenis toko** (skema database v2). Sebelumnya `stores.type` memaksa satu toko hanya melayani salah satu, sehingga "beli telur grosir di pasar yang sama" mustahil dinyatakan tanpa membuat toko duplikat. Sekarang `shopping_items.buy_mode` diatur per baris lewat chip di daftar belanja, dan `ingredients.default_buy_mode` mengingatnya untuk generate berikutnya. Toko cukup punya nama.
- Data awal: toko tinggal Super Indo dan Pasar; bahan yang biasanya dibeli banyak diberi cara beli grosir, bukan diarahkan ke "Toko Grosir".
- Minimum Flutter naik dari 3.24 ke 3.27 (Dart 3.6) karena memakai `Color.withValues`.

### Migrasi
- Database v1 naik ke v2 otomatis: nilai `stores.type` lama diwarisi jadi cara beli tiap bahan dan item belanja, lalu tabel `stores` dibangun ulang tanpa kolom itu.


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
