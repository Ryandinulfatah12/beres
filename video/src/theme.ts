import {useVideoConfig} from 'remotion';
import {s as toFrames} from './motion';

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

export const TITLE_FONT = '"Fredoka", "Plus Jakarta Sans", system-ui, sans-serif';
export const BODY_FONT = '"Plus Jakarta Sans", system-ui, sans-serif';

/** 60 fps supaya gerakannya halus. */
export const FPS = 60;
export const DURATION_SEC = 60;

export const LANDSCAPE = {width: 1920, height: 1080} as const;
export const VERTICAL = {width: 1080, height: 1920} as const;

/**
 * Storyboard dalam detik. Semua scene membaca mulai/selesainya dari sini,
 * jadi menggeser satu scene tidak membuat yang lain meleset.
 */
export const SB = {
  hook: {from: 0, to: 5},
  logo: {from: 5, to: 9},
  cycle: {from: 9, to: 14},
  plan: {from: 14, to: 24},
  merge: {from: 24, to: 34},
  shop: {from: 34, to: 44},
  done: {from: 44, to: 50},
  history: {from: 50, to: 55},
  outro: {from: 55, to: 60},
} as const;

export type SceneName = keyof typeof SB;

/** Tiga babak: pembuka, babak phone (shared element), penutup. */
export const ACT = {
  /** Scene 1–3, dirangkai dengan transisi slide/wipe. */
  intro: {from: SB.hook.from, to: SB.cycle.to},
  /** Scene 4–8 — satu phone yang tidak pernah keluar layar. */
  phone: {from: SB.plan.from, to: SB.history.to},
  /** Scene 9. */
  outro: {from: SB.outro.from, to: SB.outro.to},
} as const;

/** Lama transisi antar scene di babak pembuka. */
export const TRANSITION_SEC = 0.6;

/** Helper detik → frame yang sudah tahu fps komposisi ini. */
export const useS = () => {
  const {fps} = useVideoConfig();
  return (sec: number) => toFrames(sec, fps);
};

/** Orientasi komposisi — scene-nya sama, tata letaknya menyesuaikan. */
export type Layout = 'landscape' | 'vertical';

export const useLayout = (): Layout => {
  const {width, height} = useVideoConfig();
  return height > width ? 'vertical' : 'landscape';
};

/** Pilih nilai berdasarkan orientasi, supaya scene tidak penuh percabangan. */
export const usePick = () => {
  const layout = useLayout();
  return <T,>(landscape: T, vertical: T): T => (layout === 'vertical' ? vertical : landscape);
};

export const TOTAL_FRAMES = Math.round(DURATION_SEC * FPS);
