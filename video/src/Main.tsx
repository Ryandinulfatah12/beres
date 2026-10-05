import React from 'react';
import {AbsoluteFill, Sequence} from 'remotion';
import './fonts';
import {BC, BODY_FONT, TIMELINE, SceneName} from './theme';
import {Title} from './scenes/Title';
import {Problem} from './scenes/Problem';
import {Loop} from './scenes/Loop';
import {Week} from './scenes/Week';
import {Generate} from './scenes/Generate';
import {Shopping} from './scenes/Shopping';
import {Done} from './scenes/Done';
import {Offline} from './scenes/Offline';
import {Outro} from './scenes/Outro';

export const SCENE_COMPONENTS: Record<SceneName, React.FC> = {
  title: Title,
  problem: Problem,
  loop: Loop,
  week: Week,
  generate: Generate,
  shopping: Shopping,
  done: Done,
  offline: Offline,
  outro: Outro,
};

/**
 * Video penjelasan Beres? — sembilan adegan berurutan, tiap adegan memudar
 * sendiri di ujungnya sehingga peralihannya mulus tanpa transisi tambahan.
 */
export const Main: React.FC = () => (
  <AbsoluteFill style={{background: BC.santan, fontFamily: BODY_FONT}}>
    {TIMELINE.map((scene) => {
      const Component = SCENE_COMPONENTS[scene.name];
      return (
        <Sequence
          key={scene.name}
          name={scene.name}
          from={scene.from}
          durationInFrames={scene.durationInFrames}
        >
          <Component />
        </Sequence>
      );
    })}
  </AbsoluteFill>
);
