import React from 'react';
import {useCurrentFrame, useVideoConfig} from 'remotion';
import {BC} from '../theme';

/**
 * Si Beres — panci dengan uap "?" yang berubah jadi "✓" saat semuanya beres.
 *
 * Port langsung dari `lib/widgets/mascot.dart` (_MascotPainter) ke SVG:
 * koordinat, radius, dan fase animasinya dipertahankan dalam kanvas 120x120
 * supaya maskot di video identik dengan yang ada di aplikasi.
 */
export type Steam = 'question' | 'check' | 'none' | 'swap';
export type Eyes = 'open' | 'happy' | 'up';
export type Motion = 'bob' | 'jump' | 'tilt' | 'still';

type Props = {
  size?: number;
  steam?: Steam;
  eyes?: Eyes;
  wave?: boolean;
  motion?: Motion;
  body?: string;
  dark?: string;
  /** Geser fase animasi, supaya dua maskot di satu layar tidak serempak. */
  phase?: number;
};

export const Mascot: React.FC<Props> = ({
  size = 120,
  steam = 'question',
  eyes = 'open',
  wave = false,
  motion = 'bob',
  body = BC.pandan,
  dark = BC.daun,
  phase = 0,
}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  // Satu putaran = 2400ms (3200ms untuk steam "swap"), sama seperti di Flutter.
  const cycle = (steam === 'swap' ? 3.2 : 2.4) * fps;
  const t = ((frame / cycle + phase) % 1 + 1) % 1;
  const ph = t * 2 * Math.PI;

  // Gerakan seluruh badan.
  let dy = 0;
  let sx = 1;
  let sy = 1;
  let rot = 0;
  if (motion === 'bob') {
    dy = -4 * Math.sin(ph);
  } else if (motion === 'jump') {
    const j = Math.sin(ph);
    if (j > 0) {
      dy = -14 * j;
    } else {
      sx = 1 - 0.06 * j;
      sy = 1 + 0.06 * j;
    }
  } else if (motion === 'tilt') {
    rot = 0.09 * Math.sin(ph);
  }

  const bodyTransform = [
    `translate(60 ${108 + dy})`,
    `rotate(${(rot * 180) / Math.PI})`,
    `scale(${sx} ${sy})`,
    'translate(-60 -108)',
  ].join(' ');

  // Uap naik-turun.
  const puff = -2 * Math.sin(ph * 2);
  const shown: Steam = steam === 'swap' ? (t < 0.5 ? 'question' : 'check') : steam;
  const checkColor = body === BC.kunyit ? BC.white : BC.kunyit;

  // Kedip, dan lengan melambai di paruh awal siklus.
  const blink = t > 0.9 && t < 0.95 ? 0.12 : 1;
  const armAngle = wave && t < 0.55 ? 0.3 * Math.sin((t / 0.55) * 4 * Math.PI) - 0.1 : 0;

  const up = eyes === 'up';
  const stroke = {strokeLinecap: 'round', strokeLinejoin: 'round', fill: 'none'} as const;

  return (
    <svg width={size} height={size} viewBox="0 0 120 120" aria-hidden>
      <g transform={bodyTransform}>
        {shown === 'question' ? (
          <g>
            <path
              d={`M50 ${12 + puff} C50 ${2 + puff} 69 ${2 + puff} 69 ${12 + puff} C69 ${19 + puff} 59.5 ${
                19 + puff
              } 59.5 ${26 + puff}`}
              stroke={BC.steam}
              strokeWidth={5}
              {...stroke}
            />
            <circle cx={59.5} cy={33 + puff} r={3.2} fill={BC.steam} />
          </g>
        ) : null}
        {shown === 'check' ? (
          <path
            d={`M46 ${20 + puff} L56 ${30 + puff} L74 ${10 + puff}`}
            stroke={checkColor}
            strokeWidth={6}
            {...stroke}
          />
        ) : null}

        {/* Tutup, gagang, badan. */}
        <rect x={53} y={38} width={14} height={8} rx={4} fill={dark} />
        <ellipse cx={60} cy={49} rx={39} ry={7} fill={dark} />
        <rect x={12} y={62} width={16} height={9} rx={4.5} fill={dark} />
        <path
          d="M24 54 L96 54 L96 78 A28 28 0 0 1 68 106 L52 106 A28 28 0 0 1 24 78 Z"
          fill={body}
        />

        {/* Tangan melambai, atau gagang kanan. */}
        {wave ? (
          <g transform={`translate(94 72) rotate(${(armAngle * 180) / Math.PI}) translate(-94 -72)`}>
            <path d="M94 72 Q108 70 110 54" stroke={body} strokeWidth={8} {...stroke} />
            <circle cx={110} cy={52} r={6} fill={body} />
          </g>
        ) : (
          <rect x={92} y={62} width={16} height={9} rx={4.5} fill={dark} />
        )}

        {/* Mata. */}
        {eyes === 'happy' ? (
          <path
            d="M41 71 Q47 63 53 71 M67 71 Q73 63 79 71"
            stroke={BC.white}
            strokeWidth={4}
            {...stroke}
          />
        ) : (
          <g transform={`translate(0 70) scale(1 ${blink}) translate(0 -70)`}>
            <circle cx={47} cy={70} r={7} fill={BC.white} />
            <circle cx={73} cy={70} r={7} fill={BC.white} />
            <circle cx={up ? 49 : 48} cy={up ? 67 : 71} r={up ? 3.4 : 3.6} fill={BC.arang} />
            <circle cx={up ? 75 : 74} cy={up ? 67 : 71} r={up ? 3.4 : 3.6} fill={BC.arang} />
            {!up ? (
              <g>
                <circle cx={49.5} cy={69.5} r={1.2} fill={BC.white} />
                <circle cx={75.5} cy={69.5} r={1.2} fill={BC.white} />
              </g>
            ) : null}
          </g>
        )}

        {/* Pipi, mulut, lencana centang. */}
        <circle cx={38} cy={82} r={4.5} fill={BC.blush} />
        <circle cx={82} cy={82} r={4.5} fill={BC.blush} />
        {up ? (
          <circle cx={60} cy={84} r={3.5} fill={BC.white} />
        ) : (
          <path d="M53 82 Q60 89 67 82" stroke={BC.white} strokeWidth={3.5} {...stroke} />
        )}
        <circle cx={60} cy={96} r={7.5} fill={body === BC.kunyit ? BC.white : BC.kunyit} />
        <path d="M56.5 96 L59.1 98.6 L63.7 93.4" stroke={dark} strokeWidth={2.4} {...stroke} />
      </g>
    </svg>
  );
};
