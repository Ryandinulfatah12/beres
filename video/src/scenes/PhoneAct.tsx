import React from 'react';
import {interpolate, random, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT, usePick} from '../theme';
import {CLAMP, EASE, s, SPRING} from '../motion';
import {COPY, DATA, type Audience} from '../copy';
import {Backdrop, Card} from '../components/ui';
import {Kinetic, Sub, Rolling, Toast} from '../components/text';
import {TapCursor, tapShake, type Tap} from '../components/TapCursor';
import {MascotGuide} from '../components/Guide';
import {Mascot} from '../components/Mascot';
import {
  PhoneFrame,
  ScreenStrip,
  SCREEN_H,
  SCREEN_W,
  type ScreenSwitch,
} from '../components/Phone';
import {
  ScreenWeek,
  ScreenList,
  ScreenShop,
  ScreenHistory,
  ScreenHome,
  T,
  LIST_ROW_Y,
} from '../components/screens';

/**
 * Scene 4–8 — babak phone (14–55 dtk), satu bidikan panjang.
 *
 * Satu phone hidup dari awal sampai akhir babak dan tidak pernah keluar layar.
 * Yang berganti adalah isi layarnya (slide horizontal, seperti navigasi app),
 * sementara phone-nya sendiri bergeser dan di-zoom antar bagian.
 */

/** Pergantian layar di dalam phone. */
const SWITCHES: ScreenSwitch[] = [
  {at: 0, to: 'week'},
  {at: T.toList, to: 'list'},
  {at: T.toShop, to: 'shop'},
  {at: T.toHistory, to: 'history'},
  {at: T.toHome, to: 'home'},
];

/** Semua tap, dalam koordinat layar app (390×844). */
const TAPS_SCREEN: {at: number; sx: number; sy: number}[] = [
  {at: T.tapTambah, sx: 70, sy: 536},
  {at: T.pick1, sx: 100, sy: 514},
  {at: T.pick2, sx: 100, sy: 563},
  {at: T.tapAdd, sx: 195, sy: 805},
  {at: T.tapLibur, sx: 38, sy: 576},
  {at: T.tapGenerate, sx: 195, sy: 801},
  {at: T.tapGrosir, sx: 126, sy: 95},
  {at: T.tapSemua, sx: 53, sy: 95},
  {at: T.tapMulai, sx: 195, sy: 801},
  // Item yang dicentang selalu berada di baris paling atas, karena yang
  // sudah diambil langsung turun ke bawah daftar.
  ...T.checks.map((at) => ({at, sx: 41, sy: 269})),
  {at: T.tapSelesai, sx: 195, sy: 802},
  {at: T.tapSalin, sx: 310, sy: 268},
];

type Geo = {at: number; x: number; y: number; scale: number};

