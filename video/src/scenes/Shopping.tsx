import React from 'react';
import {interpolate, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT} from '../theme';
import {Backdrop, Body, Card, CheckBox, Chip, Eyebrow, Phone, Progress, Rise, Title} from '../components/ui';

/** Barang yang dicentang satu per satu di depan rak, beserta harganya. */
const ITEMS = [
  {name: 'Dada ayam', qty: '1000 gr', toko: 'Super Indo', price: 38000, at: 30},
  {name: 'Bawang merah', qty: '11 siung', toko: 'Pasar', price: 7500, at: 54},
  {name: 'Telur', qty: '8 butir', toko: 'Pasar', price: 22000, at: 78},
  {name: 'Wortel', qty: '2 buah', toko: 'Super Indo', price: 4000, at: 102},
  {name: 'Kunyit', qty: '2 cm', toko: 'Pasar', price: 2000, at: 126},
  // Belum diambil — tetap di atas sampai dicentang.
  {name: 'Cabai merah', qty: '250 gr', toko: 'Pasar', price: 9000, at: 99999},
  {name: 'Minyak goreng', qty: '2 liter', toko: 'Super Indo', price: 36000, at: 99999},
];

const TOTAL_ITEMS = 24;
const CHECKED_BEFORE = 7;
const TOTAL_BEFORE = 112500;

/** Ikon troli kuning yang berjalan mengikuti progres. */
const Trolley: React.FC<{size?: number}> = ({size = 30}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <path
      d="M2 3h3l3 11h10l2.5-8H6.5"
      stroke={BC.kunyit}
      strokeWidth={2.2}
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    <circle cx={9.5} cy={19} r={1.9} fill={BC.kunyit} />
    <circle cx={17.5} cy={19} r={1.9} fill={BC.kunyit} />
  </svg>
);

