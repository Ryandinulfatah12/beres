# Video penjelasan Beres?

Video **60 detik, 60 fps** yang memperkenalkan aplikasi **Beres?** dan
menjelaskan alur pemakaiannya. Audiensnya para pengelola dapur, bukan
developer. Dibuat dengan [Remotion](https://remotion.dev) — seluruh gambarnya
React, tanpa satu pun aset video atau gambar.

Dua komposisi, scene-nya sama, tata letaknya menyesuaikan orientasi:

| Komposisi         | Ukuran    |
| ----------------- | --------- |
| `BeresLandscape`  | 1920×1080 |
| `BeresVertical`   | 1080×1920 |

```bash
cd video
npm install
npm run dev              # Remotion Studio
npm run build            # landscape final (crf 18)
npm run build:vertical   # vertical final
npm run draft            # draft cepat untuk quality check
```

Kalau `npm run build` gagal dengan "No browser found for rendering frames"
(headless shell bawaan Remotion gagal diekstrak), pakai Chrome yang terpasang:

```bash
zsh render.sh            # landscape
zsh render.sh vertical   # vertical
zsh render.sh draft      # draft (scale 0.5)
zsh stills.sh            # still di 9 detik kunci -> out/still/
```

## Props

Diatur dari Remotion Studio atau lewat `--props`:

| Prop         | Default                 | Pengaruh                                                      |
| ------------ | ----------------------- | ------------------------------------------------------------- |
| `audience`   | `"pengguna"`            | `"developer"` menambah kartu teknis + chip di bagian riwayat   |
| `cta`        | `"Segera di Play Store"`| Teks tombol di outro                                           |
| `musicSrc`   | `""`                    | Nama file musik di `public/` (kosong = tanpa musik)            |
| `sfx`        | `{}`                    | `{pop, tap, whoosh, ting, confetti}` → nama file di `public/`  |
| `bpm`        | `110`                   | Momen kunci di-snap ke ketukan ini                             |
| `beatOffset` | `0`                     | Geser ketukan kalau musiknya tidak mulai di detik 0            |

Audio **opsional**: tanpa file apa pun, komposisi tetap dirender tanpa error —
videonya hanya jadi tanpa suara. Irama gerakannya sudah mengikuti `bpm`, jadi
begitu musik 110 BPM dipasang, gerakannya langsung nyambung.

```bash
npx remotion render BeresLandscape out/v.mp4 \
  --props='{"musicSrc":"music.mp3","sfx":{"pop":"sfx/pop.mp3","tap":"sfx/tap.mp3"}}'
```

## Storyboard

| Scene | Detik   | Isi                                                     | Momen yang di-snap ke ketukan              |
| ----- | ------- | ------------------------------------------------------- | ------------------------------------------ |
| 1     | 0–5     | Gelembung chat menumpuk, headline kinetic, maskot mengintip | 4 gelembung muncul (1,0 / 1,9 / 2,6 / 3,2) |
| 2     | 5–9     | Gelembung tersedot ke panci, "?"→"✓", wordmark per huruf | sedotan (5,0) · flip "?"→"✓" (7,3)          |
| 3     | 9–14    | Lingkaran siklus digambar, 4 node, kamera menembus node 1 | 4 node pop (0,75 / 1,3 / 1,85 / 2,4)       |
| 4     | 14–24   | Susun menu: bottom sheet, pilih 2 menu, matikan hari     | —                                           |
| 5     | 24–34   | Bahan terbang dari 3 kartu menu, angka berputar, filter  | 5 chip mendarat (tiap 1,0 dtk)             |
| 6     | 34–44   | Mode belanja: centang, harga terketik, total odometer    | 5 centang (20,9 / 22,2 / 23,5 / 24,8 / 26,1) |
| 7     | 44–50   | Confetti meledak dari tombol, maskot melompat, total     | ledakan confetti (tap Selesai)             |
| 8     | 50–55   | Riwayat, "Salin ke minggu ini", widget home screen       | widget pop                                  |
| 9     | 55–60   | Circle-reveal, maskot melambai, "?"→"✓", CTA             | flip "?"→"✓" (57,8)                         |

Detik di kolom "momen" bersifat relatif terhadap awal scene, kecuali scene 6
yang relatif terhadap awal babak phone (detik 14).

## Struktur

```
src/
  index.ts          registerRoot
  Root.tsx          BeresLandscape + BeresVertical
  Main.tsx          tiga babak + daftar cue SFX
  theme.ts          palet, huruf, storyboard (detik), helper orientasi
  motion.ts         spring preset, easing, stagger, living hold
  copy.ts           semua teks + data contoh
  beats.ts          ketukan: snap(), beatSeq(), beatPulse()
  fonts.ts          Fredoka + Plus Jakarta Sans
  components/
    Mascot.tsx      Si Beres, port dari lib/widgets/mascot.dart
    Guide.tsx       maskot sebagai pemandu, berpindah lewat lintasan melengkung
    Phone.tsx       rangka phone + strip layar yang slide horizontal
    screens.tsx     5 layar app dalam ruang 390×844 (ukuran asli)
    Camera.tsx      zoom/geser per scene + living hold
    TapCursor.tsx   kursor jari: gerak, tekan, riak
    text.tsx        teks kinetik, angka odometer, toast
    ui.tsx          latar blob yang bergerak, kartu, chip
    Sound.tsx       musik + SFX (semuanya opsional)
  scenes/
    Open.tsx        scene 1–2 (satu bidikan, tanpa potongan)
    Cycle.tsx       scene 3
    PhoneAct.tsx    scene 4–8 (satu phone sebagai shared element)
    Outro.tsx       scene 9
tools/
  freezecheck.mjs   pengecekan "tidak pernah diam"
```

Menggeser durasi scene cukup di `SB` pada `src/theme.ts` — semuanya dalam detik.

## Prinsip yang dipakai

**Tidak pernah diam.** Tiap frame punya minimal satu gerakan: blob latar
melayang dan berdenyut mengikuti ketukan, kamera merayap pelan (living hold),
maskot bernapas dan berkedip. Dicek otomatis, lihat bawah.

**Tanpa fade ke latar pucat.** Perpindahan memakai wipe, circle-reveal warna
Pandan dari posisi maskot, dan zoom-through kamera. Scene 1→2 bahkan tidak
punya potongan sama sekali: gelembungnya tersedot masuk ke panci.

**Phone sebagai shared element.** Satu `PhoneFrame` hidup dari detik 14 sampai
55 dan tidak pernah keluar layar. Yang berganti isi layarnya (slide horizontal
seperti navigasi app); phone-nya sendiri bergeser dan di-zoom.

**Setiap perubahan UI didahului tap.** `TapCursor` bergerak ke target, menekan,
lalu riak melebar — dan phone-nya bergetar halus (haptic). Tidak ada UI yang
berubah sendiri.

**Ukuran UI asli.** Isi layar digambar dalam ruang 390×844 pt lalu diperbesar
mengikuti tinggi phone (88% frame di landscape), jadi teksnya terbaca saat
kamera zoom.

**Si Beres memandu.** Maskot muncul di setiap scene, bereaksi terhadap yang
sedang dibahas, dan berpindah antar posisi lewat lintasan melengkung.

## Quality check

```bash
zsh render.sh draft
rm -rf out/fr && mkdir -p out/fr
npx remotion ffmpeg -y -i out/draft.mp4 -an -s 320x180 out/fr/%05d.png
node tools/freezecheck.mjs out/fr 60 0.8
```

Catatan: spec aslinya memakai `ffmpeg -vf freezedetect`, tapi ffmpeg yang
dibundel Remotion hanya membawa 50 filter (tanpa `freezedetect`) dan tanpa
muxer `rawvideo`, sementara mesin ini tidak punya ffmpeg sistem. Jadi
`tools/freezecheck.mjs` mengerjakan hal yang sama dengan cara lain: tiap frame
diekstrak sebagai PNG lossless lalu dibandingkan byte per byte. Dua frame
dengan byte identik berarti pikselnya benar-benar sama. Pengecekan ini justru
**lebih ketat** daripada freezedetect bertoleransi — perubahan satu piksel pun
sudah dihitung sebagai gerakan.

Hasil terakhir: **lulus**, diam terpanjang 0,33 detik (detik 55,18, saat
circle-reveal menutup layar) dari batas 0,8 detik.

## Konsistensi dengan aplikasi

- **Palet** disalin dari `BC` di `lib/theme.dart`.
- **Si Beres** di `src/components/Mascot.tsx` adalah port langsung dari
  `_MascotPainter` (`lib/widgets/mascot.dart`) ke SVG — koordinat, radius, dan
  fase animasinya dipertahankan dalam kanvas 120×120. Di atas latar hijau tua
  ia dipakai varian kuning atau diberi alas santan, karena tutup pancinya
  berwarna daun dan akan hilang kalau ditempel langsung di latar gelap.
- **Huruf** sama: Fredoka untuk judul, Plus Jakarta Sans untuk teks.
- **Angka contoh konsisten lintas scene**: tiga menu di scene 5 menghasilkan
  daftar yang sama dengan yang dicentang di scene 6, dan jumlah harganya
  (Rp 73.500) sama persis dengan total per toko di scene 7 — Pasar Rp 31.500 +
  Super Indo Rp 42.000.
