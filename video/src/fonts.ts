import {loadFont as loadFredoka} from '@remotion/google-fonts/Fredoka';
import {loadFont as loadJakarta} from '@remotion/google-fonts/PlusJakartaSans';

/**
 * Huruf yang sama dengan aplikasi: Fredoka untuk judul, Plus Jakarta Sans
 * untuk teks. Di aplikasi diambil lewat `google_fonts`; di sini lewat
 * @remotion/google-fonts supaya ikut dibundel saat render.
 *
 * Hanya bobot dan subset yang benar-benar dipakai yang dimuat — selisihnya
 * puluhan request per frame saat render.
 */
loadFredoka('normal', {weights: ['600'], subsets: ['latin']});
loadJakarta('normal', {weights: ['500', '600', '700', '800'], subsets: ['latin']});
