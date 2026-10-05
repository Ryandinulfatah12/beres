import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, TITLE_FONT} from '../theme';
import {CLAMP, EASE, s, SPRING} from '../motion';
import {DATA} from '../copy';
import {Mascot} from './Mascot';
import {Rolling} from './text';
import {SCREEN_W} from './Phone';

/**
 * Lima layar aplikasi, digambar dalam ruang 390×844 (ukuran asli app).
 * Semua waktu di sini adalah detik relatif terhadap awal babak phone.
 */

/** Jadwal babak phone — dipakai layar dan juga babaknya sendiri. */
export const T = {
  /** Scene 4 — susun menu. */
  tapTambah: 2.6,
  sheetUp: 2.7,
  pick1: 3.9,
  pick2: 4.6,
  tapAdd: 5.3,
  sheetDown: 5.45,
  chipsLand: 6.0,
  rollSummary: 6.2,
  tapLibur: 7.4,
  /** Scene 5 — bahan dijumlahkan. */
  tapGenerate: 9.6,
  toList: 10.0,
  mergeStart: 10.8,
  mergeStep: 1.0,
  tapGrosir: 16.6,
  tapSemua: 18.4,
  /** Scene 6 — mode belanja. */
  tapMulai: 19.6,
  toShop: 20.0,
  checks: [20.9, 22.2, 23.5, 24.8, 26.1],
  tapSelesai: 28.4,
  /** Scene 8 — riwayat dan widget. */
  toHistory: 36.2,
  tapSalin: 37.4,
  toHome: 38.3,
  widgetPop: 38.8,
} as const;

const useSec = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  return {frame, fps, at: (sec: number) => s(sec, fps)};
};

/**
 * Masuk dengan spring pada detik tertentu.
 * Bukan hook — dipanggil di dalam `.map()`, jadi frame/fps dioper dari luar.
 */
const inAt = (frame: number, fps: number, sec: number, preset = SPRING.gentle) =>
  spring({frame: frame - s(sec, fps), fps, config: preset});

const Row: React.FC<{children: React.ReactNode; style?: React.CSSProperties}> = ({
  children,
  style,
}) => <div style={{display: 'flex', alignItems: 'center', ...style}}>{children}</div>;

/* ------------------------------------------------------------------ */
/* 1. Layar Minggu Ini                                                 */
/* ------------------------------------------------------------------ */

/** Posisi kartu hari di dalam layar — dipakai juga oleh chip yang terbang. */
export const DAY_Y = (i: number) => 196 + i * 62;
export const SABTU_I = 5;
export const MINGGU_I = 6;

