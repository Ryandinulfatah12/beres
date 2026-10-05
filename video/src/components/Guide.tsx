import React from 'react';
import {useCurrentFrame, useVideoConfig} from 'remotion';
import {BC} from '../theme';
import {EASE, s} from '../motion';
import {Mascot, type Eyes, type Motion, type Steam} from './Mascot';

export type GuidePose = {
  /** Detik saat maskot sampai di pose ini. */
  at: number;
  x: number;
  y: number;
  size?: number;
  steam?: Steam;
  eyes?: Eyes;
  motion?: Motion;
  wave?: boolean;
  /** Tinggi lengkungan lompatan menuju pose ini. */
  arc?: number;
};

/**
 * Si Beres sebagai pemandu.
 *
 * Maskot tidak pernah hilang: ia berpindah antar pose dengan lintasan
 * melengkung (seperti melompat), dan ekspresinya berganti mengikuti apa yang
 * sedang dibahas — uap "?" saat ada masalah, "✓" saat beres.
 */
export const MascotGuide: React.FC<{
  poses: GuidePose[];
  /** Alas bundar warna santan, untuk latar gelap. */
  plate?: boolean;
}> = ({poses, plate = false}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  if (!poses.length) return null;

  // Pose sekarang dan sebelumnya.
  let idx = 0;
  for (let i = 0; i < poses.length; i++) {
    if (frame >= s(poses[i].at, fps)) idx = i;
  }
  const cur = poses[idx];
  const prev = idx > 0 ? poses[idx - 1] : cur;

  // Perpindahan antar pose berlangsung 0,7 detik dengan lengkungan.
  const TRAVEL = 0.7;
  const start = s(cur.at, fps);
  const raw = Math.min(1, Math.max(0, (frame - start) / s(TRAVEL, fps)));
  const t = EASE.in(raw);

  const x = prev.x + (cur.x - prev.x) * t;
  const arc = cur.arc ?? 90;
  const jumpY = idx > 0 && raw < 1 ? -Math.sin(Math.PI * raw) * arc : 0;
  const y = prev.y + (cur.y - prev.y) * t + jumpY;

  const size = (prev.size ?? 150) + ((cur.size ?? 150) - (prev.size ?? 150)) * t;

  // Saat melompat, pakai ekspresi pose tujuan supaya reaksinya terasa langsung.
  const pose = raw > 0.35 ? cur : prev;

  const mascot = (
    <Mascot
      size={size}
      steam={pose.steam ?? 'question'}
      eyes={pose.eyes ?? 'open'}
      motion={raw < 1 && idx > 0 ? 'still' : pose.motion ?? 'bob'}
      wave={pose.wave ?? false}
    />
  );

  return (
    <div
      style={{
        position: 'absolute',
        left: x,
        top: y,
        transform: 'translate(-50%, -50%)',
        willChange: 'transform',
      }}
    >
      {plate ? (
        <div style={{background: BC.santan, borderRadius: '50%', padding: size * 0.08, display: 'flex'}}>
          {mascot}
        </div>
      ) : (
        mascot
      )}
    </div>
  );
};