export const PhoneAct: React.FC<{audience: Audience; bpm: number; beatOffset: number}> = ({
  audience,
  bpm,
  beatOffset,
}) => {
  const frame = useCurrentFrame();
  const {fps, width, height} = useVideoConfig();
  const pick = usePick();

  const phoneH = pick(height * 0.88, height * 0.72);

  /** Posisi phone sepanjang babak. */
  const geo: Geo[] = pick(
    [
      {at: 0, x: width * 0.24, y: 0, scale: 1},
      {at: T.toList, x: width * 0.26, y: 0, scale: 1},
      {at: T.toShop, x: width * 0.2, y: 0, scale: 1.03},
      {at: T.tapSelesai, x: width * 0.2, y: 0, scale: 1.03},
      // Scene 7: phone mundur dan bergeser ke kanan untuk memberi ruang perayaan.
      {at: 30.6, x: width * 0.33, y: 0, scale: 0.78},
      {at: T.toHistory, x: width * 0.22, y: 0, scale: 0.95},
      {at: 41, x: width * 0.22, y: 0, scale: 0.95},
    ],
    [
      {at: 0, x: 0, y: height * 0.06, scale: 1},
      {at: T.toList, x: 0, y: height * 0.06, scale: 1},
      {at: T.toShop, x: 0, y: height * 0.05, scale: 1.02},
      {at: T.tapSelesai, x: 0, y: height * 0.05, scale: 1.02},
      {at: 30.6, x: 0, y: height * 0.1, scale: 0.78},
      {at: T.toHistory, x: 0, y: height * 0.07, scale: 0.92},
      {at: 41, x: 0, y: height * 0.07, scale: 0.92},
    ],
  );

  /** Interpolasi keyframe phone pada detik tertentu. */
  const geoAt = (sec: number) => {
    const f = s(sec, fps);
    if (f <= s(geo[0].at, fps)) return geo[0];
    for (let i = 0; i < geo.length - 1; i++) {
      const a = geo[i];
      const b = geo[i + 1];
      const fa = s(a.at, fps);
      const fb = s(b.at, fps);
      if (f >= fa && f <= fb) {
        const t = fb === fa ? 1 : EASE.in((f - fa) / (fb - fa));
        return {
          at: sec,
          x: a.x + (b.x - a.x) * t,
          y: a.y + (b.y - a.y) * t,
          scale: a.scale + (b.scale - a.scale) * t,
        };
      }
    }
    return geo[geo.length - 1];
  };

  const now = geoAt(frame / fps);

  /** Koordinat di dalam layar app → koordinat frame, mengikuti posisi phone. */
  const toFrame = (sx: number, sy: number, sec: number) => {
    const g = geoAt(sec);
    const sc = (phoneH / SCREEN_H) * g.scale;
    return {
      x: width / 2 + g.x + (sx - SCREEN_W / 2) * sc,
      y: height / 2 + g.y + (sy - SCREEN_H / 2) * sc,
    };
  };

  const taps: Tap[] = TAPS_SCREEN.map((t) => {
    const p = toFrame(t.sx, t.sy, t.at);
    return {at: t.at, x: p.x, y: p.y};
  });

  // Getaran haptic halus pada phone setiap kali ada tap.
  const shake = TAPS_SCREEN.reduce((acc, t) => acc + tapShake(frame, fps, t.at), 0);

  // Teks di sisi kiri (landscape) atau di atas (vertical).
  const textX = pick(width * 0.055, width * 0.07);
  const textW = pick(width * 0.4, width * 0.86);
  const textY = pick(height * 0.3, height * 0.05);
  /** Bagian "Bahan dijumlahkan" perlu judul lebih tinggi. */
  const mergeTextY = pick(height * 0.1, height * 0.05);

  return (
    <div style={{position: 'absolute', inset: 0}}>
      <Backdrop bpm={bpm} beatOffset={beatOffset} />

      {/* Kartu menu yang mengirim bahan ke daftar belanja (scene 5). */}
      <MergeChips toFrame={toFrame} phoneH={phoneH} />

      {/* Phone — satu-satunya, hidup sepanjang babak. */}
      <PhoneFrame height={phoneH} x={now.x} y={now.y} scale={now.scale} shake={shake}>
        <ScreenStrip
          switches={SWITCHES}
          screens={{
            week: <ScreenWeek />,
            list: <ScreenList />,
            shop: <ScreenShop />,
            history: <ScreenHistory />,
            home: <ScreenHome />,
          }}
        />
      </PhoneFrame>

      {/* Judul tiap bagian. */}
      <div style={{position: 'absolute', left: textX, top: textY, width: textW}}>
        <Kinetic text={COPY.plan.headline} at={0.4} out={8.8} size={pick(72, 60)} />
        <div style={{marginTop: 18}}>
          <Sub text={COPY.plan.sub} at={0.75} out={8.7} size={pick(30, 27)} />
        </div>
      </div>
      {/* Judul bagian ini naik ke atas: kolom kirinya dipakai kartu menu. */}
      <div style={{position: 'absolute', left: textX, top: mergeTextY, width: textW}}>
        <Kinetic text={COPY.merge.headline} at={10.3} out={18.9} size={pick(64, 56)} />
        <div style={{marginTop: 14}}>
          <Sub text={COPY.merge.sub} at={10.65} out={18.8} size={pick(28, 25)} />
        </div>
      </div>
      <div style={{position: 'absolute', left: textX, top: textY, width: textW}}>
        <Kinetic text={COPY.shop.headline} at={20.3} out={28.0} size={pick(72, 60)} />
        <div style={{marginTop: 18}}>
          <Sub text={COPY.shop.sub} at={20.65} out={27.9} size={pick(30, 27)} />
        </div>
      </div>
      <div style={{position: 'absolute', left: textX, top: textY, width: textW}}>
        <Kinetic text={COPY.history.headline} at={36.4} size={pick(66, 56)} />
        <div style={{marginTop: 18}}>
          <Sub text={COPY.history.sub} at={36.75} size={pick(30, 27)} />
        </div>
      </div>

      {/* Scene 7 — perayaan. */}
      <Celebration audience={audience} toFrame={toFrame} />

      {/* Toast setelah menu disalin. */}
      <div
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          top: height / 2 + (phoneH / 2) * geoAt(T.tapSalin).scale + pick(34, 30),
          display: 'flex',
          justifyContent: 'center',
          transform: `translateX(${geoAt(T.tapSalin).x}px)`,
        }}
      >
        <Toast text={COPY.history.toast} at={T.tapSalin + 0.25} />
      </div>

      {/* Caption widget. */}
      <div style={{position: 'absolute', left: textX, top: textY + pick(220, 200), width: textW}}>
        <Sub text={COPY.history.widget} at={T.widgetPop - 0.35} size={pick(28, 25)} />
      </div>

      {/* Kartu teknis — hanya untuk audiens developer. */}
      {audience === 'developer' ? <DevCards /> : null}

      {/* Si Beres memandu: berpindah mengikuti bagian yang sedang dibahas. */}
      <MascotGuide
        poses={[
          {
            at: 0,
            x: pick(width * 0.12, width * 0.14),
            y: pick(height * 0.78, height * 0.3),
            size: pick(170, 140),
            steam: 'none',
            eyes: 'up',
            motion: 'bob',
          },
          {
            // Di bawah, di antara kartu menu dan phone — kolom kiri sudah penuh.
            at: 9.9,
            x: pick(width * 0.47, width * 0.84),
            y: pick(height * 0.86, height * 0.24),
            size: pick(150, 125),
            steam: 'question',
            eyes: 'up',
            motion: 'bob',
          },
          {
            at: 19.9,
            x: pick(width * 0.11, width * 0.14),
            y: pick(height * 0.8, height * 0.3),
            size: pick(165, 140),
            steam: 'none',
            eyes: 'open',
            motion: 'bob',
          },
          {
            at: 30.2,
            x: pick(width * 0.3, width * 0.5),
            y: pick(height * 0.52, height * 0.3),
            size: pick(250, 210),
            steam: 'check',
            eyes: 'happy',
            motion: 'jump',
            arc: 160,
          },
          {
            at: 36.1,
            x: pick(width * 0.13, width * 0.14),
            y: pick(height * 0.76, height * 0.3),
            size: pick(165, 135),
            steam: 'check',
            eyes: 'happy',
            motion: 'bob',
          },
        ]}
      />

      <TapCursor taps={taps} size={pick(62, 58)} />
    </div>
  );
};

