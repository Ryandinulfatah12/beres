import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT} from '../theme';
import {CLAMP, EASE, s, SPRING} from '../motion';

/**
 * Teks kinetik: masuk kata per kata (stagger 0,06 detik, naik 16px + fade),
 * dan keluar lebih cepat daripada masuknya.
 */
export const Kinetic: React.FC<{
  text: string;
  at?: number;
  out?: number;
  size?: number;
  color?: string;
  font?: string;
  weight?: number;
  style?: React.CSSProperties;
}> = ({
  text,
  at = 0,
  out,
  size = 72,
  color = BC.arang,
  font = TITLE_FONT,
  weight = 600,
  style,
}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const words = text.split(' ');

  const exit =
    out === undefined
      ? 1
      : interpolate(frame, [s(out, fps), s(out + 0.35, fps)], [1, 0], {
          ...CLAMP,
          easing: EASE.out,
        });
  const exitY =
    out === undefined
      ? 0
      : interpolate(frame, [s(out, fps), s(out + 0.35, fps)], [0, -22], {
          ...CLAMP,
          easing: EASE.out,
        });

  return (
    <div
      style={{
        display: 'flex',
        flexWrap: 'wrap',
        gap: `0 ${size * 0.26}px`,
        fontFamily: font,
        fontWeight: weight,
        fontSize: size,
        lineHeight: 1.1,
        color,
        opacity: exit,
        transform: `translateY(${exitY}px)`,
        ...style,
      }}
    >
      {words.map((w, i) => {
        const e = spring({
          frame: frame - s(at + i * 0.06, fps),
          fps,
          config: SPRING.gentle,
        });
        return (
          <span
            key={`${w}-${i}`}
            style={{
              display: 'inline-block',
              opacity: e,
              transform: `translateY(${(1 - e) * 16}px)`,
            }}
          >
            {w}
          </span>
        );
      })}
    </div>
  );
};

/** Subjudul satu baris, masuk sesudah headline. */
export const Sub: React.FC<{
  text: string;
  at?: number;
  out?: number;
  size?: number;
  color?: string;
  style?: React.CSSProperties;
}> = ({text, at = 0, out, size = 30, color = BC.muted, style}) => (
  <Kinetic
    text={text}
    at={at}
    out={out}
    size={size}
    color={color}
    font={BODY_FONT}
    weight={600}
    style={style}
  />
);

/**
 * Angka yang berputar seperti odometer — dipakai untuk total rupiah dan
 * ringkasan "N hari masak".
 */
export const Rolling: React.FC<{
  value: number;
  prefix?: string;
  suffix?: string;
  size?: number;
  color?: string;
  font?: string;
  style?: React.CSSProperties;
}> = ({value, prefix = '', suffix = '', size = 44, color = BC.arang, font = TITLE_FONT, style}) => {
  const digits = `${Math.round(value).toLocaleString('id-ID')}`;
  return (
    <span
      style={{
        fontFamily: font,
        fontSize: size,
        color,
        display: 'inline-flex',
        alignItems: 'baseline',
        fontVariantNumeric: 'tabular-nums',
        ...style,
      }}
    >
      {prefix ? <span style={{marginRight: size * 0.18}}>{prefix.trim()}</span> : null}
      {digits.split('').map((d, i) => (
        <Digit key={`${i}-${d}`} char={d} size={size} />
      ))}
      {suffix ? <span style={{marginLeft: size * 0.18}}>{suffix.trim()}</span> : null}
    </span>
  );
};

/** Satu kolom angka yang bergeser vertikal saat nilainya berubah. */
const Digit: React.FC<{char: string; size: number}> = ({char, size}) => {
  if (!/\d/.test(char)) return <span>{char}</span>;
  const n = Number(char);
  return (
    <span
      style={{
        display: 'inline-block',
        height: size * 1.15,
        overflow: 'hidden',
        verticalAlign: 'bottom',
      }}
    >
      <span
        style={{
          display: 'block',
          transform: `translateY(${-n * size * 1.15}px)`,
          transition: 'none',
        }}
      >
        {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((d) => (
          <span key={d} style={{display: 'block', height: size * 1.15, lineHeight: `${size * 1.15}px`}}>
            {d}
          </span>
        ))}
      </span>
    </span>
  );
};

/** Toast kecil yang muncul sesudah aksi berhasil. */
export const Toast: React.FC<{text: string; at: number; dur?: number}> = ({
  text,
  at,
  dur = 1.6,
}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const e = spring({frame: frame - s(at, fps), fps, config: SPRING.snappy});
  const o = interpolate(
    frame,
    [s(at, fps), s(at + 0.25, fps), s(at + dur - 0.3, fps), s(at + dur, fps)],
    [0, 1, 1, 0],
    CLAMP,
  );
  if (o <= 0.01) return null;
  return (
    <div
      style={{
        padding: '12px 22px',
        borderRadius: 999,
        background: BC.arang,
        color: BC.white,
        fontFamily: BODY_FONT,
        fontWeight: 700,
        fontSize: 20,
        opacity: o,
        transform: `translateY(${(1 - e) * 16}px)`,
        boxShadow: '0 12px 30px rgba(27,42,33,0.3)',
        whiteSpace: 'nowrap',
      }}
    >
      {text}
    </div>
  );
};
