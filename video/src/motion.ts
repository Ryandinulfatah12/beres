import {Easing, interpolate, spring} from 'remotion';

/**
 * Motion system — satu sumber kebenaran untuk semua gerakan di video.
 *
 * Aturannya ada tiga:
 *  1. Semua timing ditulis dalam DETIK lewat `s()`, tidak pernah hardcode frame.
 *  2. Elemen masuk bertumpuk (stagger 3–5 frame, overlap ±40%), tidak antre.
 *  3. Tidak ada bagian yang benar-benar diam lebih dari 0,8 detik — pakai
 *     `livingHold()` atau `drift()` untuk jeda.
 */

/** Detik → frame. Selalu lewat sini, jangan tulis angka frame langsung. */
export const s = (sec: number, fps: number) => Math.round(sec * fps);

/** Spring presets. */
export const SPRING = {
  /** Teks dan kartu masuk — tenang, tanpa pantulan. */
  gentle: {damping: 200},
  /** Tombol, checkbox, chip — cepat dan terasa responsif. */
  snappy: {damping: 18, stiffness: 180, mass: 0.8},
  /** Maskot dan momen perayaan — memantul. */
  bouncy: {damping: 10, stiffness: 120},
} as const;

/** Easing untuk interpolate. */
export const EASE = {
  in: Easing.bezier(0.22, 1, 0.36, 1),
  out: Easing.bezier(0.64, 0, 0.78, 0),
} as const;

const CLAMP = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;

/** `interpolate` dengan clamp dan easing masuk — dipakai di hampir semua tempat. */
export const ease = (
  frame: number,
  range: [number, number],
  out: [number, number],
  easing = EASE.in,
) => interpolate(frame, range, out, {...CLAMP, easing});

/** Nilai 0→1 untuk elemen yang masuk pada detik `at`. */
export const enterAt = (frame: number, fps: number, at: number, preset = SPRING.gentle) =>
  spring({frame: frame - s(at, fps), fps, config: preset});

/**
 * Stagger: elemen ke-`i` mundur 3–5 frame dari sebelumnya.
 * Di 60fps ini 0,05–0,08 detik, dan animasi berikutnya mulai sebelum yang
 * sebelumnya selesai.
 */
export const stagger = (i: number, frames = 4) => i * frames;

/**
 * "Living hold" — gerakan halus yang terus jalan saat tidak ada yang terjadi,
 * supaya tidak pernah ada frame yang benar-benar beku.
 *
 * Mengembalikan skala kamera yang merayap 1.00 → 1.03 selama `over` detik.
 */
export const livingHold = (frame: number, fps: number, over = 6, to = 0.03) =>
  1 + ease(frame, [0, s(over, fps)], [0, to], Easing.linear);

/** Drift sinus pelan untuk blob latar, maskot, dan elemen dekoratif. */
export const drift = (frame: number, fps: number, periodSec: number, amount: number, phase = 0) =>
  Math.sin((frame / (periodSec * fps) + phase) * Math.PI * 2) * amount;

/** Squash & stretch untuk lompatan maskot dan tombol yang ditekan. */
export const squash = (v: number, amount = 0.08) => ({
  scaleX: 1 + amount * v,
  scaleY: 1 - amount * v,
});

/**
 * Angka yang berputar seperti odometer: nilai dari `from` ke `to` dengan
 * easing masuk, dipakai untuk total rupiah dan ringkasan "N hari masak".
 */
export const rollTo = (
  frame: number,
  fps: number,
  at: number,
  dur: number,
  from: number,
  to: number,
) => ease(frame, [s(at, fps), s(at + dur, fps)], [from, to]);

export {CLAMP};