/* ------------------------------------------------------------------ */
/* Scene 5 — kartu menu yang mengirim bahan ke daftar belanja           */
/* ------------------------------------------------------------------ */

const MergeChips: React.FC<{
  toFrame: (sx: number, sy: number, sec: number) => {x: number; y: number};
  phoneH: number;
}> = ({toFrame}) => {
  const frame = useCurrentFrame();
  const {fps, width, height} = useVideoConfig();
  const pick = usePick();

  const show = interpolate(
    frame,
    [s(T.toList - 0.3, fps), s(T.toList + 0.4, fps), s(T.tapGrosir - 0.6, fps), s(T.tapGrosir, fps)],
    [0, 1, 1, 0],
    CLAMP,
  );
  if (show <= 0.01) return null;

  const cardX = pick(width * 0.055, width * 0.06);
  const cardW = pick(width * 0.2, width * 0.36);
  const cardY = (i: number) => pick(height * 0.42, height * 0.52) + i * pick(150, 120);

  return (
    <div style={{position: 'absolute', inset: 0, opacity: show}}>
      {/* Tiga kartu menu sumber. */}
      {DATA.dishes.map((d, i) => (
        <div
          key={d.name}
          style={{
            position: 'absolute',
            left: cardX,
            top: cardY(i),
            width: cardW,
          }}
        >
          <Card pad={pick(16, 14)}>
            <div
              style={{
                fontWeight: 800,
                fontSize: pick(22, 20),
                color: BC.arang,
                marginBottom: 6,
              }}
            >
              {d.name}
            </div>
            {d.items.map((it) => (
              <div key={it} style={{fontSize: pick(16, 15), color: BC.muted, padding: '2px 0'}}>
                {it}
              </div>
            ))}
          </Card>
        </div>
      ))}

      {/* Chip bahan terbang lewat kurva bezier ke baris di dalam phone. */}
      {DATA.list.map((it, i) => {
        const landAt = T.mergeStart + i * T.mergeStep;
        const flyStart = landAt - 0.65;
        const t = interpolate(frame, [s(flyStart, fps), s(landAt, fps)], [0, 1], {
          ...CLAMP,
          easing: EASE.in,
        });
        if (t <= 0 || t >= 1) return null;

        const src = {
          x: cardX + cardW * 0.8,
          y: cardY(i % 3) + pick(44, 38),
        };
        const rowY = LIST_ROW_Y(0) - 10 + i * 66 + 29;
        const dst = toFrame(SCREEN_W * 0.4, rowY, landAt);

        // Kurva: titik kontrol diangkat ke atas supaya lintasannya melengkung.
        const ctrl = {x: (src.x + dst.x) / 2, y: Math.min(src.y, dst.y) - pick(140, 110)};
        const u = 1 - t;
        const x = u * u * src.x + 2 * u * t * ctrl.x + t * t * dst.x;
        const y = u * u * src.y + 2 * u * t * ctrl.y + t * t * dst.y;

        return (
          <div
            key={it.name}
            style={{
              position: 'absolute',
              left: x,
              top: y,
              transform: `translate(-50%, -50%) scale(${1 - t * 0.35})`,
              opacity: interpolate(t, [0, 0.12, 0.85, 1], [0, 1, 1, 0], CLAMP),
              padding: '8px 16px',
              borderRadius: 999,
              background: BC.pandan,
              color: BC.white,
              fontFamily: BODY_FONT,
              fontWeight: 800,
              fontSize: pick(19, 17),
              whiteSpace: 'nowrap',
              boxShadow: '0 10px 24px rgba(27,42,33,0.25)',
            }}
          >
            {it.name}
          </div>
        );
      })}
    </div>
  );
};

