import React from 'react';
import {AbsoluteFill, Sequence, useVideoConfig} from 'remotion';
import {TransitionSeries, springTiming} from '@remotion/transitions';
import {wipe} from '@remotion/transitions/wipe';
import './fonts';
import {BC, BODY_FONT, SB} from './theme';
import {s} from './motion';
import {snap} from './beats';
import type {Audience} from './copy';
import {Open} from './scenes/Open';
import {Cycle} from './scenes/Cycle';
import {PhoneAct} from './scenes/PhoneAct';
import {Outro} from './scenes/Outro';
import {Soundtrack, type SfxCue, type SfxMap} from './components/Sound';
import {T} from './components/screens';

export type MainProps = {
  /** Hanya memengaruhi bagian riwayat dan outro. */
  audience: Audience;
  cta: string;
  musicSrc?: string;
  sfx?: SfxMap;
  bpm: number;
  beatOffset: number;
};

export const DEFAULT_PROPS: MainProps = {
  audience: 'pengguna',
  cta: 'Segera di Play Store',
  musicSrc: '',
  sfx: {},
  bpm: 110,
  beatOffset: 0,
};

/**
 * Video penjelasan Beres? — 60 detik.
 *
 * Tiga babak: pembuka (Open + Cycle), babak phone yang memakai satu phone
 * sebagai shared element, lalu outro. Tidak ada transisi fade ke latar pucat —
 * perpindahan memakai wipe, circle-reveal, dan zoom-through kamera.
 */
export const Main: React.FC<MainProps> = ({audience, cta, musicSrc, sfx, bpm, beatOffset}) => {
  const {fps} = useVideoConfig();

  const openDur = SB.logo.to - SB.hook.from; // 9 dtk
  const cycleDur = SB.cycle.to - SB.cycle.from; // 5 dtk
  const phoneFrom = SB.plan.from; // 14
  const phoneDur = SB.history.to - SB.plan.from; // 41 dtk
  const outroFrom = SB.outro.from; // 55
  const outroDur = SB.outro.to - SB.outro.from; // 5 dtk

  /** Wipe Pandan antara pembuka dan siklus — bukan fade. */
  const WIPE = 0.6;

  // Cue SFX dalam detik absolut.
  const P = (t: number) => phoneFrom + t;
  const cues: SfxCue[] = [
    // Gelembung chat muncul.
    ...[1.0, 1.9, 2.6, 3.2].map((t) => ({at: snap(t, bpm, beatOffset), kind: 'pop' as const})),
    // Tersedot ke panci, lalu "?" jadi "✓".
    {at: snap(5.0, bpm, beatOffset), kind: 'whoosh' as const},
    {at: 5.5, kind: 'ting' as const},
    {at: snap(7.3, bpm, beatOffset), kind: 'ting' as const},
    // Node siklus.
    ...[0.75, 1.3, 1.85, 2.4].map((t) => ({
      at: SB.cycle.from + snap(t, bpm, beatOffset),
      kind: 'pop' as const,
    })),
    {at: SB.cycle.from + 4.0, kind: 'whoosh' as const},
    // Semua tap di babak phone.
    ...[
      T.tapTambah,
      T.pick1,
      T.pick2,
      T.tapAdd,
      T.tapLibur,
      T.tapGenerate,
      T.tapGrosir,
      T.tapSemua,
      T.tapMulai,
      ...T.checks,
      T.tapSelesai,
      T.tapSalin,
    ].map((t) => ({at: P(t), kind: 'tap' as const})),
    // Checkbox dan chip yang mendarat.
    ...[T.pick1, T.pick2, ...T.checks].map((t) => ({at: P(t) + 0.05, kind: 'pop' as const})),
    ...[0, 1, 2, 3, 4].map((i) => ({
      at: P(T.mergeStart + i * T.mergeStep),
      kind: 'pop' as const,
    })),
    // Perpindahan layar di dalam phone.
    ...[T.toList, T.toShop, T.toHistory, T.toHome].map((t) => ({
      at: P(t) - 0.1,
      kind: 'whoosh' as const,
    })),
    // Perayaan dan total selesai.
    {at: P(T.tapSelesai) + 0.05, kind: 'confetti' as const},
    {at: P(T.checks[4]) + 0.5, kind: 'ting' as const},
    {at: P(T.widgetPop), kind: 'pop' as const},
    // Outro.
    {at: outroFrom, kind: 'whoosh' as const},
    {at: snap(outroFrom + 2.9, bpm, beatOffset), kind: 'ting' as const},
  ];

  const duckAt = cues.filter((c) => c.kind === 'ting').map((c) => c.at);

  return (
    <AbsoluteFill style={{background: BC.santan, fontFamily: BODY_FONT}}>
      {/* Babak 1 — pembuka dan siklus, disambung wipe. */}
      <Sequence from={0} durationInFrames={s(SB.cycle.to, fps)} name="Babak 1 · Pembuka">
        <TransitionSeries>
          <TransitionSeries.Sequence durationInFrames={s(openDur, fps)}>
            <Open bpm={bpm} beatOffset={beatOffset} />
          </TransitionSeries.Sequence>
          <TransitionSeries.Transition
            timing={springTiming({config: {damping: 200}, durationInFrames: s(WIPE, fps)})}
            presentation={wipe({direction: 'from-right'})}
          />
          <TransitionSeries.Sequence durationInFrames={s(cycleDur + WIPE, fps)}>
            <Cycle bpm={bpm} beatOffset={beatOffset} />
          </TransitionSeries.Sequence>
        </TransitionSeries>
      </Sequence>

      {/* Babak 2 — phone sebagai shared element (scene 4–8). */}
      <Sequence from={s(phoneFrom, fps)} durationInFrames={s(phoneDur, fps)} name="Babak 2 · Phone">
        <PhoneAct audience={audience} bpm={bpm} beatOffset={beatOffset} />
      </Sequence>

      {/* Babak 3 — outro, masuk lewat circle-reveal di atas babak phone. */}
      <Sequence from={s(outroFrom, fps)} durationInFrames={s(outroDur, fps)} name="Babak 3 · Outro">
        <Outro cta={cta} bpm={bpm} beatOffset={beatOffset} />
      </Sequence>

      <Soundtrack musicSrc={musicSrc} sfx={sfx} cues={cues} duckAt={duckAt} />
    </AbsoluteFill>
  );
};
