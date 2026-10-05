#!/bin/zsh
# Render satu frame contoh dari tiap adegan untuk ditinjau cepat.
# Pakai Chrome yang sudah terpasang: headless shell bawaan Remotion gagal diekstrak di mesin ini.
set -e
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
render() {
  npx remotion still "Scene-$1" "out/$1.png" --frame="$2" --browser-executable="$CHROME" --log=error
}
render title 60
render problem 110
render loop 110
render week 150
render generate 150
render shopping 140
render done 120
render offline 110
render outro 90
echo "selesai"
