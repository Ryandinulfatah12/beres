import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {CameraMotionBlur} from '@remotion/motion-blur';
import {BC, BODY_FONT, TITLE_FONT, usePick} from '../theme';
import {CLAMP, drift, EASE, s, SPRING} from '../motion';
import {COPY} from '../copy';
import {beatSeq, snap} from '../beats';
import {Backdrop} from '../components/ui';
import {Camera} from '../components/Camera';
import {Kinetic} from '../components/text';
import {Mascot} from '../components/Mascot';

/**
 * Scene 1–2 — Hook dan Logo (0–9 dtk), satu bidikan tanpa potongan.
 *
 * Gelembung chat bermunculan mengikuti ketukan dan menumpuk miring, lalu
 * tersedot masuk ke panci Si Beres (spiral + mengecil, dengan motion blur).
 * Tutup menutup dengan pantulan, uap "?" berubah jadi "✓", lalu circle-reveal
 * Pandan membawa wordmark masuk per huruf.
 */

/** Motion blur hanya dipasang saat benar-benar ada gerakan besar. */
const MaybeBlur: React.FC<{on: boolean; children: React.ReactNode}> = ({on, children}) =>
  on ? (
    <CameraMotionBlur samples={6} shutterAngle={180}>
      {children}
    </CameraMotionBlur>
  ) : (
    <>{children}</>
  );

/** Waktu kunci scene ini, dalam detik lokal. */
const K = {
  suck: 5.0,
  lid: 5.5,
  reveal: 5.75,
  wordmark: 6.15,
  flip: 7.3,
  tagline: 7.55,
} as const;

