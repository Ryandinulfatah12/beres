import React from 'react';
import {Composition} from 'remotion';
import {Main, DEFAULT_PROPS} from './Main';
import {FPS, LANDSCAPE, TOTAL_FRAMES, VERTICAL} from './theme';

/**
 * Dua komposisi dengan scene yang sama; tata letaknya menyesuaikan orientasi.
 *
 * Prop `audience` hanya memengaruhi bagian riwayat dan outro:
 *   "pengguna"  (default) — tanpa jargon teknis.
 *   "developer"           — menambah kartu Tanpa akun / Tanpa server / Data
 *                           di perangkat, plus chip teknis.
 */
export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="BeresLandscape"
      component={Main}
      durationInFrames={TOTAL_FRAMES}
      fps={FPS}
      width={LANDSCAPE.width}
      height={LANDSCAPE.height}
      defaultProps={DEFAULT_PROPS}
    />
    <Composition
      id="BeresVertical"
      component={Main}
      durationInFrames={TOTAL_FRAMES}
      fps={FPS}
      width={VERTICAL.width}
      height={VERTICAL.height}
      defaultProps={DEFAULT_PROPS}
    />
  </>
);
