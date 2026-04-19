import 'package:flutter/material.dart';

class AppConstants {
  // === Core Palette ===
  static const Color bgDeep = Color(0xFF020B18);         // Rich navy base
  static const Color bgCard = Color(0xFF06101F);         // Slightly lighter navy for cards
  static const Color bgGlass = Color(0xFF0A1628);        // Glass card base

  static const Color navyLight = Color(0xFF0D2140);      // Interior card borders
  static const Color royalBlue = Color(0xFF1040A0);      // Corner mesh glow
  static const Color midnightBlue = Color(0xFF071528);   // Section dividers

  static const Color gold = Color(0xFFD4AF37);           // Primary accent gold
  static const Color goldLight = Color(0xFFE8C84A);      // Hover/glow gold
  static const Color goldGlow = Color(0xFFD4AF37);       // Shadow color
  static const Color coral = Color(0xFFFF7F50);          // Secondary accent coral/orange
  static const Color coralLight = Color(0xFFFF9A6C);     // Hover coral

  static const Color textPrimary = Color(0xFFF0EDE4);   // Warm off-white for headings
  static const Color textSecondary = Color(0xFFB8C4D0); // Cool off-white for body
  static const Color textMuted = Color(0xFF607080);     // Muted labels

  static const Color glassBorder = Color(0xFF1A3050);
  static const Color goldBorder = Color(0xFFD4AF37);

  // === Gradients ===
  static const LinearGradient nameGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF0D060)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFB8922A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralButtonGradient = LinearGradient(
    colors: [Color(0xFFFF7F50), Color(0xFFE05A30)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient meshGradientTL = RadialGradient(
    center: Alignment(-1.1, -1.1),
    radius: 1.4,
    colors: [Color(0x441A50CC), Colors.transparent],
  );

  static const RadialGradient meshGradientBR = RadialGradient(
    center: Alignment(1.1, 1.1),
    radius: 1.4,
    colors: [Color(0x331040A0), Colors.transparent],
  );

  // === Typography (using Google Fonts via index.html) ===
  static const String serifFont = 'Playfair Display';
  static const String sansFont = 'Inter';

  static TextStyle heroNameStyle(double fontSize) => TextStyle(
    fontFamily: serifFont,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 1.2,
    height: 1.1,
  );

  static TextStyle sectionHeadingStyle(double fontSize) => TextStyle(
    fontFamily: serifFont,
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.6,
    height: 1.2,
  );

  static const TextStyle navStyle = TextStyle(
    fontFamily: sansFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.8,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: sansFont,
    fontSize: 15,
    color: textSecondary,
    height: 1.65,
  );

  static const TextStyle badgeStyle = TextStyle(
    fontFamily: sansFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 1.1,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: sansFont,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: gold,
    letterSpacing: 2.5,
  );

  // === Theme ===
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDeep,
    canvasColor: bgDeep,
    primaryColor: bgDeep,
    textTheme: TextTheme(
      displayLarge: heroNameStyle(56),
      bodyLarge: bodyStyle,
      labelLarge: badgeStyle,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
    ),
    colorScheme: const ColorScheme.dark(
      primary: bgDeep,
      secondary: gold,
      surface: bgCard,
      onPrimary: textPrimary,
      onSecondary: bgDeep,
      onSurface: textPrimary,
    ),
  );
}
