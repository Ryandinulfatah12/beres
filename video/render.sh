#!/bin/zsh
# Render video Beres?.
#
#   zsh render.sh            -> landscape final (crf 18)
#   zsh render.sh vertical   -> vertical final
#   zsh render.sh draft      -> draft cepat (scale 0.5) untuk quality check
#
# Memakai Google Chrome yang terpasang: headless shell bawaan Remotion gagal
# diekstrak di mesin ini. Kalau `npm run build` sudah jalan di mesinmu, skrip
# ini tidak perlu dipakai.
set -e
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
MODE="${1:-landscape}"
case "$MODE" in
  draft)
    COMP=BeresLandscape; OUT=out/draft.mp4; EXTRA=(--scale=0.5) ;;
  vertical)
    COMP=BeresVertical;  OUT=out/beres-vertical.mp4; EXTRA=(--crf=18) ;;
  *)
    COMP=BeresLandscape; OUT=out/beres-landscape.mp4; EXTRA=(--crf=18) ;;
esac
npx remotion render "$COMP" "$OUT" --browser-executable="$CHROME" "${EXTRA[@]}"
