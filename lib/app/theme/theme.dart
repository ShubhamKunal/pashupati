import 'package:flutter/material.dart';

class PashupatiColors {
  // Brand Forest Green Palette
  static const Color darkForest = Color(0xFF0A3623);
  static const Color forestGreen = Color(0xFF244D38);
  static const Color deepGreen = Color(0xFF183B2B);
  static const Color mossGreen = Color(0xFF436653);

  // Backgrounds & Surfaces (Ivory & Soft Green)
  static const Color ivoryCanvas = Color(0xFFF5F1E7);
  static const Color warmIvory = Color(0xFFFDF9EF);
  static const Color softGreen = Color(0xFFE9F1E9);
  static const Color surfaceElevation = Color(0xFFF2EEE4);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Saffron Accent
  static const Color saffron = Color(0xFFD99A45);
  static const Color saffronLight = Color(0xFFE5A952);
  static const Color saffronDark = Color(0xFF452900);

  // Emergency & Triage Coral Red
  static const Color emergencyCoral = Color(0xFFC85C4A);
  static const Color emergencyRed = Color(0xFFBA1A1A);
  static const Color emergencyLight = Color(0xFFFFDAD6);

  // Text & Neutral Tones
  static const Color primaryText = Color(0xFF1B1C1A);
  static const Color secondaryText = Color(0xFF747B73);
  static const Color outline = Color(0xFF707973);
  static const Color outlineVariant = Color(0xFFC0C9C2);
}

class PashupatiTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: PashupatiColors.forestGreen,
      onPrimary: Colors.white,
      primaryContainer: PashupatiColors.darkForest,
      onPrimaryContainer: Colors.white,
      secondary: PashupatiColors.mossGreen,
      onSecondary: Colors.white,
      secondaryContainer: PashupatiColors.softGreen,
      onSecondaryContainer: PashupatiColors.forestGreen,
      tertiary: PashupatiColors.saffron,
      onTertiary: Colors.white,
      tertiaryContainer: PashupatiColors.saffronLight,
      onTertiaryContainer: PashupatiColors.saffronDark,
      error: PashupatiColors.emergencyCoral,
      onError: Colors.white,
      errorContainer: PashupatiColors.emergencyLight,
      onErrorContainer: PashupatiColors.emergencyRed,
      surface: PashupatiColors.warmIvory,
      onSurface: PashupatiColors.primaryText,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: PashupatiColors.surfaceElevation,
      surfaceContainer: PashupatiColors.ivoryCanvas,
      surfaceContainerHigh: PashupatiColors.softGreen,
      outline: PashupatiColors.outline,
      outlineVariant: PashupatiColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PashupatiColors.ivoryCanvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: PashupatiColors.ivoryCanvas,
        foregroundColor: PashupatiColors.darkForest,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: PashupatiColors.darkForest,
          letterSpacing: 0.15,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x1F707973), width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PashupatiColors.forestGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PashupatiColors.forestGreen,
          side: const BorderSide(color: PashupatiColors.forestGreen, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x33707973)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x33707973)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PashupatiColors.forestGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PashupatiColors.emergencyCoral, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: PashupatiColors.softGreen,
        elevation: 4,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PashupatiColors.forestGreen,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: PashupatiColors.secondaryText,
          );
        }),
      ),
    );
  }
}
