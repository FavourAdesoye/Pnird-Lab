import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  
  // Secondary Colors
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color lightGrey = Color(0xFF333333);
  static const Color textGrey = Color(0xFFB0B0B0);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFDD6B20);
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2D2D2D);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF666666);
  
  // Accent Colors
  static const Color accentBlue = Color(0xFF3182CE);
  static const Color accentPurple = Color(0xFF805AD5);
  static const Color accentPink = Color(0xFFD53F8C);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.amber,
    primaryColor: primaryYellow,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlack,
      foregroundColor: primaryWhite,
      elevation: 0,
      centerTitle: false,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryYellow,
      secondary: accentBlue,
      surface: primaryWhite,
      background: Colors.grey,
      error: errorRed,
      onPrimary: primaryBlack,
      onSecondary: primaryWhite,
      onSurface: primaryBlack,
      onBackground: primaryBlack,
      onError: primaryWhite,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: primaryBlack, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: primaryBlack, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: primaryBlack, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: primaryBlack),
      bodyMedium: TextStyle(color: primaryBlack),
      bodySmall: TextStyle(color: textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: primaryBlack,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryYellow, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryYellow, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryYellow, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.amber,
    primaryColor: primaryYellow,
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlack,
      foregroundColor: primaryWhite,
      elevation: 0,
      centerTitle: false,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryYellow,
      secondary: accentBlue,
      surface: surfaceDark,
      background: backgroundDark,
      error: errorRed,
      onPrimary: primaryBlack,
      onSecondary: primaryWhite,
      onSurface: textPrimary,
      onBackground: textPrimary,
      onError: primaryWhite,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      bodySmall: TextStyle(color: textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: primaryBlack,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryYellow, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryYellow, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryYellow, width: 2),
      ),
      filled: true,
      fillColor: cardDark,
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: primaryBlack,
    ),
  );

  // Custom Widget Themes
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  // Custom Colors for specific use cases
  static const Color likeColor = errorRed;
  static const Color commentColor = accentBlue;
  static const Color shareColor = successGreen;
  static const Color bookmarkColor = warningOrange;
}
