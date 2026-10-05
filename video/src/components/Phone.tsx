import React from 'react';
import {spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT} from '../theme';
import {s, SPRING} from '../motion';

/**
 * Ruang desain layar: ukuran asli app (390×844 pt). Semua isi layar ditulis
 * dalam satuan ini, lalu diperbesar mengikuti tinggi phone — jadi teks body
 * tetap seukuran aslinya dan terbaca saat kamera zoom.
 */
export const SCREEN_W = 390;
export const SCREEN_H = 844;

/** Urutan layar di dalam phone; perpindahannya slide horizontal. */
export const SCREENS = ['week', 'list', 'shop', 'history', 'home'] as const;
export type ScreenName = (typeof SCREENS)[number];

export type ScreenSwitch = {at: number; to: ScreenName};

/**
 * Rangka phone. Posisi, skala, dan isi layarnya dikendalikan dari luar supaya
 * satu phone yang sama bisa hidup melintasi beberapa scene tanpa pernah
 * keluar dari layar.
 */
export const PhoneFrame: React.FC<{
  /** Tinggi phone dalam piksel frame. */
  height: number;
  /** Pergeseran dan skala, diatur oleh babak phone. */
  x?: number;
  y?: number;
  scale?: number;
  /** Getaran halus efek haptic saat ada tap. */
  shake?: number;
  children: React.ReactNode;
}> = ({height, x = 0, y = 0, scale = 1, shake = 0, children}) => {
  const screenScale = height / SCREEN_H;
  const bezel = Math.round(height * 0.013);
  const width = Math.round(SCREEN_W * screenScale) + bezel * 2;

  return (
    <div
      style={{
        position: 'absolute',
        left: '50%',
        top: '50%',
        width,
        height: height + bezel * 2,
        marginLeft: -width / 2,
        marginTop: -(height + bezel * 2) / 2,
        transform: `translate(${x + shake}px, ${y}px) scale(${scale})`,
        transformOrigin: 'center center',
        borderRadius: height * 0.062,
        background: BC.arang,
        padding: bezel,
        boxShadow: '0 50px 110px rgba(27,42,33,0.3)',
        willChange: 'transform',
      }}
    >
      <div
        style={{
          width: '100%',
          height: '100%',
          borderRadius: height * 0.05,
          overflow: 'hidden',
          background: BC.santan,
          position: 'relative',
        }}
      >
        {/* Isi layar digambar dalam ruang 390×844 lalu diperbesar. */}
        <div
          style={{
            position: 'absolute',
            left: 0,
            top: 0,
            width: SCREEN_W,
            height: SCREEN_H,
            transform: `scale(${screenScale})`,
            transformOrigin: 'top left',
            fontFamily: BODY_FONT,
          }}
        >
          {children}
        </div>
      </div>
    </div>
  );
};

/**
 * Deretan layar yang digeser horizontal — perpindahan antar layar terasa
 * seperti navigasi di dalam aplikasi, bukan potongan antar scene.
 */
export const ScreenStrip: React.FC<{
  switches: ScreenSwitch[];
  screens: Record<ScreenName, React.ReactNode>;
}> = ({switches, screens}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  // Indeks layar sekarang, dianimasikan dengan spring antar perpindahan.
  let index = SCREENS.indexOf(switches[0]?.to ?? 'week');
  let prevIndex = index;
  let lastAt = 0;
  for (const sw of switches) {
    if (frame >= s(sw.at, fps)) {
      prevIndex = index;
      index = SCREENS.indexOf(sw.to);
      lastAt = sw.at;
    }
  }

  const t =
    lastAt === 0 && frame < s(0.01, fps)
      ? 1
      : spring({
          frame: frame - s(lastAt, fps),
          fps,
          config: SPRING.gentle,
          durationInFrames: s(0.55, fps),
        });
  const pos = prevIndex + (index - prevIndex) * t;

  return (
    <div
      style={{
        position: 'absolute',
        left: 0,
        top: 0,
        width: SCREEN_W * SCREENS.length,
        height: SCREEN_H,
        display: 'flex',
        transform: `translateX(${-pos * SCREEN_W}px)`,
        willChange: 'transform',
      }}
    >
      {SCREENS.map((name) => (
        <div key={name} style={{width: SCREEN_W, height: SCREEN_H, position: 'relative', flexShrink: 0}}>
          {screens[name]}
        </div>
      ))}
    </div>
  );
};

/** Ubah koordinat di dalam layar (ruang 390×844) jadi koordinat frame. */
export const screenToFrame = (
  sx: number,
  sy: number,
  opts: {height: number; x: number; y: number; scale: number; frameW: number; frameH: number},
) => {
  const screenScale = (opts.height / SCREEN_H) * opts.scale;
  const cx = opts.frameW / 2 + opts.x;
  const cy = opts.frameH / 2 + opts.y;
  return {
    x: cx + (sx - SCREEN_W / 2) * screenScale,
    y: cy + (sy - SCREEN_H / 2) * screenScale,
  };
};
