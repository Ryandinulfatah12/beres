import React from 'react';
import {interpolate, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT} from '../theme';
import {Backdrop, Body, Rise, Title} from '../components/ui';

const PILLARS = [
  {
    title: 'Tanpa akun',
    body: 'Tidak ada pendaftaran, tidak ada login. Buka, langsung pakai.',
    icon: (
      <path
        d="M12 13a5 5 0 1 0 0-10 5 5 0 0 0 0 10ZM4 21c0-4 3.6-6 8-6s8 2 8 6"
        stroke={BC.kunyit}
        strokeWidth={2}
        strokeLinecap="round"
        fill="none"
      />
    ),
  },
  {
    title: 'Tanpa server',
    body: 'Tidak ada data yang dikirim ke mana pun. Offline sepenuhnya.',
    icon: (
      <path
        d="M3 6h18v5H3V6Zm0 7h18v5H3v-5ZM6.5 8.5h.01M6.5 15.5h.01M4 3l16 18"
        stroke={BC.kunyit}
        strokeWidth={2}
        strokeLinecap="round"
        fill="none"
      />
    ),
  },
  {
    title: 'Data di perangkatmu',
    body: 'SQLite lokal. Mau dicadangkan? Bagikan satu file beres.db ke Drive.',
    icon: (
      <path
        d="M12 2 4 6v6c0 5 3.4 8.6 8 10 4.6-1.4 8-5 8-10V6l-8-4Zm-3.2 9.6 2.4 2.4 4.4-4.8"
        stroke={BC.kunyit}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    ),
  },
];

/** Adegan 8 — privasi dan widget home screen. */
export const Offline: React.FC = () => {
  const frame = useCurrentFrame();
  const {durationInFrames} = useVideoConfig();
  const out = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
  });

  return (
    <div style={{position: 'absolute', inset: 0, opacity: out}}>
      <Backdrop tone="dark" />

      <div style={{position: 'absolute', left: 130, top: 120, width: 1660}}>
        <Rise>
          <Title size={74} tone="dark">
            Datanya tetap di dapurmu
          </Title>
        </Rise>
        <Rise delay={10}>
          <Body size={32} tone="dark" style={{marginTop: 20, maxWidth: 1100}}>
            Beres? sengaja dibuat sekecil mungkin: Flutter, SQLite, satu
            ChangeNotifier. Tanpa ORM, tanpa code generation, tanpa akun.
          </Body>
        </Rise>

        <div style={{display: 'flex', gap: 26, marginTop: 60}}>
          {PILLARS.map((p, i) => (
            <Rise key={p.title} delay={26 + i * 12} style={{flex: 1}}>
              <div
                style={{
                  background: 'rgba(255,255,255,0.08)',
                  border: '1px solid rgba(255,255,255,0.16)',
                  borderRadius: 26,
                  padding: 34,
                  height: 296,
                }}
              >
                <svg width={52} height={52} viewBox="0 0 24 24">
                  {p.icon}
                </svg>
                <div
                  style={{
                    fontFamily: TITLE_FONT,
                    fontSize: 38,
                    color: BC.white,
                    marginTop: 22,
                  }}
                >
                  {p.title}
                </div>
                <div
                  style={{
                    fontFamily: BODY_FONT,
                    fontSize: 24,
                    color: 'rgba(255,255,255,0.78)',
                    marginTop: 14,
                    lineHeight: 1.45,
                  }}
                >
                  {p.body}
                </div>
              </div>
            </Rise>
          ))}
        </div>

        {/* Widget home screen — pengingat tanpa membuka aplikasi. */}
        <Rise delay={70}>
          <div style={{display: 'flex', alignItems: 'center', gap: 40, marginTop: 88}}>
            <div
              style={{
                width: 560,
                background: BC.white,
                borderRadius: 24,
                padding: '20px 24px',
                boxShadow: '0 24px 60px rgba(0,0,0,0.3)',
                flexShrink: 0,
              }}
            >
              <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'baseline'}}>
                <span style={{fontFamily: TITLE_FONT, fontSize: 24, color: BC.arang}}>
                  Rabu · Soto ayam, Risol
                </span>
                <span style={{fontFamily: BODY_FONT, fontSize: 16, color: BC.muted}}>
                  6 – 12 Okt
                </span>
              </div>
              <div
                style={{
                  fontFamily: BODY_FONT,
                  fontSize: 18,
                  color: BC.muted,
                  marginTop: 10,
                  lineHeight: 1.6,
                }}
              >
                Kam · Ikan bakar
                <br />
                Jum · Sayur asem, Tempe orek
              </div>
              <div style={{display: 'flex', gap: 10, marginTop: 14}}>
                <span
                  style={{
                    padding: '8px 16px',
                    borderRadius: 999,
                    background: BC.greenSoft,
                    color: BC.greenText,
                    fontFamily: BODY_FONT,
                    fontWeight: 700,
                    fontSize: 16,
                  }}
                >
                  5 hari masak · 8 lauk · 3 cemilan
                </span>
                <span
                  style={{
                    padding: '8px 16px',
                    borderRadius: 999,
                    background: BC.orangeSoft,
                    color: BC.orangeText,
                    fontFamily: BODY_FONT,
                    fontWeight: 700,
                    fontSize: 16,
                  }}
                >
                  Belanja sudah beres ✓
                </span>
              </div>
            </div>
            <div>
              <div style={{fontFamily: TITLE_FONT, fontSize: 36, color: BC.kunyit}}>
                Widget home screen
              </div>
              <Body size={25} tone="dark" style={{marginTop: 10, maxWidth: 620}}>
                Menu hari ini dan sisa belanjaan langsung di layar home — ikut
                diperbarui tiap kali datanya berubah.
              </Body>
            </div>
          </div>
        </Rise>
      </div>
    </div>
  );
};
