import React from 'react';
import {AbsoluteFill, Composition} from 'remotion';
import {Main, SCENE_COMPONENTS} from './Main';
import {BC, BODY_FONT, FPS, HEIGHT, TIMELINE, TOTAL_FRAMES, WIDTH} from './theme';

export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="BeresExplainer"
      component={Main}
      durationInFrames={TOTAL_FRAMES}
      fps={FPS}
      width={WIDTH}
      height={HEIGHT}
    />

    {/* Tiap adegan juga jadi komposisi sendiri supaya bisa ditinjau terpisah. */}
    {TIMELINE.map((scene) => {
      const Scene = SCENE_COMPONENTS[scene.name];
      const Solo: React.FC = () => (
        <AbsoluteFill style={{background: BC.santan, fontFamily: BODY_FONT}}>
          <Scene />
        </AbsoluteFill>
      );
      return (
        <Composition
          key={scene.name}
          id={`Scene-${scene.name}`}
          component={Solo}
          durationInFrames={scene.durationInFrames}
          fps={FPS}
          width={WIDTH}
          height={HEIGHT}
        />
      );
    })}
  </>
);
