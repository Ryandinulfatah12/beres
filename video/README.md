# Video penjelasan Beres?

Video 16:9 (1920×1080, 30 fps, ±90 detik) yang memperkenalkan aplikasi **Beres?**
dan menjelaskan alur pemakaiannya. Dibuat dengan [Remotion](https://remotion.dev)
— seluruh gambarnya React, tidak ada aset video atau gambar sama sekali.

```bash
cd video
npm install
npm run dev     # buka Remotion Studio untuk melihat dan mengedit
npm run build   # render ke out/beres-explainer.mp4
```

Kalau `npm run build` gagal dengan "No browser found for rendering frames"
(headless shell bawaan Remotion gagal diekstrak), pakai Chrome yang sudah
terpasang:

```bash
zsh render.sh                       # memakai /Applications/Google Chrome.app
CHROME=/path/ke/chrome zsh render.sh
zsh stills.sh                       # satu frame contoh tiap adegan ke out/
```

## Isi video

| #   | Adegan     | Durasi | Isi                                                           |
| --- | ---------- | ------ | ------------------------------------------------------------- |
| 1   | `title`    | 7 d    | Maskot, nama, tagline, tiga lencana                           |
| 2   | `problem`  | 9 d    | Pertanyaan yang berulang tiap minggu di dapur                 |
| 3   | `loop`     | 10 d   | Alur pemakaian sebagai satu putaran tertutup                  |
| 4   | `week`     | 12 d   | Langkah 1 — menyusun menu tujuh hari                          |
| 5   | `generate` | 13 d   | Langkah 2 — bahan dari semua menu dijumlahkan jadi satu daftar |
| 6   | `shopping` | 12 d   | Langkah 3 — mode belanja: centang, harga, total berjalan      |
| 7   | `done`     | 10 d   | Langkah 4 — perayaan, total per toko, riwayat                 |
| 8   | `offline`  | 9 d    | Tanpa akun, tanpa server, data di perangkat, widget           |
| 9   | `outro`    | 8 d    | Penutup: nama, tagline, ringkasan teknis                      |

Semua teks berbahasa Indonesia, sama seperti UI aplikasinya.

## Struktur

```
src/
  index.ts          registerRoot
  Root.tsx          komposisi BeresExplainer + satu komposisi per adegan
  Main.tsx          merangkai sembilan adegan jadi satu timeline
  theme.ts          palet, huruf, durasi tiap adegan
  fonts.ts          Fredoka + Plus Jakarta Sans
  components/
    Mascot.tsx      Si Beres, port dari lib/widgets/mascot.dart ke SVG
    ui.tsx          Rise, Pop, Card, Phone, Chip, CheckBox, Progress, dll
  scenes/           satu berkas per adegan
```

Mengubah durasi adegan cukup di `SCENES` pada `src/theme.ts`; `TIMELINE` dan
total frame ikut menyesuaikan sendiri.

## Konsistensi dengan aplikasi

- **Palet** disalin dari `BC` di `lib/theme.dart` ke `src/theme.ts`.
- **Si Beres** di `src/components/Mascot.tsx` adalah port langsung dari
  `_MascotPainter` di `lib/widgets/mascot.dart` — koordinat, radius, dan fase
  animasinya dipertahankan di kanvas 120×120, termasuk uap `?` yang berganti
  jadi `✓`, kedipan mata, dan gerakan `bob`/`jump`/`tilt`.
  Di atas latar hijau tua maskot diberi alas bundar warna santan, karena tutup
  pancinya berwarna daun dan akan hilang kalau langsung ditempel di latar gelap.
- **Huruf** sama: Fredoka untuk judul, Plus Jakarta Sans untuk teks.
- Angka contoh di dalam video konsisten antar adegan: tiga menu pada adegan
  `generate` menghasilkan daftar yang sama dengan yang dicentang pada adegan
  `shopping`, dan totalnya (Rp 186.000) sama dengan yang muncul di adegan `done`.
- Klaim "generate ulang aman kapan saja" mengikuti aturan asli di
  `Repo.generateShopping`: item manual dan item yang sudah dicentang tidak
  dihapus.
