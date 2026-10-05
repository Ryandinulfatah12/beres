import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT} from '../theme';
import {Mascot} from '../components/Mascot';
import {Backdrop, Body, Rise} from '../components/ui';

const BADGES = ['Flutter 3.27+', 'Android · iOS', 'Lisensi MIT', 'Offline'];

/** Adegan 9 — penutup: nama, tagline, dan ringkasan teknis. */
export const Outro: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const enter = spring({frame, fps, config: {damping: 14, mass: 0.8, stiffness: 90}});

  return (
    <div style={{position: 'absolute', inset: 0}}>
      <Backdrop tone="dark" />

      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <div
          style={{
            opacity: enter,
            transform: `scale(${0.8 + 0.2 * enter})`,
            background: BC.santan,
            borderRadius: '50%',
            padding: 22,
            display: 'flex',
          }}
        >
          <Mascot size={260} steam="check" eyes="happy" motion="bob" />
        </div>

        <Rise delay={14}>
          <div
            style={{
              fontFamily: TITLE_FONT,
              fontSize: 132,
              color: BC.white,
              lineHeight: 1,
              marginTop: 10,
              letterSpacing: -2,
            }}
          >
            Beres<span style={{color: BC.kunyit}}>?</span>
          </div>
        </Rise>

        <Rise delay={26}>
          <Body size={40} tone="dark" style={{marginTop: 22, textAlign: 'center'}}>
            Dari menu sampai belanja, semua beres.
          </Body>
        </Rise>

        <Rise delay={42}>
          <div
            style={{
              marginTop: 44,
              display: 'flex',
              gap: 14,
              fontFamily: BODY_FONT,
              fontWeight: 700,
              fontSize: 22,
            }}
          >
            {BADGES.map((b) => (
              <span
                key={b}
                style={{
                  padding: '13px 26px',
                  borderRadius: 999,
                  border: `1px solid ${BC.kunyit}`,
                  color: BC.kunyit,
                }}
              >
                {b}
              </span>
            ))}
          </div>
        </Rise>

        <Rise delay={58}>
          <div
            style={{
              marginTop: 48,
              fontFamily: BODY_FONT,
              fontSize: 26,
              color: 'rgba(255,255,255,0.6)',
            }}
          >
            flutter pub get · flutter run
          </div>
        </Rise>
      </div>

      {/* Fade keluar ke arang di akhir. */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: BC.arang,
          opacity: interpolate(frame, [200, 240], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          }),
        }}
      />
    </div>
  );
};