export const ScreenWeek: React.FC = () => {
  const {frame, fps} = useSec();

  // Sabtu terisi setelah chip mendarat; Minggu dimatikan setelah di-tap.
  const sabtuFilled = frame >= s(T.chipsLand, fps);
  const mingguOff = frame >= s(T.tapLibur, fps);
  const hari = interpolate(
    frame,
    [s(T.rollSummary, fps), s(T.rollSummary + 0.5, fps)],
    [DATA.summary.before, DATA.summary.after],
    CLAMP,
  );

  return (
    <div style={{width: SCREEN_W, height: '100%', position: 'relative'}}>
      <div style={{padding: '26px 18px 10px'}}>
        <div style={{fontSize: 12, fontWeight: 700, color: BC.muted, letterSpacing: 0.6}}>
          MINGGU INI
        </div>
        <Row style={{justifyContent: 'space-between', marginTop: 2}}>
          <span style={{fontFamily: TITLE_FONT, fontSize: 26, color: BC.arang}}>
            {DATA.weekRange}
          </span>
          <span style={{color: BC.muted, fontSize: 20}}>‹ ›</span>
        </Row>
      </div>

      {/* Ringkasan dengan maskot kecil. */}
      <div style={{padding: '0 18px'}}>
        <Row style={{background: BC.daun, borderRadius: 16, padding: 12, gap: 10}}>
          <Mascot size={46} steam="none" eyes="happy" motion="bob" body={BC.pandan} />
          <div style={{color: BC.white}}>
            <Row style={{gap: 5, fontWeight: 800, fontSize: 17}}>
              <Rolling value={Math.round(hari)} size={17} color={BC.white} font="inherit" />
              <span>hari masak</span>
            </Row>
            <div style={{fontSize: 12, opacity: 0.85, marginTop: 2}}>
              {DATA.weekRange} · {sabtuFilled ? 11 : 9} menu
            </div>
          </div>
        </Row>
      </div>

      {/* Tujuh kartu hari. */}
      <div style={{position: 'absolute', left: 18, right: 18, top: DAY_Y(0) - 8}}>
        {DATA.days.map((d, i) => {
          const e = inAt(frame, fps, 0.15 + i * 0.07);
          const isSabtu = i === SABTU_I;
          const isMinggu = i === MINGGU_I;
          const items = isSabtu && sabtuFilled ? DATA.sheetPicks : [...d.items];
          const off = isMinggu && mingguOff;
          const dim = off || (items.length === 0 && !off);

          return (
            <div
              key={d.day}
              style={{
                height: 54,
                marginBottom: 8,
                borderRadius: 13,
                background: BC.white,
                border: d.today ? `2px solid ${BC.pandan}` : `1px solid ${BC.line}`,
                padding: '8px 11px',
                opacity: e * (dim ? 0.5 : 1),
                transform: `translateY(${(1 - e) * 14}px)`,
                boxSizing: 'border-box',
              }}
            >
              <Row style={{gap: 7}}>
                <div
                  style={{
                    width: 15,
                    height: 15,
                    borderRadius: 4,
                    border: `2px solid ${off ? BC.line : BC.pandan}`,
                    background: off ? 'transparent' : BC.pandan,
                    flexShrink: 0,
                  }}
                />
                <span style={{fontWeight: 800, fontSize: 15, color: BC.arang}}>{d.day}</span>
                {d.today ? (
                  <span
                    style={{
                      fontSize: 10,
                      fontWeight: 700,
                      padding: '2px 7px',
                      borderRadius: 999,
                      background: BC.greenSoft,
                      color: BC.greenText,
                    }}
                  >
                    Hari ini
                  </span>
                ) : null}
                {off ? (
                  <span style={{marginLeft: 'auto', fontSize: 15, color: BC.muted}}>zz</span>
                ) : null}
              </Row>
              <Row style={{gap: 5, marginTop: 5, flexWrap: 'wrap'}}>
                {items.length ? (
                  items.map((it) => (
                    <span
                      key={it}
                      style={{
                        fontSize: 11,
                        fontWeight: 700,
                        padding: '3px 8px',
                        borderRadius: 999,
                        background: BC.greenSoft,
                        color: BC.greenText,
                      }}
                    >
                      {it}
                    </span>
                  ))
                ) : (
                  <span style={{fontSize: 11, color: BC.muted}}>+ Tambah menu</span>
                )}
              </Row>
            </div>
          );
        })}
      </div>

      <BottomButton label="Generate daftar belanja" pressAt={T.tapGenerate} />
      <PickSheet />
    </div>
  );
};

