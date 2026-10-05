/**
 * Semua teks video ada di sini.
 *
 * Aturan: headline maksimal 5 kata, subjudul maksimal 12 kata, tanpa paragraf
 * dan tanpa jargon teknis untuk audiens "pengguna" (para pengelola dapur).
 */

export type Audience = 'pengguna' | 'developer';

export const COPY = {
  /** 1. Hook */
  hook: {
    headline: 'Tiap minggu, pertanyaannya sama.',
    bubbles: [
      'Hari ini masak apa?',
      'Bahannya apa aja ya?',
      'Telur udah dibeli belum?',
      'Kemarin beli di toko mana?',
    ],
  },

  /** 2. Logo */
  logo: {
    wordmark: 'Beres',
    tagline: 'Dari menu sampai belanja, semua beres.',
  },

  /** 3. Siklus */
  cycle: {
    headline: 'Satu putaran, tiap minggu.',
    nodes: [
      {label: 'Susun menu', sub: 'seminggu sekali'},
      {label: 'Buat daftar', sub: 'otomatis dari menu'},
      {label: 'Belanja', sub: 'centang + harga'},
      {label: 'Riwayat', sub: 'tahu habis berapa'},
    ],
  },

  /** 4. Susun menu */
  plan: {
    headline: 'Susun menu seminggu.',
    sub: 'Pilih lauk dan cemilan, satu kali duduk.',
    toast: 'Sabtu sudah terisi',
  },

  /** 5. Bahan dijumlahkan */
  merge: {
    headline: 'Bahan dijumlahkan sendiri.',
    sub: 'Dipakai tiga menu? Jadi satu baris.',
  },

  /** 6. Mode belanja */
  shop: {
    headline: 'Centang sambil belanja.',
    sub: 'Harga masuk, total jalan sendiri.',
  },

  /** 7. Perayaan */
  done: {
    headline: 'Belanja beres!',
    sub: 'Kerja bagus, Bunda.',
  },

  /** 8. Riwayat dan widget */
  history: {
    headline: 'Minggu depan tinggal salin.',
    sub: 'Menu favorit dipakai lagi sekali ketuk.',
    toast: 'Menu disalin',
    widget: 'Menu hari ini, langsung di layar home.',
    /** Hanya tampil kalau audience = "developer". */
    devCards: [
      {title: 'Tanpa akun', body: 'Buka, langsung pakai.'},
      {title: 'Tanpa server', body: 'Offline sepenuhnya.'},
      {title: 'Data di perangkat', body: 'SQLite lokal, bisa dicadangkan.'},
    ],
    devChips: ['Flutter', 'SQLite', 'Android · iOS', 'MIT'],
  },

  /** 9. Outro */
  outro: {
    tagline: 'Dari menu sampai belanja, semua beres.',
    defaultCta: 'Segera di Play Store',
  },
} as const;

export type DayPlan = {
  day: string;
  items: string[];
  on: boolean;
  today?: boolean;
};

/** Rencana tujuh hari yang tampil di layar Minggu Ini. */
const DAYS: DayPlan[] = [
  {day: 'Senin', items: ['Ayam goreng', 'Tumis kangkung'], on: true},
  {day: 'Selasa', items: ['Capcay', 'Rolade'], on: true},
  {day: 'Rabu', items: ['Soto ayam', 'Risol'], on: true, today: true},
  {day: 'Kamis', items: ['Ikan bakar'], on: true},
  {day: 'Jumat', items: ['Sayur asem', 'Bakwan'], on: true},
  {day: 'Sabtu', items: [], on: true},
  {day: 'Minggu', items: [], on: true},
];

/** Data contoh yang dipakai lintas scene — angkanya harus tetap konsisten. */
export const DATA = {
  weekRange: '6 – 12 Okt',

  days: DAYS,

  /** Menu yang ditambahkan lewat bottom sheet di scene 4. */
  sheetPicks: ['Sate taichan', 'Es buah'],

  /** 5 → 6 hari masak setelah Sabtu terisi, lalu Minggu dimatikan. */
  summary: {before: 5, after: 6},

  /** Tiga menu yang bahannya dijumlahkan di scene 5. */
  dishes: [
    {name: 'Ayam goreng', items: ['Dada ayam 500 gr', 'Bawang merah 3 siung']},
    {name: 'Soto ayam', items: ['Dada ayam 500 gr', 'Bawang merah 5 siung']},
    {name: 'Capcay', items: ['Bawang merah 3 siung', 'Telur 8 butir']},
  ],

  /** Hasil generate — urutannya sama dengan yang dicentang di scene 6. */
  list: [
    {name: 'Dada ayam', from: 500, to: 1000, unit: 'gr', toko: 'Super Indo', cara: 'Eceran'},
    {name: 'Bawang merah', from: 3, to: 11, unit: 'siung', toko: 'Pasar', cara: 'Eceran'},
    {name: 'Telur', from: 8, to: 8, unit: 'butir', toko: 'Pasar', cara: 'Grosir'},
    {name: 'Wortel', from: 2, to: 2, unit: 'buah', toko: 'Super Indo', cara: 'Eceran'},
    {name: 'Kunyit', from: 2, to: 2, unit: 'cm', toko: 'Pasar', cara: 'Eceran'},
  ],

  /** Harga yang diketik satu per satu di mode belanja. */
  prices: [38000, 7500, 22000, 4000, 2000],

  stores: [
    {name: 'Pasar', total: 31500},
    {name: 'Super Indo', total: 42000},
  ],
  /** = jumlah `prices`, dan = jumlah `stores`. */
  grandTotal: 73500,

  history: [
    {range: '22 – 28 Sep', info: '4 hari masak', total: 'Rp 68.000'},
    {range: '15 – 21 Sep', info: '5 hari masak', total: 'Rp 81.500'},
  ],
} as const;
