/**
 * Pengecekan "tidak pernah diam".
 *
 * Menggantikan `ffmpeg -vf freezedetect`: ffmpeg yang dibundel Remotion hanya
 * membawa 50 filter (tanpa freezedetect) dan tidak punya muxer rawvideo,
 * sementara mesin ini tidak punya ffmpeg sistem.
 *
 * Gantinya: tiap frame diekstrak sebagai PNG lossless, lalu isinya dibandingkan
 * byte per byte. PNG bersifat deterministik, jadi dua frame dengan byte yang
 * sama berarti pikselnya benar-benar identik — alias beku. Pengecekan ini
 * malah lebih ketat daripada freezedetect dengan toleransi, karena perubahan
 * sekecil satu piksel pun sudah dihitung sebagai gerakan.
 *
 * Pakai:
 *   npx remotion ffmpeg -y -i out/draft.mp4 -an -s 320x180 out/fr/%05d.png
 *   node tools/freezecheck.mjs out/fr 60 0.8
 *
 * Keluar dengan kode 1 kalau ada bagian beku melebihi batas.
 */
import {readdirSync, readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {join} from 'node:path';

const [, , dir, fpsArg, maxHoldArg] = process.argv;
const FPS = Number(fpsArg ?? 60);
const MAX_HOLD = Number(maxHoldArg ?? 0.8);

const files = readdirSync(dir)
  .filter((f) => f.endsWith('.png'))
  .sort();

if (files.length < 2) {
  console.error(`Hanya ${files.length} frame di ${dir}.`);
  process.exit(1);
}

const hashes = files.map((f) =>
  createHash('md5').update(readFileSync(join(dir, f))).digest('hex'),
);

// Cari deretan frame yang isinya persis sama.
const minRun = Math.round(MAX_HOLD * FPS);
const frozen = [];
let start = 0;
let longest = 0;
let longestAt = 0;

for (let i = 1; i <= hashes.length; i++) {
  if (i === hashes.length || hashes[i] !== hashes[start]) {
    const len = i - start;
    if (len > longest) {
      longest = len;
      longestAt = start;
    }
    if (len >= minRun) {
      frozen.push({
        from: (start / FPS).toFixed(2),
        to: (i / FPS).toFixed(2),
        detik: (len / FPS).toFixed(2),
      });
    }
    start = i;
  }
}

console.log(`Frame diperiksa : ${hashes.length} (${(hashes.length / FPS).toFixed(2)} dtk @ ${FPS}fps)`);
console.log(`Batas diam      : ${MAX_HOLD} dtk (${minRun} frame identik berturut-turut)`);
console.log(
  `Diam terpanjang : ${(longest / FPS).toFixed(2)} dtk (${longest} frame) mulai detik ${(
    longestAt / FPS
  ).toFixed(2)}`,
);

if (frozen.length === 0) {
  console.log('\nLULUS — tidak ada bagian yang beku melebihi batas.');
  process.exit(0);
}

console.log(`\nGAGAL — ${frozen.length} bagian beku:`);
for (const f of frozen) console.log(`  ${f.from}s → ${f.to}s  (${f.detik} dtk)`);
process.exit(1);
