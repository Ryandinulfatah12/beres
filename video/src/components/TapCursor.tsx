import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC} from '../theme';
import {CLAMP, EASE, s, SPRING} from '../motion';

export type Tap = {
  /** Detik saat jari menekan (relatif terhadap awal scene). */
  at: number;
  /** Posisi target dalam koordinat layar scene. */
  x: number;
  y: number;
};

/**
 * Kursor jari — setiap perubahan UI di video harus didahului tap, supaya
 * terlihat seperti ada yang memakai aplikasinya, bukan UI yang berubah sendiri.
 *
 * Jari bergerak ke target dengan spring, menekan (scale 0.85), lalu riak
 * melebar dari titik tekan.
 */
export const TapCursor: React.FC<{taps: Tap[]; size?: number}> = ({taps, size = 64}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  if (!taps.length) return null;

  // Jari berangkat ke target 0,45 detik sebelum menekan.
  const TRAVEL = 0.45;
  const first = taps[0];

  // Target sekarang: tap terakhir yang perjalanannya sudah dimulai.
  let idx = 0;
  for (let i = 0; i < taps.length; i++) {
    if (frame >= s(taps[i].at - TRAVEL, fps)) idx = i;
  }
  const target = taps[idx];
  const prev = idx > 0 ? taps[idx - 1] : first;

  const moveStart = s(target.at - TRAVEL, fps);
  const move = spring({
    frame: frame - moveStart,
    fps,
    config: SPRING.snappy,
    durationInFrames: s(TRAVEL, fps),
  });
  const x = prev.x + (target.x - prev.x) * move;
  const y = prev.y + (target.y - prev.y) * move;

  // Tekan lalu lepas.
  const pressAt = s(target.at, fps);
  const press = interpolate(
    frame,
    [pressAt - s(0.08, fps), pressAt, pressAt + s(0.12, fps)],
    [1, 0.85, 1],
    {...CLAMP, easing: EASE.in},
  );

  // Riak yang melebar sesudah tekan.
  const rippleT = interpolate(frame, [pressAt, pressAt + s(0.5, fps)], [0, 1], CLAMP);
  const showRipple = frame >= pressAt && rippleT < 1;

  // Muncul sedikit sebelum tap pertama, hilang setelah tap terakhir.
  const appear = interpolate(
    frame,
    [s(first.at - TRAVEL - 0.2, fps), s(first.at - TRAVEL, fps)],
    [0, 1],
    CLAMP,
  );
  const last = taps[taps.length - 1];
  const vanish = interpolate(
    frame,
    [s(last.at + 0.6, fps), s(last.at + 0.9, fps)],
    [1, 0],
    CLAMP,
  );
  const opacity = appear * vanish;

  if (opacity <= 0.01) return null;

  return (
    <div style={{position: 'absolute', left: x, top: y, opacity, pointerEvents: 'none'}}>
      {showRipple ? (
        <div
          style={{
            position: 'absolute',
            left: -size * 1.4,
            top: -size * 1.4,
            width: size * 2.8,
            height: size * 2.8,
            borderRadius: '50%',
            border: `3px solid ${BC.daun}`,
            opacity: (1 - rippleT) * 0.5,
            transform: `scale(${0.3 + rippleT * 0.9})`,
          }}
        />
      ) : null}
      <div
        style={{
          position: 'absolute',
          left: -size / 2,
          top: -size / 2,
          width: size,
          height: size,
          borderRadius: '50%',
          background: 'rgba(255,255,255,0.55)',
          border: `3px solid ${BC.daun}`,
          boxShadow: '0 6px 18px rgba(27,42,33,0.25)',
          transform: `scale(${press})`,
        }}
      />
    </div>
  );
};

/** Seberapa "baru saja ditekan" sebuah tap — untuk micro-shake haptic. */
export const tapShake = (frame: number, fps: number, at: number) => {
  const d = frame - s(at, fps);
  if (d < 0 || d > s(0.18, fps)) return 0;
  return Math.sin((d / s(0.18, fps)) * Math.PI * 3) * (1 - d / s(0.18, fps)) * 2;
};
