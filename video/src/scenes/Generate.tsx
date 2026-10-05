import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT} from '../theme';
import {Backdrop, Body, Chip, Eyebrow, Rise, Title} from '../components/ui';

/** Tiga menu dari rencana minggu ini, dengan bahannya. */
const DISHES = [
  {name: 'Ayam goreng', y: 392, items: ['Dada ayam · 500 gr', 'Bawang merah · 3 siung', 'Kunyit · 2 cm']},
  {name: 'Soto ayam', y: 614, items: ['Dada ayam · 500 gr', 'Bawang merah · 5 siung', 'Telur · 6 butir']},
  {name: 'Capcay', y: 836, items: ['Bawang merah · 3 siung', 'Telur · 2 butir', 'Wortel · 2 buah']},
];

/** Hasil penjumlahan — `sources` memberi tahu bahan ini dari menu mana. */
const MERGED = [
  {name: 'Dada ayam', qty: '1000 gr', from: 'Ayam goreng, Soto ayam', cara: 'Eceran', toko: 'Super Indo'},
  {name: 'Bawang merah', qty: '11 siung', from: '3 menu', cara: 'Eceran', toko: 'Pasar'},
  {name: 'Telur', qty: '8 butir', from: 'Soto ayam, Capcay', cara: 'Grosir', toko: 'Pasar'},
  {name: 'Kunyit', qty: '2 cm', from: 'Ayam goreng', cara: 'Eceran', toko: 'Pasar'},
  {name: 'Wortel', qty: '2 buah', from: 'Capcay', cara: 'Eceran', toko: 'Super Indo'},
];

const DISH_X = 96;
const DISH_W = 400;
const LIST_X = 1080;
const LIST_W = 740;

/** Adegan 5 — langkah 2: bahan dari semua menu dijumlahkan jadi satu daftar. */
export const Generate: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps, durationInFrames} = useVideoConfig();
  const out = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
  });

  // Garis penghubung digambar setelah kartu menu muncul.
  const flow = interpolate(frame, [52, 104], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <div style={{position: 'absolute', inset: 0, opacity: out}}>
      <Backdrop />

      <div style={{position: 'absolute', top: 70, left: 96, width: 1000}}>
        <Rise>
          <Eyebrow>LANGKAH 2</Eyebrow>
        </Rise>
        <Rise delay={8}>
          <div style={{marginTop: 20}}>
            <Title size={72}>Bahan dijumlahkan sendiri</Title>
          </div>
        </Rise>
        <Rise delay={16}>
          <Body size={28} style={{marginTop: 16, maxWidth: 880}}>
            Bawang merah dipakai tiga menu? Jadi satu baris, 11 siung — nama
            bahan dinormalkan tanpa peduli huruf besar-kecil.
          </Body>
        </Rise>
      </div>

      {/* Garis dari tiap kartu menu ke daftar belanja. */}
      <svg style={{position: 'absolute', inset: 0}} width={1920} height={1080}>
        {DISHES.map((d, i) => {
          const x1 = DISH_X + DISH_W;
          const y1 = d.y + 90;
          const x2 = LIST_X - 14;
          const y2 = 566;
          const path = `M${x1} ${y1} C${x1 + 180} ${y1} ${x2 - 180} ${y2} ${x2} ${y2}`;
          const len = 700;
          const local = interpolate(flow, [i * 0.12, i * 0.12 + 0.7], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          });
          return (
            <path
              key={d.name}
              d={path}
              stroke={BC.pandan}
              strokeWidth={3.5}
              fill="none"
              strokeLinecap="round"
              opacity={0.45}
              strokeDasharray={len}
              strokeDashoffset={len * (1 - local)}
            />
          );
        })}
      </svg>

      {DISHES.map((d, i) => (
        <Rise
          key={d.name}
          delay={24 + i * 10}
          style={{position: 'absolute', left: DISH_X, top: d.y, width: DISH_W}}
        >
          <div
            style={{
              background: BC.white,
              borderRadius: 20,
              border: `1px solid ${BC.line}`,
              padding: 22,
              boxShadow: '0 14px 34px rgba(27,42,33,0.08)',
            }}
          >
            <div
              style={{
                fontFamily: BODY_FONT,
                fontWeight: 800,
                fontSize: 26,
                color: BC.arang,
                marginBottom: 12,
              }}
            >
              {d.name}
            </div>
            {d.items.map((it) => (
              <div
                key={it}
                style={{
                  fontFamily: BODY_FONT,
                  fontSize: 20,
                  color: BC.muted,
                  padding: '5px 0',
                }}
              >
                {it}
              </div>
            ))}
          </div>
        </Rise>
      ))}

      {/* Daftar belanja hasil generate. */}
      <div style={{position: 'absolute', left: LIST_X, top: 300, width: LIST_W}}>
        <Rise delay={60}>
          <div
            style={{
              background: BC.white,
              borderRadius: 24,
              border: `2px solid ${BC.pandan}`,
              boxShadow: '0 22px 50px rgba(27,42,33,0.12)',
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                background: BC.pandan,
                color: BC.white,
                padding: '18px 24px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                fontFamily: BODY_FONT,
                fontWeight: 800,
                fontSize: 24,
              }}
            >
              <span>Daftar belanja · Dari menu</span>
              <span style={{opacity: 0.8, fontSize: 20}}>5 bahan</span>
            </div>

            {MERGED.map((m, i) => {
              const s = spring({
                frame: frame - (76 + i * 9),
                fps,
                config: {damping: 200, mass: 0.6},
              });
              const grosir = m.cara === 'Grosir';
              return (
                <div
                  key={m.name}
                  style={{
                    padding: '16px 24px',
                    borderTop: `1px solid ${BC.lineSoft}`,
                    opacity: s,
                    transform: `translateX(${(1 - s) * 22}px)`,
                    display: 'flex',
                    alignItems: 'center',
                    gap: 16,
                  }}
                >
                  <div
                    style={{
                      width: 24,
                      height: 24,
                      borderRadius: 7,
                      border: `2px solid ${BC.line}`,
                      flexShrink: 0,
                    }}
                  />
                  <div style={{flex: 1}}>
                    <div
                      style={{
                        fontFamily: BODY_FONT,
                        fontWeight: 800,
                        fontSize: 23,
                        color: BC.arang,
                      }}
                    >
                      {m.name} — {m.qty}
                    </div>
                    <div
                      style={{
                        fontFamily: BODY_FONT,
                        fontSize: 17,
                        color: BC.muted,
                        marginTop: 3,
                      }}
                    >
                      dari {m.from}
                    </div>
                  </div>
                  <Chip size={14} bg={BC.pill} color={BC.muted}>
                    {m.toko}
                  </Chip>
                  <Chip
                    size={14}
                    bg={grosir ? BC.orangeSoft : BC.greenSoft}
                    color={grosir ? BC.orangeText : BC.greenText}
                  >
                    {m.cara}
                  </Chip>
                </div>
              );
            })}
          </div>
        </Rise>

        <Rise delay={132}>
          <div
            style={{
              marginTop: 22,
              fontFamily: BODY_FONT,
              fontSize: 22,
              color: BC.muted,
              lineHeight: 1.5,
            }}
          >
            Generate ulang aman kapan saja: centang, harga, dan item tambahanmu
            tidak hilang.
          </div>
        </Rise>
      </div>
    </div>
  );
};
