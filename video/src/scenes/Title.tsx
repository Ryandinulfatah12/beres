import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT} from '../theme';
import {Mascot} from '../components/Mascot';
import {Backdrop, Body, Rise} from '../components/ui';

/** Adegan 1 — pembuka: maskot, nama aplikasi, dan tagline. */
export const Title: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps, durationInFrames} = useVideoConfig();

  const enter = spring({frame, fps, config: {damping: 13, mass: 0.8, stiffness: 90}});
  const ring = interpolate(frame, [0, 60], [0.6, 1.5], {extrapolateRight: 'clamp'});
  const ringFade = interpolate(frame, [0, 60], [0.5, 0], {extrapolateRight: 'clamp'});
  const out = interpolate(frame, [durationInFrames - 14, durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
  });

  return (
    <div style={{position: 'absolute', inset: 0, opacity: out}}>
      <Backdrop tone="dark" />

      {/* Lingkaran uap yang mengembang di belakang maskot. */}
      <div
        style={{
          position: 'absolute',
          left: 960,
          top: 430,
          width: 520,
          height: 520,
          marginLeft: -260,
          marginTop: -260,
          borderRadius: '50%',
          border: `3px solid ${BC.kunyit}`,
          opacity: ringFade,
          transform: `scale(${ring})`,
        }}
      />

      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 8,
        }}
      >
        {/* Piring santan di belakang maskot: tutup pancinya berwarna daun,
            jadi perlu alas terang supaya terbaca di atas latar hijau tua. */}
        <div
          style={{
            transform: `scale(${0.7 + 0.3 * enter})`,
            opacity: enter,
            background: BC.santan,
            borderRadius: '50%',
            padding: 26,
            display: 'flex',
          }}
        >
          <Mascot size={320} steam="swap" eyes="happy" motion="bob" wave />
        </div>

        <Rise delay={18} distance={34}>
          <div
            style={{
              fontFamily: TITLE_FONT,
              fontSize: 168,
              fontWeight: 600,
              color: BC.white,
              lineHeight: 1,
              letterSpacing: -2,
            }}
          >
            Beres<span style={{color: BC.kunyit}}>?</span>
          </div>
        </Rise>

        <Rise delay={34} distance={24}>
          <Body size={42} tone="dark" style={{marginTop: 18, textAlign: 'center'}}>
            Dari menu sampai belanja, semua beres.
          </Body>
        </Rise>

        <Rise delay={52} distance={18}>
          <div
            style={{
              marginTop: 34,
              display: 'flex',
              gap: 14,
              fontFamily: BODY_FONT,
              fontWeight: 700,
              fontSize: 22,
            }}
          >
            {['Offline', 'Tanpa akun', 'Data di perangkatmu'].map((t) => (
              <span
                key={t}
                style={{
                  padding: '12px 24px',
                  borderRadius: 999,
                  background: 'rgba(255,255,255,0.12)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  color: 'rgba(255,255,255,0.9)',
                }}
              >
                {t}
              </span>
            ))}
          </div>
        </Rise>
      </div>
    </div>
  );
};