/** Bottom sheet pemilih menu — naik saat "+ Tambah menu" ditekan. */
const PickSheet: React.FC = () => {
  const {frame, fps} = useSec();
  const up = spring({
    frame: frame - s(T.sheetUp, fps),
    fps,
    config: SPRING.snappy,
    durationInFrames: s(0.45, fps),
  });
  const down = spring({
    frame: frame - s(T.sheetDown, fps),
    fps,
    config: SPRING.snappy,
    durationInFrames: s(0.4, fps),
  });
  const shown = up - down;
  if (shown <= 0.01) return null;

  const H = 420;
  return (
    <div
      style={{
        position: 'absolute',
        left: 0,
        right: 0,
        bottom: 0,
        height: H,
        background: BC.white,
        borderRadius: '22px 22px 0 0',
        boxShadow: '0 -14px 40px rgba(27,42,33,0.2)',
        transform: `translateY(${(1 - shown) * H}px)`,
        padding: '14px 18px',
      }}
    >
      <div
        style={{
          width: 40,
          height: 4,
          borderRadius: 999,
          background: BC.line,
          margin: '0 auto 14px',
        }}
      />
      <div style={{fontFamily: TITLE_FONT, fontSize: 20, color: BC.arang}}>
        Sabtu mau masak apa?
      </div>

      <div style={{marginTop: 14, display: 'flex', flexDirection: 'column', gap: 9}}>
        {['Sate taichan', 'Es buah', 'Nasi goreng', 'Perkedel'].map((name, i) => {
          const pickAt = i === 0 ? T.pick1 : i === 1 ? T.pick2 : null;
          const on = pickAt !== null && frame >= s(pickAt, fps);
          const pop = pickAt === null ? 0 : spring({
            frame: frame - s(pickAt, fps),
            fps,
            config: SPRING.snappy,
            durationInFrames: s(0.3, fps),
          });
          return (
            <Row
              key={name}
              style={{
                gap: 10,
                padding: '10px 12px',
                borderRadius: 12,
                border: `1px solid ${on ? BC.pandan : BC.line}`,
                background: on ? BC.greenSoft : BC.white,
              }}
            >
              <div
                style={{
                  width: 20,
                  height: 20,
                  borderRadius: 6,
                  border: `2px solid ${on ? BC.pandan : BC.line}`,
                  background: on ? BC.pandan : 'transparent',
                  transform: `scale(${1 + pop * 0.25 * (1 - pop)})`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                {on ? (
                  <svg width={13} height={13} viewBox="0 0 24 24">
                    <path
                      d="M5 13 L10 18 L19 7"
                      stroke={BC.white}
                      strokeWidth={3.6}
                      fill="none"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                ) : null}
              </div>
              <span style={{fontSize: 15, fontWeight: 700, color: BC.arang}}>{name}</span>
            </Row>
          );
        })}
      </div>

      <div
        style={{
          position: 'absolute',
          left: 18,
          right: 18,
          bottom: 18,
          background: BC.pandan,
          color: BC.white,
          borderRadius: 14,
          padding: '13px 0',
          textAlign: 'center',
          fontWeight: 800,
          fontSize: 15,
        }}
      >
        Tambahkan 2 menu
      </div>
    </div>
  );
};

/** Tombol utama di dasar layar, mengecil sedikit saat ditekan. */
const BottomButton: React.FC<{label: string; pressAt: number; color?: string}> = ({
  label,
  pressAt,
  color = BC.pandan,
}) => {
  const {frame, fps} = useSec();
  const press = interpolate(
    frame,
    [s(pressAt - 0.06, fps), s(pressAt, fps), s(pressAt + 0.14, fps)],
    [1, 0.97, 1],
    CLAMP,
  );
  return (
    <div
      style={{
        position: 'absolute',
        left: 18,
        right: 18,
        bottom: 20,
        background: color,
        color: BC.white,
        borderRadius: 15,
        padding: '15px 0',
        textAlign: 'center',
        fontWeight: 800,
        fontSize: 16,
        transform: `scale(${press})`,
      }}
    >
      {label}
    </div>
  );
};

/* ------------------------------------------------------------------ */
/* 2. Layar Daftar belanja                                             */
/* ------------------------------------------------------------------ */

export const LIST_ROW_Y = (i: number) => 212 + i * 66;

export const ScreenList: React.FC = () => {
  const {frame, fps} = useSec();

  // Filter grosir: baris non-grosir mengkerut.
  const grosir = interpolate(
    frame,
    [s(T.tapGrosir, fps), s(T.tapGrosir + 0.4, fps), s(T.tapSemua, fps), s(T.tapSemua + 0.4, fps)],
    [0, 1, 1, 0],
    CLAMP,
  );

  return (
    <div style={{width: SCREEN_W, height: '100%', position: 'relative'}}>
      <div style={{padding: '26px 18px 10px'}}>
        <div style={{fontSize: 12, fontWeight: 700, color: BC.muted, letterSpacing: 0.6}}>
          DAFTAR BELANJA
        </div>
        <Row style={{justifyContent: 'space-between', marginTop: 2}}>
          <span style={{fontFamily: TITLE_FONT, fontSize: 26, color: BC.arang}}>
            {DATA.weekRange}
          </span>
          <span style={{fontSize: 13, color: BC.muted, fontWeight: 700}}>5 bahan</span>
        </Row>
      </div>

      {/* Pill filter dengan indikator yang bergeser. */}
      <div style={{padding: '0 18px', position: 'relative'}}>
        <Row style={{gap: 8, position: 'relative'}}>
          <div
            style={{
              position: 'absolute',
              left: interpolate(grosir, [0, 1], [0, 74], CLAMP),
              top: 0,
              width: interpolate(grosir, [0, 1], [70, 68], CLAMP),
              height: 30,
              borderRadius: 999,
              background: BC.pandan,
            }}
          />
          {['Semua 5', 'Grosir 1'].map((t, i) => (
            <div
              key={t}
              style={{
                position: 'relative',
                width: i === 0 ? 70 : 68,
                height: 30,
                borderRadius: 999,
                background: BC.pill,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: 12,
                fontWeight: 700,
                color: (i === 0 ? grosir < 0.5 : grosir >= 0.5) ? BC.white : BC.muted,
                zIndex: 1,
                backgroundColor: 'transparent',
              }}
            >
              {t}
            </div>
          ))}
        </Row>
      </div>

      {/* Baris bahan — angkanya berputar saat bahan dari menu lain mendarat. */}
      <div style={{position: 'absolute', left: 18, right: 18, top: LIST_ROW_Y(0) - 10}}>
        {DATA.list.map((it, i) => {
          const e = inAt(frame, fps, T.toList - 0.2 + i * 0.07);
          const landAt = T.mergeStart + i * T.mergeStep;
          const land = spring({
            frame: frame - s(landAt, fps),
            fps,
            config: SPRING.snappy,
            durationInFrames: s(0.4, fps),
          });
          const value = interpolate(
            frame,
            [s(landAt, fps), s(landAt + 0.55, fps)],
            [it.from, it.to],
            CLAMP,
          );
          // Denyut hijau muda tepat saat chip mendarat.
          const pulse = interpolate(
            frame,
            [s(landAt, fps), s(landAt + 0.18, fps), s(landAt + 0.7, fps)],
            [0, 1, 0],
            CLAMP,
          );
          const isGrosir = it.cara === 'Grosir';
          const collapse = isGrosir ? 0 : grosir;
          const h = interpolate(collapse, [0, 1], [58, 0], CLAMP);

          return (
            <div
              key={it.name}
              style={{
                height: h,
                marginBottom: interpolate(collapse, [0, 1], [8, 0], CLAMP),
                opacity: e * (1 - collapse),
                transform: `translateY(${(1 - e) * 14}px) scale(${1 + land * 0.03 * (1 - land)})`,
                overflow: 'hidden',
              }}
            >
              <Row
                style={{
                  height: 58,
                  borderRadius: 13,
                  background: `rgb(${255 - pulse * 28}, ${255 - pulse * 10}, ${255 - pulse * 24})`,
                  border: `1px solid ${pulse > 0.2 ? BC.pandan : BC.line}`,
                  padding: '0 11px',
                  gap: 10,
                  boxSizing: 'border-box',
                }}
              >
                <div
                  style={{
                    width: 20,
                    height: 20,
                    borderRadius: 6,
                    border: `2px solid ${BC.line}`,
                    flexShrink: 0,
                  }}
                />
                <div style={{flex: 1}}>
                  <Row style={{gap: 4, fontWeight: 800, fontSize: 15, color: BC.arang}}>
                    <span>{it.name}</span>
                    <span>—</span>
                    <Rolling value={value} size={15} color={BC.arang} font="inherit" />
                    <span>{it.unit}</span>
                  </Row>
                  <div style={{fontSize: 11, color: BC.muted, marginTop: 2}}>{it.toko}</div>
                </div>
                <span
                  style={{
                    fontSize: 11,
                    fontWeight: 700,
                    padding: '3px 9px',
                    borderRadius: 999,
                    background: isGrosir ? BC.orangeSoft : BC.greenSoft,
                    color: isGrosir ? BC.orangeText : BC.greenText,
                  }}
                >
                  {it.cara}
                </span>
              </Row>
            </div>
          );
        })}
      </div>

      <BottomButton label="Mulai belanja" pressAt={T.tapMulai} />
    </div>
  );
};

/* ------------------------------------------------------------------ */
/* 3. Layar Mode belanja                                               */
/* ------------------------------------------------------------------ */

export const SHOP_ROW_Y = (i: number) => 250 + i * 66;

export const ScreenShop: React.FC = () => {
  const {frame, fps} = useSec();

  const checked = T.checks.filter((c) => frame >= s(c, fps)).length;
  const progress = checked / DATA.list.length;
  const total = DATA.prices.reduce((sum, p, i) => {
    const g = interpolate(
      frame,
      [s(T.checks[i], fps), s(T.checks[i] + 0.45, fps)],
      [0, 1],
      CLAMP,
    );
    return sum + p * g;
  }, 0);

  return (
    <div style={{width: SCREEN_W, height: '100%', position: 'relative'}}>
      {/* Header hijau tua dengan troli yang melaju. */}
      <div style={{background: BC.daun, padding: '26px 18px 20px', color: BC.white}}>
        <div style={{fontSize: 12, fontWeight: 700, opacity: 0.75, letterSpacing: 0.6}}>
          MODE BELANJA
        </div>
        <Row style={{gap: 6, fontFamily: TITLE_FONT, fontSize: 24, marginTop: 4}}>
          <Rolling value={checked} size={24} color={BC.white} />
          <span>dari {DATA.list.length} item</span>
        </Row>
        <div style={{position: 'relative', marginTop: 16}}>
          <div style={{height: 7, borderRadius: 999, background: 'rgba(255,255,255,0.22)'}}>
            <div
              style={{
                height: '100%',
                width: `${progress * 100}%`,
                borderRadius: 999,
                background: BC.kunyit,
              }}
            />
          </div>
          <div style={{position: 'absolute', top: -20, left: `calc(${progress * 100}% - 13px)`}}>
            <svg width={26} height={26} viewBox="0 0 24 24" fill="none">
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
          </div>
        </div>
      </div>

      {/* Item: yang sudah dicentang turun ke bawah. */}
      <div style={{position: 'absolute', left: 18, right: 18, top: SHOP_ROW_Y(0) - 10, height: 400}}>
        {DATA.list.map((it, i) => {
          const checkAt = T.checks[i];
          const on = interpolate(
            frame,
            [s(checkAt, fps), s(checkAt + 0.25, fps)],
            [0, 1],
            CLAMP,
          );
          // Urutan baru: yang sudah dicentang pindah ke bawah daftar.
          const doneCount = T.checks.filter((c, j) => j < i && frame >= s(c, fps)).length;
          const pendingBefore = i - doneCount;
          const nDone = T.checks.filter((c) => frame >= s(c, fps)).length;
          const targetIdx = on > 0.5 ? DATA.list.length - 1 - (nDone - 1 - doneCount) : pendingBefore;
          const slide = spring({
            frame: frame - s(checkAt, fps),
            fps,
            config: SPRING.gentle,
            durationInFrames: s(0.45, fps),
          });
          const y = (on > 0.5 ? i + (targetIdx - i) * slide : i) * 66;

          const priceChars = `${DATA.prices[i].toLocaleString('id-ID')}`;
          const typed = Math.round(
            interpolate(
              frame,
              [s(checkAt + 0.1, fps), s(checkAt + 0.5, fps)],
              [0, priceChars.length],
              CLAMP,
            ),
          );

          return (
            <Row
              key={it.name}
              style={{
                position: 'absolute',
                left: 0,
                right: 0,
                top: y,
                height: 58,
                borderRadius: 13,
                background: BC.white,
                border: `1px solid ${on > 0.5 ? BC.greenSoft : BC.line}`,
                padding: '0 11px',
                gap: 10,
                boxSizing: 'border-box',
              }}
            >
              <div
                style={{
                  width: 24,
                  height: 24,
                  borderRadius: 7,
                  border: `2px solid ${on > 0.5 ? BC.pandan : BC.line}`,
                  background: on > 0.5 ? BC.pandan : 'transparent',
                  flexShrink: 0,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  transform: `scale(${1 + Math.sin(on * Math.PI) * 0.22})`,
                }}
              >
                <svg width={15} height={15} viewBox="0 0 24 24">
                  <path
                    d="M5 13 L10 18 L19 7"
                    stroke={BC.white}
                    strokeWidth={3.6}
                    fill="none"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeDasharray={30}
                    strokeDashoffset={30 * (1 - on)}
                  />
                </svg>
              </div>
              <div style={{flex: 1, opacity: on > 0.5 ? 0.55 : 1}}>
                <div
                  style={{
                    fontWeight: 800,
                    fontSize: 15,
                    color: BC.arang,
                    textDecoration: on > 0.5 ? 'line-through' : 'none',
                  }}
                >
                  {it.name}
                </div>
                <div style={{fontSize: 11, color: BC.muted, marginTop: 2}}>
                  {it.to} {it.unit} · {it.toko}
                </div>
              </div>
              <div
                style={{
                  minWidth: 74,
                  textAlign: 'right',
                  borderBottom: `1.5px solid ${typed > 0 ? BC.pandan : BC.line}`,
                  paddingBottom: 2,
                  fontWeight: 800,
                  fontSize: 15,
                  color: typed > 0 ? BC.arang : BC.line,
                }}
              >
                Rp {typed > 0 ? priceChars.slice(0, typed) : '—'}
              </div>
            </Row>
          );
        })}
      </div>

      {/* Total odometer. */}
      <div
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          bottom: 0,
          padding: '14px 18px 20px',
          background: BC.white,
          borderTop: `1px solid ${BC.line}`,
        }}
      >
        <Row style={{justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 12}}>
          <span style={{fontSize: 13, color: BC.muted, fontWeight: 700}}>Total</span>
          <Rolling value={total} prefix="Rp " size={26} />
        </Row>
        <BottomButtonInline label="Selesai" pressAt={T.tapSelesai} />
      </div>
    </div>
  );
};