/* ------------------------------------------------------------------ */
/* Scene 7 — perayaan                                                   */
/* ------------------------------------------------------------------ */

const CONFETTI = new Array(30).fill(0).map((_, i) => ({
  i,
  ang: (i / 30) * Math.PI * 2 + random(`a${i}`) * 0.4,
  speed: 420 + random(`v${i}`) * 520,
  size: 12 + random(`s${i}`) * 16,
  color: [BC.kunyit, BC.cabai, BC.pandan, BC.blush, BC.kunyitDark][i % 5],
  spin: (random(`r${i}`) - 0.5) * 900,
  delay: random(`d${i}`) * 0.12,
}));

const Celebration: React.FC<{
  audience: Audience;
  toFrame: (sx: number, sy: number, sec: number) => {x: number; y: number};
}> = ({toFrame}) => {
  const frame = useCurrentFrame();
  const {fps, width, height} = useVideoConfig();
  const pick = usePick();

  const burstAt = T.tapSelesai;
  const origin = toFrame(195, 802, burstAt);

  const show = interpolate(
    frame,
    [s(30.0, fps), s(30.5, fps), s(35.4, fps), s(35.9, fps)],
    [0, 1, 1, 0],
    CLAMP,
  );

  // Dua cincin kuning yang melebar dari maskot.
  const ringT = (d: number) =>
    interpolate(frame, [s(30.2 + d, fps), s(31.4 + d, fps)], [0, 1], {
      ...CLAMP,
      easing: EASE.in,
    });
  const mascotX = pick(width * 0.3, width * 0.5);
  const mascotY = pick(height * 0.52, height * 0.3);

  return (
    <>
      {/* Confetti meledak dari tombol Selesai. */}
      <div style={{position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none'}}>
        {CONFETTI.map((c) => {
          const t = (frame - s(burstAt + c.delay, fps)) / fps;
          if (t < 0 || t > 3.4) return null;
          const x = origin.x + Math.cos(c.ang) * c.speed * t;
          const y = origin.y + Math.sin(c.ang) * c.speed * t + 420 * t * t;
          if (y > height + 80) return null;
          return (
            <div
              key={c.i}
              style={{
                position: 'absolute',
                left: x,
                top: y,
                width: c.size,
                height: c.size * 0.6,
                borderRadius: 3,
                background: c.color,
                transform: `rotate(${c.spin * t}deg)`,
                opacity: interpolate(t, [0, 0.1, 2.4, 3.3], [0, 1, 1, 0], CLAMP),
              }}
            />
          );
        })}
      </div>

      {show > 0.01 ? (
        <div style={{position: 'absolute', inset: 0, opacity: show}}>
          {/* Cincin dari maskot. */}
          {[0, 0.22].map((d) => {
            const t = ringT(d);
            if (t <= 0 || t >= 1) return null;
            const r = t * pick(320, 280);
            return (
              <div
                key={d}
                style={{
                  position: 'absolute',
                  left: mascotX - r,
                  top: mascotY - r,
                  width: r * 2,
                  height: r * 2,
                  borderRadius: '50%',
                  border: `4px solid ${BC.kunyit}`,
                  opacity: (1 - t) * 0.6,
                }}
              />
            );
          })}

          {/* Judul perayaan. */}
          <div
            style={{
              position: 'absolute',
              left: pick(width * 0.055, width * 0.07),
              top: pick(height * 0.68, height * 0.44),
              width: pick(width * 0.42, width * 0.86),
            }}
          >
            <Kinetic text={COPY.done.headline} at={30.5} size={pick(78, 64)} />
            <div style={{marginTop: 14}}>
              <Sub text={COPY.done.sub} at={30.85} size={pick(30, 27)} />
            </div>
          </div>

          {/* Ringkasan per toko, naik satu per satu. */}
          <div
            style={{
              position: 'absolute',
              left: pick(width * 0.055, width * 0.07),
              top: pick(height * 0.835, height * 0.62),
              width: pick(width * 0.34, width * 0.86),
            }}
          >
            {DATA.stores.map((st, i) => {
              const e = spring({
                frame: frame - s(31.5 + i * 0.22, fps),
                fps,
                config: SPRING.snappy,
                durationInFrames: s(0.5, fps),
              });
              return (
                <div
                  key={st.name}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'baseline',
                    padding: pick('9px 0', '7px 0'),
                    fontFamily: BODY_FONT,
                    fontSize: pick(26, 23),
                    color: BC.arang,
                    opacity: e,
                    transform: `translateY(${(1 - e) * 18}px)`,
                  }}
                >
                  <span style={{fontWeight: 600}}>{st.name}</span>
                  <Rolling value={st.total} prefix="Rp " size={pick(26, 23)} font={BODY_FONT} />
                </div>
              );
            })}
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'baseline',
                marginTop: 8,
                paddingTop: 10,
                borderTop: `2px solid ${BC.line}`,
                color: BC.greenText,
              }}
            >
              <span style={{fontFamily: TITLE_FONT, fontSize: pick(30, 26)}}>Minggu ini</span>
              <Rolling value={DATA.grandTotal} prefix="Rp " size={pick(32, 27)} color={BC.greenText} />
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
};

/* ------------------------------------------------------------------ */
/* Kartu teknis — hanya untuk audiens developer                         */
/* ------------------------------------------------------------------ */

const DevCards: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps, width, height} = useVideoConfig();
  const pick = usePick();

  const show = interpolate(
    frame,
    [s(37.4, fps), s(38.0, fps), s(40.6, fps), s(41, fps)],
    [0, 1, 1, 0],
    CLAMP,
  );
  if (show <= 0.01) return null;

  return (
    <div
      style={{
        position: 'absolute',
        left: pick(width * 0.055, width * 0.07),
        top: pick(height * 0.56, height * 0.62),
        width: pick(width * 0.4, width * 0.86),
        opacity: show,
      }}
    >
      {COPY.history.devCards.map((c, i) => {
        const e = spring({
          frame: frame - s(37.5 + i * 0.12, fps),
          fps,
          config: SPRING.snappy,
          durationInFrames: s(0.45, fps),
        });
        return (
          <div
            key={c.title}
            style={{
              marginBottom: 10,
              opacity: e,
              transform: `translateY(${(1 - e) * 16}px)`,
            }}
          >
            <Card pad={pick(16, 14)} style={{display: 'flex', alignItems: 'center', gap: 14}}>
              <div
                style={{width: 10, height: 10, borderRadius: 999, background: BC.kunyit, flexShrink: 0}}
              />
              <span style={{fontWeight: 800, fontSize: pick(22, 20), color: BC.arang}}>
                {c.title}
              </span>
              <span style={{fontSize: pick(19, 17), color: BC.muted}}>— {c.body}</span>
            </Card>
          </div>
        );
      })}
      <div style={{display: 'flex', gap: 8, marginTop: 6, flexWrap: 'wrap'}}>
        {COPY.history.devChips.map((chip) => (
          <span
            key={chip}
            style={{
              padding: '8px 16px',
              borderRadius: 999,
              border: `1px solid ${BC.pandan}`,
              color: BC.greenText,
              fontFamily: BODY_FONT,
              fontWeight: 700,
              fontSize: pick(18, 16),
            }}
          >
            {chip}
          </span>
        ))}
      </div>
    </div>
  );
};