export const Open: React.FC<{bpm: number; beatOffset: number}> = ({bpm, beatOffset}) => {
  const frame = useCurrentFrame();
  const {fps, width, height} = useVideoConfig();
  const pick = usePick();

  // Gelembung muncul makin rapat: 2 ketukan, 1,5, lalu 1.
  const times = [1.0, 1.9, 2.6, 3.2].map((t) => snap(t, bpm, beatOffset));
  const suck = snap(K.suck, bpm, beatOffset);
  const flip = snap(K.flip, bpm, beatOffset);

  const bubbleArea = pick(
    {left: width * 0.52, top: height * 0.12, w: width * 0.42},
    {left: width * 0.07, top: height * 0.42, w: width * 0.86},
  );
  const spots = pick(
    [
      {x: 0.04, y: 0.0, rot: -3},
      {x: 0.26, y: 0.17, rot: 2.5},
      {x: 0.0, y: 0.35, rot: -2},
      {x: 0.2, y: 0.53, rot: 3},
    ],
    [
      {x: 0.0, y: 0.0, rot: -3},
      {x: 0.22, y: 0.14, rot: 2.5},
      {x: 0.02, y: 0.28, rot: -2},
      {x: 0.18, y: 0.42, rot: 3},
    ],
  );

  // Posisi maskot: mengintip di bawah, lalu melompat ke tengah.
  const peekX = pick(width * 0.26, width * 0.5);
  const peekY = pick(height * 0.86, height * 0.88);
  const centerX = width * 0.5;
  const centerY = pick(height * 0.38, height * 0.36);

  const jump = spring({
    frame: frame - s(suck - 0.55, fps),
    fps,
    config: SPRING.bouncy,
    durationInFrames: s(0.75, fps),
  });
  const mx = peekX + (centerX - peekX) * jump;
  const my = peekY + (centerY - peekY) * jump - Math.sin(Math.PI * Math.min(1, jump)) * 70;
  const mSize = pick(230, 220) + pick(90, 80) * jump;

  // Panci "membuka tutup" saat menyedot, lalu menutup dengan pantulan.
  const lidOpen = interpolate(
    frame,
    [s(suck - 0.3, fps), s(suck, fps), s(K.lid, fps), s(K.lid + 0.35, fps)],
    [0, 1, 1, 0],
    {...CLAMP, easing: EASE.in},
  );

  // Reveal Pandan melebar dari posisi maskot.
  const revealR = interpolate(
    frame,
    [s(K.reveal, fps), s(K.reveal + 0.75, fps)],
    [0, Math.hypot(width, height) * 1.1],
    {...CLAMP, easing: EASE.in},
  );
  const onPandan = frame >= s(K.reveal + 0.2, fps);

  const wordmark = COPY.logo.wordmark.split('');
  const flipT = interpolate(frame, [s(flip, fps), s(flip + 0.45, fps)], [0, 1], {
    ...CLAMP,
    easing: EASE.in,
  });

  return (
    <div style={{position: 'absolute', inset: 0}}>
      <Backdrop bpm={bpm} beatOffset={beatOffset} />

      <Camera moves={[{at: 0, scale: 1.04}, {at: 4.6, scale: 1.0}]} holdAmount={0.008}>
        {/* Headline, keluar tepat sebelum gelembung tersedot. */}
        <div
          style={{
            position: 'absolute',
            left: width * 0.07,
            top: pick(height * 0.34, height * 0.14),
            width: pick(width * 0.4, width * 0.86),
          }}
        >
          <Kinetic
            text={COPY.hook.headline}
            at={0.35}
            out={suck - 0.5}
            size={pick(84, 76)}
            style={{letterSpacing: -1}}
          />
        </div>

        {/* Gelembung: muncul mengikuti ketukan, lalu tersedot spiral ke panci. */}
        <MaybeBlur on={frame >= s(suck - 0.1, fps) && frame <= s(suck + 0.9, fps)}>
          {COPY.hook.bubbles.map((text, i) => {
            const e = spring({
              frame: frame - s(times[i], fps),
              fps,
              config: SPRING.snappy,
              durationInFrames: s(0.4, fps),
            });
            const spot = spots[i];
            const bx = bubbleArea.left + spot.x * bubbleArea.w;
            const by = bubbleArea.top + spot.y * height * pick(1, 0.78);
            const float = drift(frame, fps, 4 + i * 0.6, 5, i * 0.25);

            // Tersedot: lintasan spiral menuju mulut panci.
            const sIn = interpolate(
              frame,
              [s(suck + i * 0.07, fps), s(suck + 0.55 + i * 0.07, fps)],
              [0, 1],
              {...CLAMP, easing: EASE.in},
            );
            const ang = sIn * Math.PI * 1.6;
            const rad = 1 - sIn;
            const tx = centerX + (bx - centerX) * rad * Math.cos(ang) - 160 * rad * Math.sin(ang);
            const ty = centerY - mSize * 0.22 + (by - centerY) * rad * Math.cos(ang);

            return (
              <div
                key={text}
                style={{
                  position: 'absolute',
                  left: sIn > 0 ? tx : bx,
                  top: (sIn > 0 ? ty : by) + float * (1 - sIn),
                  opacity: e * (1 - sIn * 0.9),
                  transform: `scale(${(0.86 + e * 0.14) * (1 - sIn)}) rotate(${
                    spot.rot + sIn * 180
                  }deg)`,
                  transformOrigin: 'left center',
                }}
              >
                <div
                  style={{
                    padding: '20px 30px',
                    background: BC.white,
                    borderRadius: '26px 26px 26px 8px',
                    border: `1px solid ${BC.line}`,
                    boxShadow: '0 16px 36px rgba(27,42,33,0.1)',
                    fontFamily: BODY_FONT,
                    fontWeight: 600,
                    fontSize: pick(34, 32),
                    color: BC.arang,
                    whiteSpace: 'nowrap',
                  }}
                >
                  {text}
                </div>
              </div>
            );
          })}
        </MaybeBlur>
      </Camera>

      {/* Circle-reveal Pandan, melebar dari posisi maskot. */}
      <div
        style={{
          position: 'absolute',
          left: centerX,
          top: centerY,
          width: revealR * 2,
          height: revealR * 2,
          marginLeft: -revealR,
          marginTop: -revealR,
          borderRadius: '50%',
          background: BC.pandan,
        }}
      />

      {/* Maskot: melompat ke tengah, tutupnya terangkat saat menyedot. */}
      <div
        style={{
          position: 'absolute',
          left: mx,
          top: my,
          transform: 'translate(-50%, -50%)',
        }}
      >
        {/* Tutup terangkat terpisah dari badan. */}
        <div
          style={{
            position: 'absolute',
            left: '50%',
            top: `${8 - lidOpen * 16}%`,
            width: mSize * 0.66,
            height: mSize * 0.1,
            marginLeft: -(mSize * 0.33),
            borderRadius: 999,
            background: onPandan ? BC.kunyitDark : BC.daun,
            opacity: lidOpen,
            transform: `rotate(${lidOpen * -8}deg)`,
          }}
        />
        <Mascot
          size={mSize}
          steam={frame >= s(K.lid, fps) ? 'check' : 'question'}
          eyes={frame >= s(K.lid, fps) ? 'happy' : 'up'}
          motion={frame >= s(K.lid, fps) ? 'bob' : 'bob'}
          body={onPandan ? BC.kunyit : BC.pandan}
          dark={onPandan ? BC.kunyitDark : BC.daun}
        />
      </div>

      {/* Wordmark masuk per huruf, "?" berbalik jadi "✓". */}
      <div
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          top: pick(height * 0.62, height * 0.58),
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'baseline',
          gap: 2,
        }}
      >
        {wordmark.map((ch, i) => {
          const e = spring({
            frame: frame - s(K.wordmark + i * 0.055, fps),
            fps,
            config: SPRING.bouncy,
            durationInFrames: s(0.5, fps),
          });
          return (
            <span
              key={`${ch}-${i}`}
              style={{
                fontFamily: TITLE_FONT,
                fontSize: pick(150, 120),
                color: BC.white,
                opacity: e,
                transform: `translateY(${(1 - e) * 40}px)`,
                letterSpacing: -2,
              }}
            >
              {ch}
            </span>
          );
        })}
        {/* "?" membalik menjadi "✓". */}
        <span
          style={{
            position: 'relative',
            width: pick(96, 78),
            height: pick(150, 120),
            display: 'inline-block',
            opacity: spring({
              frame: frame - s(K.wordmark + wordmark.length * 0.055, fps),
              fps,
              config: SPRING.bouncy,
              durationInFrames: s(0.5, fps),
            }),
            transformStyle: 'preserve-3d',
            transform: `rotateY(${flipT * 180}deg)`,
          }}
        >
          <span
            style={{
              position: 'absolute',
              inset: 0,
              fontFamily: TITLE_FONT,
              fontSize: pick(150, 120),
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
              transform: 'rotateY(180deg) translateY(12%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <svg width={pick(92, 74)} height={pick(92, 74)} viewBox="0 0 24 24">
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

      {/* Tagline. */}
      <div
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          top: pick(height * 0.8, height * 0.73),
          display: 'flex',
          justifyContent: 'center',
        }}
      >
        <Kinetic
          text={COPY.logo.tagline}
          at={K.tagline}
          size={pick(38, 32)}
          color="rgba(255,255,255,0.9)"
          font={BODY_FONT}
          weight={600}
          style={{justifyContent: 'center', textAlign: 'center'}}
        />
      </div>
    </div>
  );
};