const BottomButtonInline: React.FC<{label: string; pressAt: number}> = ({label, pressAt}) => {
  const {frame, fps} = useSec();
  const press = interpolate(
    frame,
    [s(pressAt - 0.06, fps), s(pressAt, fps), s(pressAt + 0.14, fps)],
    [1, 0.97, 1],
    CLAMP,
  );
  return (
    <div
      style={{
        background: BC.pandan,
        color: BC.white,
        borderRadius: 15,
        padding: '14px 0',
        textAlign: 'center',
        fontWeight: 800,
        fontSize: 16,
        transform: `scale(${press})`,
      }}
    >
      {label}
    </div>
  );
};

/* ------------------------------------------------------------------ */
/* 4. Layar Riwayat                                                    */
/* ------------------------------------------------------------------ */

export const HISTORY_SALIN_Y = 268;

export const ScreenHistory: React.FC = () => {
  const {frame, fps} = useSec();
  const glow = interpolate(
    frame,
    [s(T.tapSalin, fps), s(T.tapSalin + 0.2, fps), s(T.tapSalin + 1.1, fps)],
    [0, 1, 0],
    CLAMP,
  );

  return (
    <div style={{width: SCREEN_W, height: '100%', position: 'relative'}}>
      <div style={{padding: '26px 18px 10px'}}>
        <div style={{fontSize: 12, fontWeight: 700, color: BC.muted, letterSpacing: 0.6}}>
          RIWAYAT
        </div>
        <div style={{fontFamily: TITLE_FONT, fontSize: 26, color: BC.arang, marginTop: 2}}>
          Oktober
        </div>
      </div>

      <div style={{padding: '0 18px'}}>
        <div style={{background: BC.daun, borderRadius: 16, padding: 14, color: BC.white}}>
          <div style={{fontSize: 11, fontWeight: 700, opacity: 0.7}}>BULAN INI</div>
          <Rolling value={DATA.grandTotal} prefix="Rp " size={30} color={BC.white} />
          <div style={{fontSize: 12, opacity: 0.75, marginTop: 2}}>1 kali belanja</div>
        </div>
      </div>

      <div style={{position: 'absolute', left: 18, right: 18, top: 236}}>
        {DATA.history.map((h, i) => {
          const e = inAt(frame, fps, T.toHistory - 0.1 + i * 0.09);
          const hot = i === 0 ? glow : 0;
          return (
            <div
              key={h.range}
              style={{
                marginBottom: 10,
                borderRadius: 14,
                background: BC.white,
                border: `${hot > 0.2 ? 2 : 1}px solid ${hot > 0.2 ? BC.pandan : BC.line}`,
                padding: 12,
                opacity: e,
                transform: `translateY(${(1 - e) * 14}px) scale(${1 + hot * 0.02})`,
                boxSizing: 'border-box',
              }}
            >
              <Row style={{justifyContent: 'space-between'}}>
                <div>
                  <div style={{fontWeight: 800, fontSize: 15, color: BC.arang}}>{h.range}</div>
                  <div style={{fontSize: 11, color: BC.muted, marginTop: 2}}>
                    {h.info} · {h.total}
                  </div>
                </div>
                <span
                  style={{
                    fontSize: 11,
                    fontWeight: 800,
                    padding: '7px 12px',
                    borderRadius: 999,
                    background: hot > 0.2 ? BC.pandan : BC.greenSoft,
                    color: hot > 0.2 ? BC.white : BC.greenText,
                  }}
                >
                  Salin ke minggu ini
                </span>
              </Row>
            </div>
          );
        })}
      </div>
    </div>
  );
};

