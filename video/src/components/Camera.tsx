import React from 'react';
import {useCurrentFrame, useVideoConfig} from 'remotion';
import {CameraMotionBlur} from '@remotion/motion-blur';
import {drift, EASE, s} from '../motion';

export type Move = {
  /** Detik (relatif terhadap awal scene) saat kamera sampai di posisi ini. */
  at: number;
  scale?: number;
  x?: number;
  y?: number;
};

/**
 * Kamera scene: zoom dan geser ke area yang sedang dibahas, lalu kembali.
 *
 * Selalu ada gerakan — di luar keyframe pun kamera merayap pelan (living hold),
 * jadi tidak pernah ada frame yang benar-benar beku.
 */
export const Camera: React.FC<{
  moves?: Move[];
  children: React.ReactNode;
  /** Nyalakan motion blur untuk perpindahan kamera yang besar. */
  blur?: boolean;
  /** Kekuatan rayapan living hold. */
  holdAmount?: number;
}> = ({moves = [], children, blur = false, holdAmount = 0.02}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  const keys: Move[] = moves.length ? moves : [{at: 0, scale: 1}];

  // Cari dua keyframe yang mengapit frame sekarang, lalu interpolasi.
  const read = (prop: 'scale' | 'x' | 'y', fallback: number) => {
    const pts = keys.map((k) => ({at: s(k.at, fps), v: k[prop] ?? fallback}));
    if (frame <= pts[0].at) return pts[0].v;
    for (let i = 0; i < pts.length - 1; i++) {
      const a = pts[i];
      const b = pts[i + 1];
      if (frame >= a.at && frame <= b.at) {
        if (b.at === a.at) return b.v;
        const t = EASE.in((frame - a.at) / (b.at - a.at));
        return a.v + (b.v - a.v) * t;
      }
    }
    return pts[pts.length - 1].v;
  };

  // Rayapan pelan + goyangan sangat halus supaya tiap frame tetap berubah.
  const hold = 1 + (frame / (s(10, fps) || 1)) * holdAmount;
  const scale = read('scale', 1) * hold;
  const x = read('x', 0) + drift(frame, fps, 9, 5);
  const y = read('y', 0) + drift(frame, fps, 11, 4, 0.3);

  const inner = (
    <div
      style={{
        position: 'absolute',
        inset: 0,
        transform: `scale(${scale}) translate(${x}px, ${y}px)`,
        transformOrigin: 'center center',
        willChange: 'transform',
      }}
    >
      {children}
    </div>
  );

  if (!blur) return inner;
  return (
    <CameraMotionBlur samples={6} shutterAngle={180}>
      {inner}
    </CameraMotionBlur>
  );
};
