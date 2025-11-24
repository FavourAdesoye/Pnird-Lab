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

  // Light Theme - Improved
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.amber,
    primaryColor: primaryYellow,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Soft off-white
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryYellow, // Yellow app bar in light mode
      foregroundColor: primaryBlack, // Black text/icons on yellow
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: primaryBlack),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryYellow,
      secondary: accentBlue,
      surface: Color(0xFFFFFFFF), // Pure white for cards
      background: Color(0xFFF5F5F5), // Soft grey background
      error: errorRed,
      onPrimary: primaryBlack,
      onSecondary: primaryWhite,
      onSurface: Color(0xFF1A1A1A), // Dark text on light surface
      onBackground: Color(0xFF1A1A1A), // Dark text on light background
      onError: primaryWhite,
      surfaceVariant: Color(0xFFF0F0F0), // Lighter variant for subtle backgrounds
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 32),
      headlineMedium: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 28),
      headlineSmall: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
      titleLarge: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600, fontSize: 22),
      titleMedium: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600, fontSize: 18),
      titleSmall: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: TextStyle(color: Color(0xFF2D2D2D), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF2D2D2D), fontSize: 14),
      bodySmall: TextStyle(color: Color(0xFF666666), fontSize: 12),
      labelLarge: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: Color(0xFF666666), fontSize: 12),
      labelSmall: TextStyle(color: Color(0xFF999999), fontSize: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: primaryBlack,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryYellow, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFF1A1A1A),
      iconColor: Color(0xFF666666),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: 1,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFFFFFFFF),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: primaryYellow,
      unselectedItemColor: Color(0xFF666666),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
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
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryBlack,
      selectedItemColor: primaryYellow, // Yellow for active tabs in dark mode
      unselectedItemColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
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