/* ------------------------------------------------------------------ */
/* 5. Home screen dengan widget                                        */
/* ------------------------------------------------------------------ */

export const ScreenHome: React.FC = () => {
  const {frame, fps} = useSec();
  const pop = spring({
    frame: frame - s(T.widgetPop, fps),
    fps,
    config: SPRING.bouncy,
    durationInFrames: s(0.7, fps),
  });
  const ring = interpolate(
    frame,
    [s(T.widgetPop + 0.2, fps), s(T.widgetPop + 1.2, fps)],
    [0, 1],
    {...CLAMP, easing: EASE.in},
  );
  const R = 17;
  const C = 2 * Math.PI * R;

  return (
    <div
      style={{
        width: SCREEN_W,
        height: '100%',
        position: 'relative',
        background: `linear-gradient(160deg, ${BC.daun} 0%, #2b5a41 60%, ${BC.pandan} 100%)`,
      }}
    >
      {/* Deretan ikon home screen. */}
      <div
        style={{
          position: 'absolute',
          left: 22,
          right: 22,
          top: 60,
          display: 'grid',
          gridTemplateColumns: 'repeat(4, 1fr)',
          gap: 18,
        }}
      >
        {Array.from({length: 8}).map((_, i) => (
          <div
            key={i}
            style={{
              height: 54,
              borderRadius: 14,
              background: 'rgba(255,255,255,0.14)',
            }}
          />
        ))}
      </div>

      {/* Widget 4×2. */}
      <div
        style={{
          position: 'absolute',
          left: 22,
          right: 22,
          top: 260,
          background: BC.white,
          borderRadius: 20,
          padding: 14,
          opacity: Math.min(1, pop * 1.4),
          transform: `scale(${0.8 + pop * 0.2})`,
          boxShadow: '0 18px 44px rgba(0,0,0,0.3)',
        }}
      >
        <Row style={{justifyContent: 'space-between', alignItems: 'center'}}>
          <div>
            <div style={{fontFamily: TITLE_FONT, fontSize: 17, color: BC.arang}}>
              Rabu · Soto ayam
            </div>
            <div style={{fontSize: 11, color: BC.muted, marginTop: 3}}>
              Kam · Ikan bakar
            </div>
          </div>
          {/* Lingkaran progres belanja. */}
          <svg width={44} height={44} viewBox="0 0 44 44">
            <circle cx={22} cy={22} r={R} stroke={BC.lineSoft} strokeWidth={5} fill="none" />
            <circle
              cx={22}
              cy={22}
              r={R}
              stroke={BC.pandan}
              strokeWidth={5}
              fill="none"
              strokeLinecap="round"
              strokeDasharray={C}
              strokeDashoffset={C * (1 - ring)}
              transform="rotate(-90 22 22)"
            />
          </svg>
        </Row>
        <div
          style={{
            marginTop: 10,
            display: 'inline-block',
            fontSize: 11,
            fontWeight: 700,
            padding: '5px 11px',
            borderRadius: 999,
            background: BC.greenSoft,
            color: BC.greenText,
          }}
        >
          Belanja sudah beres ✓
        </div>
      </div>
    </div>
  );
};