/** Adegan 6 — langkah 3: mode belanja, dipakai sambil berdiri di toko. */
export const Shopping: React.FC = () => {
  const frame = useCurrentFrame();
  const {durationInFrames} = useVideoConfig();
  const out = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
  });

  const done = ITEMS.filter((i) => frame >= i.at).length;
  const checked = CHECKED_BEFORE + done;
  const progress = interpolate(frame, [0, 150], [0, 0], {extrapolateRight: 'clamp'}) + checked / TOTAL_ITEMS;

  // Total ikut beranimasi tiap kali satu harga masuk.
  const total = ITEMS.reduce((sum, it) => {
    const grow = interpolate(frame, [it.at, it.at + 10], [0, 1], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    });
    return sum + it.price * grow;
  }, TOTAL_BEFORE);

  return (
    <div style={{position: 'absolute', inset: 0, opacity: out}}>
      <Backdrop />

      <div style={{position: 'absolute', left: 130, top: 230, width: 760}}>
        <Rise>
          <Eyebrow>LANGKAH 3</Eyebrow>
        </Rise>
        <Rise delay={8}>
          <div style={{marginTop: 22}}>
            <Title size={78}>Centang sambil belanja</Title>
          </div>
        </Rise>
        <Rise delay={18}>
          <Body size={32} style={{marginTop: 26}}>
            Mode belanja adalah satu layar fokus: checkbox besar, getaran halus
            tiap centang, dan kolom harga per item. Totalnya jalan sendiri.
          </Body>
        </Rise>

        <div style={{marginTop: 42, display: 'flex', flexDirection: 'column', gap: 14}}>
          {[
            {t: 'Filter per toko', d: 'belanja satu toko dulu, lalu pindah'},
            {t: 'Yang sudah diambil turun', d: 'sisanya tetap di atas'},
            {t: 'Langsung tersimpan', d: 'aman kalau aplikasi tertutup di tengah belanja'},
          ].map((f, i) => (
            <Rise key={f.t} delay={34 + i * 12}>
              <Card pad={20} style={{display: 'flex', alignItems: 'center', gap: 18}}>
                <div
                  style={{
                    width: 12,
                    height: 12,
                    borderRadius: 999,
                    background: BC.kunyit,
                    flexShrink: 0,
                  }}
                />
                <div>
                  <span
                    style={{fontFamily: BODY_FONT, fontWeight: 800, fontSize: 24, color: BC.arang}}
                  >
                    {f.t}
                  </span>
                  <span style={{fontFamily: BODY_FONT, fontSize: 22, color: BC.muted}}>
                    {' '}
                    — {f.d}
                  </span>
                </div>
              </Card>
            </Rise>
          ))}
        </div>
      </div>

      <Rise delay={6} distance={48} style={{position: 'absolute', left: 1180, top: 70}}>
        <Phone width={430}>
          {/* Header hijau tua dengan progress bar bertroli. */}
          <div style={{background: BC.daun, padding: '26px 20px 22px', color: BC.white}}>
            <div style={{fontSize: 13, fontWeight: 700, opacity: 0.75, letterSpacing: 0.6}}>
              MODE BELANJA
            </div>
            <div style={{fontFamily: TITLE_FONT, fontSize: 26, marginTop: 6}}>
              {checked} dari {TOTAL_ITEMS} item diambil
            </div>
            <div style={{position: 'relative', marginTop: 18, paddingBottom: 6}}>
              <Progress
                value={progress}
                height={8}
                color={BC.kunyit}
                track="rgba(255,255,255,0.22)"
              />
              <div
                style={{
                  position: 'absolute',
                  top: -22,
                  left: `calc(${Math.min(1, progress) * 100}% - 15px)`,
                }}
              >
                <Trolley />
              </div>
            </div>
          </div>

          {/* Chip filter toko. */}
          <div style={{display: 'flex', gap: 8, padding: '14px 20px 6px'}}>
            <Chip size={13} bg={BC.pandan} color={BC.white}>
              Semua 24
            </Chip>
            <Chip size={13} bg={BC.pill} color={BC.muted}>
              Pasar 14
            </Chip>
            <Chip size={13} bg={BC.pill} color={BC.muted}>
              Super Indo 10
            </Chip>
          </div>

          <div style={{padding: '8px 20px', display: 'flex', flexDirection: 'column', gap: 10}}>
            {ITEMS.map((it) => {
              const on = interpolate(frame, [it.at, it.at + 9], [0, 1], {
                extrapolateLeft: 'clamp',
                extrapolateRight: 'clamp',
              });
              const priceIn = interpolate(frame, [it.at + 4, it.at + 14], [0, 1], {
                extrapolateLeft: 'clamp',
                extrapolateRight: 'clamp',
              });
              return (
                <div
                  key={it.name}
                  style={{
                    background: BC.white,
                    borderRadius: 16,
                    border: `1px solid ${on > 0.5 ? BC.greenSoft : BC.line}`,
                    padding: '13px 14px',
                    display: 'flex',
                    alignItems: 'center',
                    gap: 12,
                  }}
                >
                  <CheckBox on={on} size={30} />
                  <div style={{flex: 1, opacity: on > 0.5 ? 0.6 : 1}}>
                    <div
                      style={{
                        fontWeight: 800,
                        fontSize: 16,
                        color: BC.arang,
                        textDecoration: on > 0.5 ? 'line-through' : 'none',
                      }}
                    >
                      {it.name}
                    </div>
                    <div style={{fontSize: 13, color: BC.muted, marginTop: 2}}>
                      {it.qty} · {it.toko}
                    </div>
                  </div>
                  <div
                    style={{
                      minWidth: 92,
                      textAlign: 'right',
                      borderBottom: `1.5px solid ${priceIn > 0 ? BC.pandan : BC.line}`,
                      paddingBottom: 3,
                      fontWeight: 800,
                      fontSize: 16,
                      color: priceIn > 0 ? BC.arang : BC.line,
                    }}
                  >
                    Rp{' '}
                    {priceIn > 0
                      ? Math.round(it.price * priceIn).toLocaleString('id-ID')
                      : '—'}
                  </div>
                </div>
              );
            })}
          </div>

          <div
            style={{
              marginTop: 'auto',
              padding: 20,
              borderTop: `1px solid ${BC.line}`,
              background: BC.white,
            }}
          >
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'baseline',
                marginBottom: 14,
              }}
            >
              <span style={{fontSize: 15, color: BC.muted, fontWeight: 600}}>Total</span>
              <span style={{fontFamily: TITLE_FONT, fontSize: 30, color: BC.arang}}>
                Rp {Math.round(total).toLocaleString('id-ID')}
              </span>
            </div>
            <div
              style={{
                background: BC.pandan,
                color: BC.white,
                borderRadius: 16,
                padding: '15px 0',
                textAlign: 'center',
                fontWeight: 800,
                fontSize: 17,
              }}
            >
              Selesai
            </div>
          </div>
        </Phone>
      </Rise>
    </div>
  );
};
