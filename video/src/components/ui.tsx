import React from 'react';
import {useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT} from '../theme';
import {drift} from '../motion';
import {beatPulse} from '../beats';

/**
 * Latar: Santan dengan dua blob lembut yang bergerak parallax pelan dan ikut
 * berdenyut tipis mengikuti ketukan. Inilah lapisan yang menjamin tidak ada
 * frame yang benar-benar beku, bahkan saat tidak ada yang terjadi di depan.
 */
export const Backdrop: React.FC<{
  tone?: 'light' | 'dark';
  bpm?: number;
  beatOffset?: number;
  /** Detik absolut video, supaya denyutnya nyambung antar scene. */
  absSec?: number;
}> = ({tone = 'light', bpm = 110, beatOffset = 0, absSec}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const sec = absSec ?? frame / fps;
  const pulse = beatPulse(sec, bpm, beatOffset);

  if (tone === 'dark') {
    return (
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `radial-gradient(1400px 900px at ${50 + drift(frame, fps, 14, 6)}% ${
            30 + drift(frame, fps, 17, 5, 0.4)
          }%, ${BC.pandan} 0%, ${BC.daun} 55%, #163927 100%)`,
        }}
      />
    );
  }

  return (
    <div style={{position: 'absolute', inset: 0, background: BC.santan, overflow: 'hidden'}}>
      <div
        style={{
          position: 'absolute',
          width: '58%',
          aspectRatio: '1',
          left: `${-14 + drift(frame, fps, 13, 2.2)}%`,
          top: `${-22 + drift(frame, fps, 16, 2.6, 0.2)}%`,
          borderRadius: '50%',
          background: BC.greenSoft,
          opacity: 0.9,
          transform: `scale(${1 + pulse * 0.012})`,
        }}
      />
      <div
        style={{
          position: 'absolute',
          width: '42%',
          aspectRatio: '1',
          right: `${-12 + drift(frame, fps, 19, 2.4, 0.6)}%`,
          bottom: `${-16 + drift(frame, fps, 15, 2.8, 0.8)}%`,
          borderRadius: '50%',
          background: BC.orangeSoft,
          opacity: 0.75,
          transform: `scale(${1 + pulse * 0.01})`,
        }}
      />
    </div>
  );
};

/** Kartu putih bersudut besar — bentuk dasar UI Beres?. */
export const Card: React.FC<{
  children: React.ReactNode;
  style?: React.CSSProperties;
  pad?: number;
}> = ({children, style, pad = 24}) => (
  <div
    style={{
      background: BC.white,
      borderRadius: 24,
      border: `1px solid ${BC.line}`,
      padding: pad,
      boxShadow: '0 18px 44px rgba(27,42,33,0.08)',
      fontFamily: BODY_FONT,
      ...style,
    }}
  >
    {children}
  </div>
);

/** Chip kecil. */
export const Chip: React.FC<{
  children: React.ReactNode;
  bg?: string;
  color?: string;
  size?: number;
}> = ({children, bg = BC.greenSoft, color = BC.greenText, size = 18}) => (
  <span
    style={{
      display: 'inline-block',
      padding: `${size * 0.4}px ${size * 0.85}px`,
      borderRadius: 999,
      background: bg,
      color,
      fontFamily: BODY_FONT,
      fontWeight: 700,
      fontSize: size,
      whiteSpace: 'nowrap',
    }}
  >
    {children}
  </span>
);
