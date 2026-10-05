/**
 * Palet dapur Beres? — disalin dari `lib/theme.dart` (class BC) supaya
 * videonya memakai warna yang sama persis dengan aplikasinya.
 */
export const BC = {
  pandan: '#2E6A4C',
  daun: '#1F4D36',
  kunyit: '#F5C24C',
  kunyitDark: '#D9A22E',
  cabai: '#C8622A',
  santan: '#F3F5F1',
  arang: '#1B2A21',
  muted: '#56645A',
  line: '#E1E6DF',
  lineSoft: '#EEF1EC',
  greenSoft: '#E3EFE7',
  greenText: '#245A3F',
  orangeSoft: '#FBEBDD',
  orangeText: '#8F4318',
  steam: '#A9C4B2',
  blush: '#F2A27A',
  pill: '#E4E9E2',
  white: '#FFFFFF',
} as const;

/** Fredoka untuk judul, Plus Jakarta Sans untuk teks — seperti di aplikasi. */
export const TITLE_FONT = '"Fredoka", "Plus Jakarta Sans", system-ui, sans-serif';
export const BODY_FONT = '"Plus Jakarta Sans", system-ui, sans-serif';

export const FPS = 30;
export const WIDTH = 1920;
export const HEIGHT = 1080;

/** Durasi tiap adegan dalam detik, dipakai juga oleh Root untuk total frame. */
export const SCENES = {
  title: 7,
  problem: 9,
  loop: 10,
  week: 12,
  generate: 13,
  shopping: 12,
  done: 10,
  offline: 9,
  outro: 8,
} as const;

export const sec = (s: number) => Math.round(s * FPS);

export type SceneName = keyof typeof SCENES;

/** Urutan adegan dan frame mulainya. */
export const TIMELINE: {name: SceneName; from: number; durationInFrames: number}[] = (() => {
  let cursor = 0;
  return (Object.keys(SCENES) as SceneName[]).map((name) => {
    const durationInFrames = sec(SCENES[name]);
    const from = cursor;
    cursor += durationInFrames;
    return {name, from, durationInFrames};
  });
})();

export const TOTAL_FRAMES = TIMELINE.reduce((n, s) => n + s.durationInFrames, 0);
