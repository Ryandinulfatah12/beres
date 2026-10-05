import React from 'react';
import {Audio, Sequence, staticFile, useVideoConfig} from 'remotion';
import {s} from '../motion';

/**
 * Musik dan SFX.
 *
 * Semua sumber bersifat opsional: kalau propnya kosong, komposisi tetap
 * dirender tanpa error — videonya hanya jadi tanpa suara.
 */

export type SfxMap = {
  pop?: string;
  tap?: string;
  whoosh?: string;
  ting?: string;
  confetti?: string;
};

export type SfxCue = {at: number; kind: keyof SfxMap};

/** Volume per jenis SFX. */
const SFX_VOLUME: Record<keyof SfxMap, number> = {
  pop: 0.5,
  tap: 0.4,
  whoosh: 0.55,
  ting: 0.7,
  confetti: 0.6,
};

export const Soundtrack: React.FC<{
  musicSrc?: string;
  sfx?: SfxMap;
  cues?: SfxCue[];
  /** Detik tempat musik diredam (ducking) — biasanya saat "ting". */
  duckAt?: number[];
  volume?: number;
}> = ({musicSrc, sfx = {}, cues = [], duckAt = [], volume = 0.6}) => {
  const {fps, durationInFrames} = useVideoConfig();

  const fadeIn = s(0.5, fps);
  const fadeOut = s(1, fps);

  return (
    <>
      {musicSrc ? (
        <Audio
          src={staticFile(musicSrc)}
          volume={(f) => {
            // Fade in 0,5 dtk, fade out 1 dtk.
            let v = volume;
            if (f < fadeIn) v = volume * (f / fadeIn);
            const tail = durationInFrames - fadeOut;
            if (f > tail) v = volume * Math.max(0, 1 - (f - tail) / fadeOut);

            // Ducking: turun ke 0,35 selama 0,3 detik di momen "ting".
            for (const d of duckAt) {
              const start = s(d, fps);
              const end = s(d + 0.3, fps);
              if (f >= start && f <= end) v = Math.min(v, 0.35);
            }
            return v;
          }}
        />
      ) : null}

      {cues.map((cue, i) => {
        const src = sfx[cue.kind];
        if (!src) return null;
        const from = s(cue.at, fps);
        if (from < 0 || from >= durationInFrames) return null;
        return (
          <Sequence key={`${cue.kind}-${i}`} from={from} durationInFrames={s(2, fps)}>
            <Audio src={staticFile(src)} volume={SFX_VOLUME[cue.kind]} />
          </Sequence>
        );
      })}
    </>
  );
};
