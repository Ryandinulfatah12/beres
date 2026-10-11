import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet Beres? — warna dapur.
class BC {
  static const pandan = Color(0xFF2E6A4C);
  static const daun = Color(0xFF1F4D36);
  static const kunyit = Color(0xFFF5C24C);
  static const kunyitDark = Color(0xFFD9A22E);
  static const cabai = Color(0xFFC8622A);
  static const santan = Color(0xFFF3F5F1);
  static const arang = Color(0xFF1B2A21);
  static const muted = Color(0xFF56645A);
  static const line = Color(0xFFE1E6DF);
  static const lineSoft = Color(0xFFEEF1EC);
  static const greenSoft = Color(0xFFE3EFE7);
  static const greenText = Color(0xFF245A3F);
  static const orangeSoft = Color(0xFFFBEBDD);
  static const orangeText = Color(0xFF8F4318);
  static const steam = Color(0xFFA9C4B2);
  static const blush = Color(0xFFF2A27A);
  static const pill = Color(0xFFE4E9E2);

  // --- Lapis baru: permukaan lembut, judul tebal, dan bilah bawah gelap. ---
  static const mint = Color(0xFFEAF4EC);
  static const mintLine = Color(0xFFD8E8DE);
  static const kunyitSoft = Color(0xFFFCF2DA);
  static const kunyitText = Color(0xFF8A6512);

  /// Warna judul besar — sedikit lebih pekat dari [arang] supaya kontras.
  static const ink = Color(0xFF14241A);

  /// Gradasi kartu utama (kartu hijau di Beranda).
  static const heroFrom = Color(0xFF2F7351);
  static const heroTo = Color(0xFF1B4530);
}

/// Satu bahasa sudut untuk seluruh aplikasi, mengikuti bilah navigasi.
///
/// Apa pun yang diketuk sebagai kontrol berbentuk pil penuh; permukaan kartu
/// memakai satu sudut besar yang sama; baris padat dan kotak isian memakai
/// sudut sedang supaya isinya tidak tertabrak lengkungan.
class BR {
  static const pill = 99.0;
  static const card = 28.0;
  static const inner = 18.0;

  static BorderRadius get pillR => BorderRadius.circular(pill);
  static BorderRadius get cardR => BorderRadius.circular(card);
  static BorderRadius get innerR => BorderRadius.circular(inner);

  static RoundedRectangleBorder get pillShape => RoundedRectangleBorder(borderRadius: pillR);
  static RoundedRectangleBorder get cardShape => RoundedRectangleBorder(borderRadius: cardR);
  static RoundedRectangleBorder get innerShape => RoundedRectangleBorder(borderRadius: innerR);
}

/// Bayangan tipis untuk kartu yang perlu sedikit "terangkat".
const softShadow = [
  BoxShadow(color: Color(0x0D1B2A21), blurRadius: 18, offset: Offset(0, 8)),
];

/// Bayangan bilah navigasi melayang.
const navShadow = [
  BoxShadow(color: Color(0x261B2A21), blurRadius: 24, offset: Offset(0, 10)),
];

/// Huruf judul (Fredoka).
TextStyle fredoka(double size, {FontWeight weight = FontWeight.w600, Color color = BC.arang}) =>
    GoogleFonts.fredoka(fontSize: size, fontWeight: weight, color: color, height: 1.15);

const mutedText = TextStyle(fontSize: 12, color: BC.muted, fontWeight: FontWeight.w500);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: BC.pandan,
      primary: BC.pandan,
      secondary: BC.cabai,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: BC.santan,
  );
  final body =
      GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(bodyColor: BC.arang, displayColor: BC.arang);
  final btnText = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15);
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BR.innerR,
        borderSide: BorderSide(color: c, width: w),
      );
  return base.copyWith(
    textTheme: body,
    appBarTheme: AppBarTheme(
      backgroundColor: BC.santan,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: BC.arang,
      titleTextStyle: fredoka(22),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: BC.pandan,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: BR.pillShape,
        textStyle: btnText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BC.arang,
        backgroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: BC.line),
        shape: BR.pillShape,
        textStyle: btnText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BC.pandan,
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(BC.line),
      enabledBorder: border(BC.line),
      focusedBorder: border(BC.pandan, 1.5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: BC.greenSoft,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    // FilterChip di Pengaturan ikut bentuk pil, bukan kotak bawaan Material.
    chipTheme: const ChipThemeData(shape: StadiumBorder(side: BorderSide(color: BC.line))),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(BR.card))),
    ),
    dialogTheme: DialogThemeData(shape: BR.cardShape),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: BC.daun,
    ),
  );
}
