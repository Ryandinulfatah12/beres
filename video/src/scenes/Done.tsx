import React from 'react';
import {interpolate, random, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT} from '../theme';
import {Mascot} from '../components/Mascot';
import {Backdrop, Body, Card, Eyebrow, Rise, Title} from '../components/ui';

/** 22 potong confetti dalam lima warna palet — seperti layar perayaan di aplikasi. */
const COLORS = [BC.kunyit, BC.cabai, BC.pandan, BC.blush, BC.kunyitDark];
const CONFETTI = new Array(22).fill(0).map((_, i) => ({
  i,
  x: random(`x${i}`) * 1920,
  size: 12 + random(`s${i}`) * 16,
  color: COLORS[i % COLORS.length],
  delay: random(`d${i}`) * 40,
  speed: 5 + random(`v${i}`) * 4,
  spin: (random(`r${i}`) - 0.5) * 16,
  drift: (random(`f${i}`) - 0.5) * 120,
}));

const Confetti: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <div style={{position: 'absolute', inset: 0, overflow: 'hidden'}}>
      {CONFETTI.map((c) => {
        const t = Math.max(0, frame - c.delay);
        const y = -60 + t * c.speed;
        if (y > 1140) return null;
        return (
          <div
            key={c.i}
            style={{
              position: 'absolute',
              left: c.x + Math.sin(t / 22) * c.drift,
              top: y,
              width: c.size,
              height: c.size * 0.6,
              borderRadius: 3,
              background: c.color,
              transform: `rotate(${t * c.spin}deg)`,
              opacity: interpolate(y, [900, 1120], [1, 0], {extrapolateLeft: 'clamp'}),
            }}
          />
        );
      })}
    </div>
  );
};

const STORES = [
  {name: 'Pasar', total: 71500},
  {name: 'Super Indo', total: 114500},
];

/** Riwayat minggu-minggu sebelumnya, siap disalin ulang. */
const HISTORY = [
  {range: '29 Sep – 5 Okt', info: '5 hari · 8 lauk · 4 cemilan', total: 'Rp 174.000'},
  {range: '22 – 28 Sep', info: '4 hari · 7 lauk · 3 cemilan', total: 'Rp 158.500'},
  {range: '15 – 21 Sep', info: '5 hari · 9 lauk · 5 cemilan', total: 'Rp 196.000'},
];

/** Adegan 7 — langkah 4: perayaan, lalu riwayat yang menutup putaran. */
export const Done: React.FC = () => {
  const frame = useCurrentFrame();
  const {durationInFrames} = useVideoConfig();
  const out = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
  });

  return (
    <div style={{position: 'absolute', inset: 0, opacity: out}}>
      <Backdrop />
      <Confetti />

      <div style={{position: 'absolute', left: 130, top: 230, width: 740}}>
        <Rise>
          <Eyebrow>LANGKAH 4</Eyebrow>
        </Rise>
        <Rise delay={6}>
          <div style={{display: 'flex', alignItems: 'center', gap: 28, marginTop: 26}}>
            <Mascot size={150} steam="check" eyes="happy" motion="jump" />
            <Title size={76}>Belanja beres!</Title>
          </div>
        </Rise>
        <Rise delay={16}>
          <Body size={32} style={{marginTop: 24}}>
            24 item sudah masuk keranjang. Kerja bagus, Bunda.
          </Body>
        </Rise>

        <Rise delay={30}>
          <Card pad={26} style={{marginTop: 36}}>
            <div
              style={{fontFamily: BODY_FONT, fontWeight: 700, fontSize: 20, color: BC.muted}}
            >
              TOTAL PER TOKO
            </div>
            {STORES.map((s) => (
              <div
                key={s.name}
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  padding: '14px 0',
                  borderBottom: `1px solid ${BC.lineSoft}`,
                  fontFamily: BODY_FONT,
                  fontSize: 26,
                  color: BC.arang,
                }}
              >
                <span style={{fontWeight: 600}}>{s.name}</span>
                <span style={{fontWeight: 800}}>Rp {s.total.toLocaleString('id-ID')}</span>
              </div>
            ))}
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                paddingTop: 16,
                fontFamily: TITLE_FONT,
                fontSize: 32,
                color: BC.greenText,
              }}
            >
              <span>Minggu ini</span>
              <span>Rp 186.000</span>
            </div>
          </Card>
        </Rise>
      </div>

      <div style={{position: 'absolute', left: 1010, top: 210, width: 800}}>
        <Rise delay={44}>
          <Title size={46}>Semuanya masuk Riwayat</Title>
        </Rise>
        <Rise delay={52}>
          <Body size={26} style={{marginTop: 14}}>
            Total pengeluaran per bulan, dan pola menu tiap minggu yang bisa
            dipakai lagi.
          </Body>
        </Rise>

        <Rise delay={62}>
          <Card pad={24} style={{marginTop: 28, background: BC.daun, border: 'none'}}>
            <div
              style={{
                fontFamily: BODY_FONT,
                color: 'rgba(255,255,255,0.7)',
                fontSize: 19,
                fontWeight: 700,
              }}
            >
              PENGELUARAN OKTOBER
            </div>
            <div
              style={{
                fontFamily: TITLE_FONT,
                fontSize: 54,
                color: BC.white,
                marginTop: 8,
              }}
            >
              Rp 186.000
            </div>
            <div
              style={{
                fontFamily: BODY_FONT,
                color: 'rgba(255,255,255,0.75)',
                fontSize: 21,
                marginTop: 4,
              }}
            >
              1 kali belanja
            </div>
          </Card>
        </Rise>

        <div style={{marginTop: 22, display: 'flex', flexDirection: 'column', gap: 14}}>
          {HISTORY.map((h, i) => (
            <Rise key={h.range} delay={76 + i * 10}>
              <Card pad={20} style={{display: 'flex', alignItems: 'center', gap: 18}}>
                <div style={{flex: 1}}>
                  <div
                    style={{fontFamily: BODY_FONT, fontWeight: 800, fontSize: 24, color: BC.arang}}
                  >
                    {h.range}
                  </div>
                  <div style={{fontFamily: BODY_FONT, fontSize: 19, color: BC.muted, marginTop: 4}}>
                    {h.info} · {h.total}
                  </div>
                </div>
                <div
                  style={{
                    padding: '11px 20px',
                    borderRadius: 999,
                    background: BC.greenSoft,
                    color: BC.greenText,
                    fontFamily: BODY_FONT,
                    fontWeight: 800,
                    fontSize: 19,
                  }}
                >
                  Salin ke minggu ini
                </div>
              </Card>
            </Rise>
          ))}
        </div>
      </div>
    </div>
  );
};
