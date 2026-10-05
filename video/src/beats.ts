/**
 * Ketukan musik.
 *
 * Momen kunci video (gelembung chat, node siklus, centang, "?"→"✓") di-snap ke
 * ketukan terdekat supaya gerakannya terasa menyatu dengan musik. Kalau musik
 * tidak dipasang, angka-angka ini tetap dipakai sebagai irama dasar — videonya
 * tetap terasa berdetak.
 */

export const DEFAULT_BPM = 110;

/** Jarak antar ketukan dalam detik. */
export const beatLen = (bpm: number = DEFAULT_BPM) => 60 / bpm;

/** Daftar detik ketukan sepanjang `durationSec`. */
export const beatTimes = (
  durationSec: number,
  bpm: number = DEFAULT_BPM,
  offset = 0,
): number[] => {
  const len = beatLen(bpm);
  const out: number[] = [];
  for (let t = offset; t < durationSec; t += len) out.push(Number(t.toFixed(4)));
  return out;
};

/** Bulatkan sebuah detik ke ketukan terdekat. */
export const snap = (sec: number, bpm: number = DEFAULT_BPM, offset = 0): number => {
  const len = beatLen(bpm);
  return Number((Math.round((sec - offset) / len) * len + offset).toFixed(4));
};

/** Snap sederetan detik sekaligus — dipakai untuk urutan centang dan chip. */
export const snapAll = (secs: number[], bpm: number = DEFAULT_BPM, offset = 0): number[] =>
  secs.map((t) => snap(t, bpm, offset));

/**
 * Deret ketukan mulai dari `start`, sebanyak `count`, dengan jarak `every`
 * ketukan. Dipakai untuk gelembung chat yang makin menumpuk dan untuk urutan
 * centang di mode belanja.
 */
export const beatSeq = (
  start: number,
  count: number,
  every = 1,
  bpm: number = DEFAULT_BPM,
  offset = 0,
): number[] => {
  const len = beatLen(bpm) * every;
  return Array.from({length: count}, (_, i) => snap(start + i * len, bpm, offset));
};

/**
 * Seberapa dekat frame ini dengan ketukan (1 tepat di ketukan, 0 di tengah).
 * Dipakai untuk denyut halus pada elemen latar supaya ikut bernapas.
 */
export const beatPulse = (
  sec: number,
  bpm: number = DEFAULT_BPM,
  offset = 0,
): number => {
  const len = beatLen(bpm);
  const phase = ((sec - offset) % len + len) % len;
  return Math.max(0, 1 - phase / (len * 0.5));
};
