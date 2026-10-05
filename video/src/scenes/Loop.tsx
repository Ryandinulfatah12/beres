import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT} from '../theme';
import {Mascot} from '../components/Mascot';
import {Backdrop, Body, Rise, Title} from '../components/ui';

const CX = 960;
const CY = 620;
const R = 268;

const STEPS = [
  {n: '1', label: 'Susun menu', sub: 'seminggu sekali', angle: -90, delay: 26},
  {n: '2', label: 'Generate belanja', sub: 'bahan dijumlahkan', angle: 0, delay: 44},
  {n: '3', label: 'Belanja & catat', sub: 'centang + harga', angle: 90, delay: 62},
  {n: '4', label: 'Riwayat', sub: 'total pengeluaran', angle: 180, delay: 80},
];

const pos = (angle: number) => ({
  x: CX + R * Math.cos((angle * Math.PI) / 180),
  y: CY + R * Math.sin((angle * Math.PI) / 180),
});

/** Adegan 3 — alur pemakaian sebagai satu putaran tertutup. */
export const Loop: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps, durationInFrames} = useVideoConfig();
  const out = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
  });

  const circumference = 2 * Math.PI * R;
  // Garis putaran digambar searah jarum jam mulai dari langkah 1.
  const draw = interpolate(frame, [16, 92], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <div style={{position: 'absolute', inset: 0, opacity: out}}>
      <Backdrop />

      <div style={{position: 'absolute', top: 92, left: 0, right: 0, textAlign: 'center'}}>
        <Rise>
          <Title size={74}>Alurnya satu putaran</Title>
        </Rise>
        <Rise delay={12}>
          <Body size={32} style={{marginTop: 20}}>
            Minggu depan tinggal salin minggu lalu — putarannya mulai lagi tanpa dari nol.
          </Body>
        </Rise>
      </div>

      <svg style={{position: 'absolute', inset: 0}} width={1920} height={1080}>
        <circle cx={CX} cy={CY} r={R} stroke={BC.line} strokeWidth={4} fill="none" />
        <circle
          cx={CX}
          cy={CY}
          r={R}
          stroke={BC.pandan}
          strokeWidth={6}
          fill="none"
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - draw)}
          transform={`rotate(-90 ${CX} ${CY})`}
        />
        {/* Kepala panah yang berjalan di sepanjang putaran. */}
        {draw > 0.02 && draw < 0.995
          ? (() => {
              const a = -90 + draw * 360;
              const p = pos(a);
              return (
                <g transform={`translate(${p.x} ${p.y}) rotate(${a + 90})`}>
                  <circle r={13} fill={BC.kunyit} stroke={BC.white} strokeWidth={4} />
                </g>
              );
            })()
          : null}
      </svg>

      {/* Maskot di tengah putaran. */}
      <div
        style={{
          position: 'absolute',
          left: CX - 90,
          top: CY - 95,
          opacity: interpolate(frame, [86, 104], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          }),
        }}
      >
        <Mascot size={180} steam="check" eyes="happy" motion="bob" />
      </div>

      {STEPS.map((step) => {
        const p = pos(step.angle);
        const s = spring({
          frame: frame - step.delay,
          fps,
          config: {damping: 13, mass: 0.6, stiffness: 120},
        });
        return (
          <div
            key={step.n}
            style={{
              position: 'absolute',
              left: p.x,
              top: p.y,
              transform: `translate(-50%, -50%) scale(${0.8 + 0.2 * s})`,
              opacity: s,
              width: 342,
            }}
          >
            <div
              style={{
                background: BC.white,
                borderRadius: 22,
                border: `1px solid ${BC.line}`,
                boxShadow: '0 16px 38px rgba(27,42,33,0.1)',
                padding: '20px 24px',
                display: 'flex',
                alignItems: 'center',
                gap: 16,
              }}
            >
              <div
                style={{
                  width: 52,
                  height: 52,
                  borderRadius: 16,
                  background: BC.pandan,
                  color: BC.white,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontFamily: TITLE_FONT,
                  fontSize: 30,
                  flexShrink: 0,
                }}
              >
                {step.n}
              </div>
              <div>
                <div
                  style={{
                    fontFamily: BODY_FONT,
                    fontWeight: 800,
                    fontSize: 26,
                    color: BC.arang,
                  }}
                >
                  {step.label}
                </div>
                <div style={{fontFamily: BODY_FONT, fontSize: 19, color: BC.muted, marginTop: 4}}>
                  {step.sub}
                </div>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
};
