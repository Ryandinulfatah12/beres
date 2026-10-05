import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT, usePick} from '../theme';
import {CLAMP, EASE, s, SPRING} from '../motion';
import {COPY} from '../copy';
import {snap} from '../beats';
import {Backdrop} from '../components/ui';
import {Camera} from '../components/Camera';
import {Kinetic} from '../components/text';
import {Mascot} from '../components/Mascot';

/**
 * Scene 3 — Siklus (9–14 dtk).
 *
 * Lingkaran digambar mengikuti ketukan, empat node pop satu per satu, dan
 * Si Beres berjalan mengitarinya. Di akhir, kamera menembus node 1 yang
 * membesar menjadi layar phone — menyambung ke babak berikutnya.
 */
export const Cycle: React.FC<{bpm: number; beatOffset: number}> = ({bpm, beatOffset}) => {
  const frame = useCurrentFrame();
  const {fps, width, height} = useVideoConfig();
  const pick = usePick();

  const cx = width / 2;
  const cy = pick(height * 0.58, height * 0.54);
  const R = pick(height * 0.25, width * 0.3);

  // Node pop mengikuti ketukan.
  const nodeAt = [0.75, 1.3, 1.85, 2.4].map((t) => snap(t, bpm, beatOffset));

  const draw = interpolate(frame, [s(0.35, fps), s(2.7, fps)], [0, 1], {
    ...CLAMP,
    easing: EASE.in,
  });
  const C = 2 * Math.PI * R;

  // Maskot berjalan mengitari lingkaran, sedikit di depan garis yang digambar.
  const walkA = -90 + draw * 360;
  const walkRad = (walkA * Math.PI) / 180;
  // Mengorbit di sisi dalam lingkaran: kalau tepat di garis, ia akan menutupi
  // kartu node yang posisinya juga di garis itu.
  const walkR = R * 0.5;
  const mx = cx + walkR * Math.cos(walkRad);
  const my = cy + walkR * Math.sin(walkRad);

  // Zoom menembus node 1 di akhir scene.
  const n0 = {x: cx, y: cy - R};
  const through = interpolate(frame, [s(4.0, fps), s(5.2, fps)], [0, 1], {
    ...CLAMP,
    easing: EASE.in,
  });

  const pos = (i: number) => {
    const a = (-90 + i * 90) * (Math.PI / 180);
    return {x: cx + R * Math.cos(a), y: cy + R * Math.sin(a)};
  };

  return (
    <div style={{position: 'absolute', inset: 0}}>
      <Backdrop bpm={bpm} beatOffset={beatOffset} />

      <Camera
        moves={[
          {at: 0, scale: 1, x: 0, y: 0},
          {at: 3.6, scale: 1, x: 0, y: 0},
          // Menembus node 1: skala naik dan titik itu digeser ke tengah.
          {at: 5.2, scale: 2.6, x: (cx - n0.x) * 1.2, y: (cy - n0.y) * 1.2 + height * 0.1},
        ]}
        blur={frame >= s(3.8, fps)}
        holdAmount={0.012}
      >
        <div
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            top: pick(height * 0.1, height * 0.12),
            display: 'flex',
            justifyContent: 'center',
          }}
        >
          <Kinetic
            text={COPY.cycle.headline}
            at={0.15}
            out={3.9}
            size={pick(68, 58)}
            style={{justifyContent: 'center'}}
          />
        </div>

        <svg style={{position: 'absolute', inset: 0}} width={width} height={height}>
          <circle cx={cx} cy={cy} r={R} stroke={BC.line} strokeWidth={4} fill="none" />
          <circle
            cx={cx}
            cy={cy}
            r={R}
            stroke={BC.pandan}
            strokeWidth={6}
            fill="none"
            strokeLinecap="round"
            strokeDasharray={C}
            strokeDashoffset={C * (1 - draw)}
            transform={`rotate(-90 ${cx} ${cy})`}
          />
        </svg>

        {/* Empat node. */}
        {COPY.cycle.nodes.map((n, i) => {
          const p = pos(i);
          const e = spring({
            frame: frame - s(nodeAt[i], fps),
            fps,
            config: SPRING.snappy,
            durationInFrames: s(0.45, fps),
          });
          // Node 1 ikut membesar saat kamera menembusnya.
          const grow = i === 0 ? 1 + through * 1.1 : 1 - through * 0.25;
          const fade = i === 0 ? 1 : 1 - through;
          return (
            <div
              key={n.label}
              style={{
                position: 'absolute',
                left: p.x,
                top: p.y,
                transform: `translate(-50%, -50%) scale(${(0.8 + e * 0.2) * grow})`,
                opacity: e * fade,
                width: pick(300, 260),
              }}
            >
              <div
                style={{
                  background: BC.white,
                  borderRadius: 20,
                  border: `1px solid ${BC.line}`,
                  boxShadow: '0 16px 38px rgba(27,42,33,0.1)',
                  padding: '16px 20px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: 14,
                }}
              >
                <div
                  style={{
                    width: 46,
                    height: 46,
                    borderRadius: 14,
                    background: BC.pandan,
                    color: BC.white,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontFamily: TITLE_FONT,
                    fontSize: 26,
                    flexShrink: 0,
                  }}
                >
                  {i + 1}
                </div>
                <div>
                  <div
                    style={{
                      fontFamily: BODY_FONT,
                      fontWeight: 800,
                      fontSize: 23,
                      color: BC.arang,
                    }}
                  >
                    {n.label}
                  </div>
                  <div style={{fontFamily: BODY_FONT, fontSize: 17, color: BC.muted, marginTop: 2}}>
                    {n.sub}
                  </div>
                </div>
              </div>
            </div>
          );
        })}

        {/* Si Beres berjalan mengitari lingkaran. */}
        <div
          style={{
            position: 'absolute',
            left: mx,
            top: my,
            transform: 'translate(-50%, -50%)',
            opacity: 1 - through,
          }}
        >
          <Mascot size={pick(130, 110)} steam="check" eyes="happy" motion="jump" />
        </div>
      </Camera>
    </div>
  );
};
