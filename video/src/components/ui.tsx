import React from 'react';
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BC, BODY_FONT, TITLE_FONT} from '../theme';

/** Muncul dari bawah sambil memudar — gerakan dasar untuk hampir semua elemen. */
export const Rise: React.FC<{
  delay?: number;
  distance?: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({delay = 0, distance = 28, children, style}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const s = spring({frame: frame - delay, fps, config: {damping: 200, mass: 0.7}});
  return (
    <div
      style={{
        ...style,
        opacity: s,
        transform: `translateY(${(1 - s) * distance}px)`,
      }}
    >
      {children}
    </div>
  );
};

/** Membesar sedikit saat masuk — untuk kartu dan lencana. */
export const Pop: React.FC<{
  delay?: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({delay = 0, children, style}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const s = spring({frame: frame - delay, fps, config: {damping: 14, mass: 0.6, stiffness: 120}});
  return (
    <div style={{...style, opacity: Math.min(1, s * 1.6), transform: `scale(${0.86 + 0.14 * s})`}}>
      {children}
    </div>
  );
};

/** Latar adegan: santan hangat dengan dua sapuan warna lembut. */
export const Backdrop: React.FC<{tone?: 'light' | 'dark'}> = ({tone = 'light'}) => (
  <div
    style={{
      position: 'absolute',
      inset: 0,
      background:
        tone === 'dark'
          ? `radial-gradient(1200px 700px at 20% 10%, ${BC.pandan} 0%, ${BC.daun} 55%, #163927 100%)`
          : BC.santan,
    }}
  >
    {tone === 'light' ? (
      <>
        <div
          style={{
            position: 'absolute',
            width: 900,
            height: 900,
            left: -260,
            top: -340,
            borderRadius: '50%',
            background: BC.greenSoft,
            opacity: 0.85,
            filter: 'blur(2px)',
          }}
        />
        <div
          style={{
            position: 'absolute',
            width: 620,
            height: 620,
            right: -200,
            bottom: -260,
            borderRadius: '50%',
            background: BC.orangeSoft,
            opacity: 0.7,
          }}
        />
      </>
    ) : null}
  </div>
);

/** Eyebrow kecil di atas judul — nomor langkah atau label bagian. */
export const Eyebrow: React.FC<{children: React.ReactNode; tone?: 'light' | 'dark'}> = ({
  children,
  tone = 'light',
}) => (
  <div
    style={{
      display: 'inline-flex',
      alignItems: 'center',
      gap: 10,
      padding: '10px 20px',
      borderRadius: 999,
      background: tone === 'dark' ? 'rgba(255,255,255,0.14)' : BC.white,
      color: tone === 'dark' ? BC.kunyit : BC.greenText,
      border: tone === 'dark' ? '1px solid rgba(255,255,255,0.18)' : `1px solid ${BC.line}`,
      fontFamily: BODY_FONT,
      fontWeight: 700,
      fontSize: 24,
      letterSpacing: 0.4,
    }}
  >
    {children}
  </div>
);

export const Title: React.FC<{
  children: React.ReactNode;
  size?: number;
  tone?: 'light' | 'dark';
}> = ({children, size = 76, tone = 'light'}) => (
  <h1
    style={{
      margin: 0,
      fontFamily: TITLE_FONT,
      fontWeight: 600,
      fontSize: size,
      lineHeight: 1.1,
      color: tone === 'dark' ? BC.white : BC.arang,
    }}
  >
    {children}
  </h1>
);

export const Body: React.FC<{
  children: React.ReactNode;
  size?: number;
  tone?: 'light' | 'dark';
  style?: React.CSSProperties;
}> = ({children, size = 32, tone = 'light', style}) => (
  <p
    style={{
      margin: 0,
      fontFamily: BODY_FONT,
      fontWeight: 500,
      fontSize: size,
      lineHeight: 1.5,
      color: tone === 'dark' ? 'rgba(255,255,255,0.86)' : BC.muted,
      ...style,
    }}
  >
    {children}
  </p>
);

/** Kartu putih bersudut besar — bentuk dasar UI Beres?. */
export const Card: React.FC<{
  children: React.ReactNode;
  style?: React.CSSProperties;
  pad?: number;
}> = ({children, style, pad = 24}) => (
  <div
    style={{
      background: BC.white,
      borderRadius: 24,
      border: `1px solid ${BC.line}`,
      padding: pad,
      boxShadow: '0 18px 44px rgba(27,42,33,0.08)',
      ...style,
    }}
  >
    {children}
  </div>
);

/** Rangka ponsel 9:19.5 untuk memperlihatkan layar aplikasi. */
export const Phone: React.FC<{
  children: React.ReactNode;
  width?: number;
  style?: React.CSSProperties;
}> = ({children, width = 390, style}) => {
  const height = Math.round(width * (844 / 390));
  return (
    <div
      style={{
        width,
        height,
        borderRadius: width * 0.13,
        background: BC.arang,
        padding: width * 0.028,
        boxShadow: '0 40px 90px rgba(27,42,33,0.28)',
        ...style,
      }}
    >
      <div
        style={{
          width: '100%',
          height: '100%',
          borderRadius: width * 0.105,
          background: BC.santan,
          overflow: 'hidden',
          position: 'relative',
          display: 'flex',
          flexDirection: 'column',
          fontFamily: BODY_FONT,
        }}
      >
        {children}
      </div>
    </div>
  );
};

/** Chip kecil: nama lauk, tag toko, cara beli. */
export const Chip: React.FC<{
  children: React.ReactNode;
  bg?: string;
  color?: string;
  size?: number;
}> = ({children, bg = BC.greenSoft, color = BC.greenText, size = 15}) => (
  <span
    style={{
      display: 'inline-block',
      padding: `${size * 0.33}px ${size * 0.73}px`,
      borderRadius: 999,
      background: bg,
      color,
      fontFamily: BODY_FONT,
      fontWeight: 700,
      fontSize: size,
      whiteSpace: 'nowrap',
    }}
  >
    {children}
  </span>
);

/** Kotak centang yang bisa dianimasikan dari kosong ke tercentang. */
export const CheckBox: React.FC<{on: number; size?: number; color?: string}> = ({
  on,
  size = 26,
  color = BC.pandan,
}) => (
  <div
    style={{
      width: size,
      height: size,
      borderRadius: size * 0.3,
      border: `2px solid ${on > 0.5 ? color : BC.line}`,
      background: on > 0.5 ? color : 'transparent',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      flexShrink: 0,
    }}
  >
    <svg width={size * 0.66} height={size * 0.66} viewBox="0 0 24 24">
      <path
        d="M5 13 L10 18 L19 7"
        stroke={BC.white}
        strokeWidth={3.4}
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
        strokeDasharray={30}
        strokeDashoffset={interpolate(on, [0.5, 1], [30, 0], {
          extrapolateLeft: 'clamp',
          extrapolateRight: 'clamp',
        })}
      />
    </svg>
  </div>
);

/** Batang progres beranimasi, seperti kartu belanja di Beranda. */
export const Progress: React.FC<{
  value: number;
  height?: number;
  color?: string;
  track?: string;
}> = ({value, height = 10, color = BC.pandan, track = BC.pill}) => (
  <div style={{height, borderRadius: height, background: track, overflow: 'hidden', width: '100%'}}>
    <div
      style={{
        height: '100%',
        width: `${Math.max(0, Math.min(1, value)) * 100}%`,
        background: color,
        borderRadius: height,
      }}
    />
  </div>
);

export const Rupiah: React.FC<{value: number; style?: React.CSSProperties}> = ({value, style}) => (
  <span style={{fontFamily: BODY_FONT, fontWeight: 800, ...style}}>
    Rp {Math.round(value).toLocaleString('id-ID')}
  </span>
);
