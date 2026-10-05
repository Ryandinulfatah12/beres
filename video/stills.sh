#!/bin/zsh
# Render still di detik-detik kunci untuk ditinjau (quality check spec).
#   zsh stills.sh              -> landscape
#   zsh stills.sh BeresVertical -> vertical
set -e
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
COMP="${1:-BeresLandscape}"
FPS=60
SECONDS_LIST=(3 8 12 20 30 40 47 53 58)
mkdir -p out/still
for sec in $SECONDS_LIST; do
  frame=$(( sec * FPS ))
  npx remotion still "$COMP" "out/still/${COMP}-${sec}s.png" \
    --frame="$frame" --browser-executable="$CHROME" --log=error
done
echo "selesai -> out/still/"
