import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Guru (Member) theme - Blue
  static const Color guruPrimary = Color(0xFF1769E0);
  static const Color guruPrimaryLight = Color(0xFF4A8DF5);
  static const Color guruPrimaryDark = Color(0xFF0D47A1);

  // Trainer theme - Red
  static const Color trainerPrimary = Color(0xFFE50914);
  static const Color trainerPrimaryLight = Color(0xFFFF4D4D);
  static const Color trainerPrimaryDark = Color(0xFFB00710);

  // Neutral greys
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF2F4F7);
  static const Color grey200 = Color(0xFFEAECF0);
  static const Color grey300 = Color(0xFFD0D5DD);
  static const Color grey400 = Color(0xFF98A2B3);
  static const Color grey500 = Color(0xFF667085);
  static const Color grey600 = Color(0xFF475467);
  static const Color grey700 = Color(0xFF344054);
  static const Color grey800 = Color(0xFF1D2939);
  static const Color grey900 = Color(0xFF101828);

  // Semantic colors
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFD92D20);
  static const Color info = Color(0xFF1769E0);

  // Mapped aliases (used throughout the app)
  static const Color surface = grey50;
  static const Color background = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey500;
  static const Color textTertiary = grey400;
  static const Color divider = grey200;

  // Chat colors
  static const Color chatBubbleSent = Color(0xFF1769E0);
  static const Color chatBubbleReceived = grey100;
  static const Color chatBubbleSentText = Colors.white;
  static const Color chatBubbleReceivedText = grey900;
  static const Color systemMessageBg = Color(0xFFFEF3C7);

  // Spacing (8pt grid)
  static const double sp1 = 8.0;
  static const double sp2 = 16.0;
  static const double sp3 = 24.0;
  static const double sp4 = 32.0;
  static const double sp5 = 40.0;
  static const double sp6 = 48.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 200);
  static const Duration animSlow = Duration(milliseconds: 250);

  static ThemeData buildTheme({required bool isTrainer}) {
    final primary = isTrainer ? trainerPrimary : guruPrimary;
    final primaryLight = isTrainer ? trainerPrimaryLight : guruPrimaryLight;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: primaryLight,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: Colors.white,
        outline: grey300,
        outlineVariant: grey200,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: grey200, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: grey400, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primary.withValues(alpha: 0.1),
        labelStyle: const TextStyle(fontSize: 13, color: grey700),
        side: const BorderSide(color: grey300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: grey800,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: grey200,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
