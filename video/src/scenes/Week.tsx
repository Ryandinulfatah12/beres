import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT} from '../theme';
import {Mascot} from '../components/Mascot';
import {Backdrop, Body, Card, Chip, Eyebrow, Phone, Rise, Title} from '../components/ui';

type Day = {
  day: string;
  lauk: string[];
  cemilan: string[];
  on: boolean;
  today?: boolean;
  /** Frame saat menunya mulai muncul; -1 berarti sudah terisi dari awal. */
  delay: number;
};

const DAYS: Day[] = [
  {day: 'Senin', lauk: ['Ayam goreng', 'Tumis kangkung'], cemilan: ['Pisang goreng'], on: true, delay: -1},
  {day: 'Selasa', lauk: ['Capcay', 'Rolade'], cemilan: [], on: true, delay: -1},
  {day: 'Rabu', lauk: ['Soto ayam'], cemilan: ['Risol'], on: true, today: true, delay: -1},
  {day: 'Kamis', lauk: ['Ikan bakar'], cemilan: [], on: true, delay: 62},
  {day: 'Jumat', lauk: ['Sayur asem', 'Tempe orek'], cemilan: ['Bakwan'], on: true, delay: 96},
  {day: 'Sabtu', lauk: [], cemilan: [], on: false, delay: -1},
];

const DayCard: React.FC<{d: Day}> = ({d}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const filled = d.delay < 0 ? 1 : spring({frame: frame - d.delay, fps, config: {damping: 200}});
  const items = [...d.lauk.map((l) => ({t: l, kind: 'lauk' as const})), ...d.cemilan.map((c) => ({t: c, kind: 'cemilan' as const}))];
  // Hari yang baru terisi ikut menyala: checkbox "Masak" otomatis aktif.
  const active = d.on && (d.delay < 0 || filled > 0.2);

  return (
    <div
      style={{
        background: BC.white,
        borderRadius: 16,
        border: d.today ? `2px solid ${BC.pandan}` : `1px solid ${BC.line}`,
        padding: '12px 14px',
        opacity: active ? 1 : 0.45,
      }}
    >
      <div style={{display: 'flex', alignItems: 'center', gap: 8}}>
        <div
          style={{
            width: 18,
            height: 18,
            borderRadius: 5,
            border: `2px solid ${active ? BC.pandan : BC.line}`,
            background: active ? BC.pandan : 'transparent',
          }}
        />
        <span style={{fontWeight: 800, fontSize: 16, color: BC.arang}}>{d.day}</span>
        {d.today ? <Chip size={11}>Hari ini</Chip> : null}
        {!d.on ? (
          <span style={{fontSize: 12, color: BC.muted, marginLeft: 'auto'}}>Libur masak</span>
        ) : null}
      </div>
      {items.length ? (
        <div
          style={{
            display: 'flex',
            flexWrap: 'wrap',
            gap: 6,
            marginTop: 10,
            opacity: filled,
            transform: `translateY(${(1 - filled) * 8}px)`,
          }}
        >
          {items.map((it) => (
            <Chip
              key={it.t}
              size={12}
              bg={it.kind === 'lauk' ? BC.greenSoft : BC.orangeSoft}
              color={it.kind === 'lauk' ? BC.greenText : BC.orangeText}
            >
              {it.t} ×
            </Chip>
          ))}
        </div>
      ) : (
        <div style={{marginTop: 10, fontSize: 12, color: BC.muted}}>+ Tambah menu</div>
      )}
    </div>
  );
};

/** Adegan 4 — langkah 1: menyusun menu tujuh hari. */
export const Week: React.FC = () => {
  const frame = useCurrentFrame();
  const {durationInFrames} = useVideoConfig();
  const out = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
  });

  // Ringkasan ikut naik begitu Kamis dan Jumat terisi.
  const hari = frame > 96 ? 5 : frame > 62 ? 4 : 3;
  const lauk = frame > 96 ? 8 : frame > 62 ? 6 : 5;
  const cemilan = frame > 96 ? 3 : 2;

  return (
    <div style={{position: 'absolute', inset: 0, opacity: out}}>
      <Backdrop />

      <div style={{position: 'absolute', left: 130, top: 250, width: 760}}>
        <Rise>
          <Eyebrow>LANGKAH 1</Eyebrow>
        </Rise>
        <Rise delay={8}>
          <Title size={78} >
            <span style={{display: 'block', marginTop: 24}}>Susun menu seminggu</span>
          </Title>
        </Rise>
        <Rise delay={18}>
          <Body size={32} style={{marginTop: 26}}>
            Pilih lauk dan cemilan per hari dari menu yang sudah kamu simpan. Hari
            ke luar kota? Matikan checkbox <b style={{color: BC.arang}}>Masak</b> —
            bahannya tidak ikut dihitung.
          </Body>
        </Rise>

        <Rise delay={34}>
          <div style={{display: 'flex', gap: 16, marginTop: 40}}>
            {[
              {k: 'Pilih banyak sekaligus', v: 'satu bottom sheet'},
              {k: 'Nama baru? langsung jadi', v: 'bahan menyusul'},
            ].map((f) => (
              <Card key={f.k} pad={20} style={{flex: 1}}>
                <div style={{fontFamily: BODY_FONT, fontWeight: 800, fontSize: 22, color: BC.arang}}>
                  {f.k}
                </div>
                <div style={{fontFamily: BODY_FONT, fontSize: 18, color: BC.muted, marginTop: 6}}>
                  {f.v}
                </div>
              </Card>
            ))}
          </div>
        </Rise>
      </div>

      <Rise delay={6} distance={48} style={{position: 'absolute', left: 1180, top: 70}}>
        <Phone width={430}>
          {/* Kepala layar Minggu Ini. */}
          <div style={{padding: '26px 20px 14px'}}>
            <div style={{fontSize: 13, fontWeight: 700, color: BC.muted, letterSpacing: 0.6}}>
              MINGGU INI
            </div>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginTop: 4,
              }}
            >
              <span style={{fontFamily: TITLE_FONT, fontSize: 28, color: BC.arang}}>
                6 – 12 Okt 2026
              </span>
              <span style={{color: BC.muted, fontSize: 22}}>‹ ›</span>
            </div>
          </div>

          {/* Kartu ringkasan dengan maskot. */}
          <div style={{padding: '0 20px'}}>
            <div
              style={{
                background: BC.daun,
                borderRadius: 18,
                padding: 16,
                display: 'flex',
                alignItems: 'center',
                gap: 12,
              }}
            >
              <Mascot size={62} steam="none" eyes="happy" motion="bob" body={BC.pandan} />
              <div style={{color: BC.white}}>
                <div style={{fontWeight: 800, fontSize: 19}}>
                  {hari} hari masak
                </div>
                <div style={{fontSize: 14, opacity: 0.85, marginTop: 3}}>
                  {lauk} lauk · {cemilan} cemilan
                </div>
              </div>
            </div>
          </div>

          <div style={{padding: '14px 20px', display: 'flex', flexDirection: 'column', gap: 10}}>
            {DAYS.map((d) => (
              <DayCard key={d.day} d={d} />
            ))}
          </div>

          <div style={{marginTop: 'auto', padding: 20}}>
            <div
              style={{
                background: BC.pandan,
                color: BC.white,
                borderRadius: 16,
                padding: '16px 0',
                textAlign: 'center',
                fontWeight: 800,
                fontSize: 17,
              }}
            >
              Generate daftar belanja
            </div>
          </div>
        </Phone>
      </Rise>
    </div>
  );
};
