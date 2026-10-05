#!/bin/zsh
# Render video penuh ke out/beres-explainer.mp4.
#
# Memakai Google Chrome yang sudah terpasang: di mesin ini headless shell
# bawaan Remotion gagal diekstrak. Kalau di mesinmu `npm run build` sudah
# jalan tanpa masalah, skrip ini tidak perlu dipakai.
set -e
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
npx remotion render BeresExplainer out/beres-explainer.mp4 \
  --browser-executable="$CHROME" \
  "$@"
