import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT} from '../theme';
import {Mascot} from '../components/Mascot';
import {Backdrop, Body, Rise, Title} from '../components/ui';

/** Pertanyaan yang muncul tiap minggu di dapur — posisinya disebar manual. */
const QUESTIONS = [
  {text: 'Hari ini masak apa?', x: 1080, y: 170, rot: -3, delay: 10},
  {text: 'Bahannya apa aja ya?', x: 1390, y: 330, rot: 2.5, delay: 24},
  {text: 'Telur udah dibeli belum?', x: 1010, y: 470, rot: -1.5, delay: 38},
  {text: 'Kemarin beli di toko mana?', x: 1330, y: 620, rot: 3, delay: 52},
  {text: 'Bulan ini habis berapa?', x: 1030, y: 780, rot: -2, delay: 66},
];

export const Problem: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps, durationInFrames} = useVideoConfig();
  const out = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
  });

  return (
    <div style={{position: 'absolute', inset: 0, opacity: out}}>
      <Backdrop />

      <div style={{position: 'absolute', left: 130, top: 300, width: 780}}>
        <Rise>
          <Title size={82}>
            Tiap minggu,
            <br />
            pertanyaannya sama.
          </Title>
        </Rise>
        <Rise delay={14}>
          <Body size={34} style={{marginTop: 32}}>
            Menu, bahan, belanjaan, pengeluaran — semuanya berserakan di kepala,
            catatan HP, dan chat sendiri.
          </Body>
        </Rise>
        <Rise delay={70}>
          <div
            style={{
              marginTop: 48,
              display: 'inline-flex',
              alignItems: 'center',
              gap: 18,
              padding: '18px 28px',
              background: BC.white,
              borderRadius: 20,
              border: `2px solid ${BC.pandan}`,
              boxShadow: '0 16px 40px rgba(27,42,33,0.1)',
            }}
          >
            <Mascot size={78} steam="check" eyes="happy" motion="still" />
            <span
              style={{
                fontFamily: BODY_FONT,
                fontWeight: 800,
                fontSize: 30,
                color: BC.greenText,
              }}
            >
              Satu aplikasi, satu putaran.
            </span>
          </div>
        </Rise>
      </div>

      {QUESTIONS.map((q) => {
        const s = spring({
          frame: frame - q.delay,
          fps,
          config: {damping: 12, mass: 0.7, stiffness: 110},
        });
        // Pertanyaan memudar begitu Si Beres menjawab.
        const quiet = interpolate(frame, [76, 100], [1, 0.3], {
          extrapolateLeft: 'clamp',
          extrapolateRight: 'clamp',
        });
        const float = Math.sin((frame + q.delay * 3) / 26) * 6;
        return (
          <div
            key={q.text}
            style={{
              position: 'absolute',
              left: q.x,
              top: q.y + float,
              opacity: s * quiet,
              transform: `translateY(${(1 - s) * 20}px) rotate(${q.rot}deg) scale(${0.9 + 0.1 * s})`,
            }}
          >
            <div
              style={{
                padding: '22px 32px',
                background: BC.white,
                borderRadius: '26px 26px 26px 8px',
                border: `1px solid ${BC.line}`,
                boxShadow: '0 14px 34px rgba(27,42,33,0.09)',
                fontFamily: BODY_FONT,
                fontWeight: 600,
                fontSize: 32,
                color: BC.arang,
              }}
            >
              {q.text}
            </div>
          </div>
        );
      })}
    </div>
  );
};
