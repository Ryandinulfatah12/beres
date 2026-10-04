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
}

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
  final body = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
      .apply(bodyColor: BC.arang, displayColor: BC.arang);
  final btnText = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15);
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: btnText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BC.arang,
        backgroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: BC.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: BC.daun,
    ),
  );
}
