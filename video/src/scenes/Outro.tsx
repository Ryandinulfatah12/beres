import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT, usePick} from '../theme';
import {CLAMP, drift, EASE, s, SPRING} from '../motion';
import {COPY} from '../copy';
import {snap} from '../beats';
import {Backdrop} from '../components/ui';
import {Kinetic} from '../components/text';
import {Mascot} from '../components/Mascot';
import {SB} from '../theme';

/**
 * Scene 9 — Outro (55–60 dtk).
 *
 * Circle-reveal Pandan menutup babak phone, maskot kuning melambai, wordmark
 * masuk, dan "?" berbalik jadi "✓" tepat di ketukan. Tidak ada fade ke hitam:
 * frame terakhir tetap bergerak (living hold).
 */
export const Outro: React.FC<{cta: string; bpm: number; beatOffset: number}> = ({
  cta,
  bpm,
  beatOffset,
}) => {
  const frame = useCurrentFrame();
  const {fps, width, height} = useVideoConfig();
  const pick = usePick();

  // Reveal berangkat dari posisi terakhir maskot di babak sebelumnya.
  const originX = pick(width * 0.13, width * 0.14);
  const originY = pick(height * 0.76, height * 0.3);
  const revealR = interpolate(
    frame,
    [0, s(0.75, fps)],
    [0, Math.hypot(width, height) * 1.25],
    {...CLAMP, easing: EASE.in},
  );

  // "?" → "✓" di ketukan terdekat dengan detik ke-58 absolut.
  const flipLocal = snap(SB.outro.from + 2.9, bpm, beatOffset) - SB.outro.from;
  const flipT = interpolate(frame, [s(flipLocal, fps), s(flipLocal + 0.45, fps)], [0, 1], {
    ...CLAMP,
    easing: EASE.in,
  });

  const wordmark = COPY.logo.wordmark.split('');
  const mascotIn = spring({
    frame: frame - s(0.5, fps),
    fps,
    config: SPRING.bouncy,
    durationInFrames: s(0.8, fps),
  });

  return (
    <div style={{position: 'absolute', inset: 0}}>
      {/* Latar terang di baliknya, supaya reveal punya sesuatu untuk menutup. */}
      <Backdrop bpm={bpm} beatOffset={beatOffset} />

      <div
        style={{
          position: 'absolute',
          left: originX,
          top: originY,
          width: revealR * 2,
          height: revealR * 2,
          marginLeft: -revealR,
          marginTop: -revealR,
          borderRadius: '50%',
          background: BC.pandan,
        }}
      />

      {/* Isi outro. */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          gap: pick(6, 4),
        }}
      >
        <div
          style={{
            opacity: mascotIn,
            transform: `scale(${0.75 + mascotIn * 0.25}) translateY(${drift(frame, fps, 5, 6)}px)`,
          }}
        >
          <Mascot
            size={pick(230, 200)}
            steam="check"
            eyes="happy"
            motion="bob"
            wave
            body={BC.kunyit}
            dark={BC.kunyitDark}
          />
        </div>

        {/* Wordmark. */}
        <div style={{display: 'flex', alignItems: 'baseline', gap: 2, marginTop: pick(14, 10)}}>
          {wordmark.map((ch, i) => {
            const e = spring({
              frame: frame - s(1.0 + i * 0.05, fps),
              fps,
              config: SPRING.bouncy,
              durationInFrames: s(0.5, fps),
            });
            return (
              <span
                key={`${ch}-${i}`}
                style={{
                  fontFamily: TITLE_FONT,
                  fontSize: pick(132, 108),
                  color: BC.white,
                  opacity: e,
                  transform: `translateY(${(1 - e) * 36}px)`,
                  letterSpacing: -2,
                }}
              >
                {ch}
              </span>
            );
          })}
          <span
            style={{
              position: 'relative',
              width: pick(84, 70),
              height: pick(132, 108),
              display: 'inline-block',
              transformStyle: 'preserve-3d',
              transform: `rotateY(${flipT * 180}deg)`,
              opacity: spring({
                frame: frame - s(1.0 + wordmark.length * 0.05, fps),
                fps,
                config: SPRING.bouncy,
                durationInFrames: s(0.5, fps),
              }),
            }}
          >
            <span
              style={{
                position: 'absolute',
                inset: 0,
                fontFamily: TITLE_FONT,
                fontSize: pick(132, 108),
                color: BC.kunyit,
                backfaceVisibility: 'hidden',
                display: 'flex',
                alignItems: 'baseline',
                justifyContent: 'center',
              }}
            >
              ?
            </span>
            <span
              style={{
                position: 'absolute',
                inset: 0,
                backfaceVisibility: 'hidden',
                transform: 'rotateY(180deg)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <svg width={pick(80, 66)} height={pick(80, 66)} viewBox="0 0 24 24">
                <path
                  d="M4 13 L9.5 18.5 L20 6"
                  stroke={BC.kunyit}
                  strokeWidth={3.6}
                  fill="none"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </span>
          </span>
        </div>

        <div style={{marginTop: pick(18, 14), display: 'flex', justifyContent: 'center'}}>
          <Kinetic
            text={COPY.outro.tagline}
            at={1.6}
            size={pick(36, 30)}
            color="rgba(255,255,255,0.9)"
            font={BODY_FONT}
            weight={600}
            style={{justifyContent: 'center', textAlign: 'center'}}
          />
        </div>

        {/* CTA. */}
        <CtaPill text={cta} at={2.25} />
      </div>
    </div>
  );
};

const CtaPill: React.FC<{text: string; at: number}> = ({text, at}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const pick = usePick();
  const e = spring({
    frame: frame - s(at, fps),
    fps,
    config: SPRING.bouncy,
    durationInFrames: s(0.6, fps),
  });
  // Denyut halus sampai frame terakhir — tidak pernah benar-benar diam.
  const breathe = 1 + Math.sin(frame / (fps * 1.1)) * 0.012;
  return (
    <div
      style={{
        marginTop: pick(30, 24),
        padding: pick('16px 34px', '14px 28px'),
        borderRadius: 999,
        background: BC.kunyit,
        color: BC.daun,
        fontFamily: BODY_FONT,
        fontWeight: 800,
        fontSize: pick(26, 23),
        opacity: Math.min(1, e * 1.3),
        transform: `scale(${(0.86 + e * 0.14) * breathe})`,
        boxShadow: '0 16px 40px rgba(0,0,0,0.25)',
      }}
    >
      {text}
    </div>
  );
};
