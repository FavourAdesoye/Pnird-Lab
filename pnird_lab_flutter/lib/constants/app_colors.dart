import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2D2D2D);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF666666);
  
  // Status Colors
  static const Color success = Color(0xFF38A169);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFDD6B20);
  static const Color info = Color(0xFF3182CE);
  
  // Accent Colors
  static const Color accentBlue = Color(0xFF3182CE);
  static const Color accentPurple = Color(0xFF805AD5);
  static const Color accentPink = Color(0xFFD53F8C);
  
  // Social Media Colors
  static const Color likeColor = Color(0xFFE53E3E);
  static const Color commentColor = Color(0xFF3182CE);
  static const Color shareColor = Color(0xFF38A169);
  static const Color bookmarkColor = Color(0xFFDD6B20);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA500),
  ];
  
  static const List<Color> darkGradient = [
    Color(0xFF000000),
    Color(0xFF1A1A1A),
  ];
  
  // Opacity Variations
  static Color primaryYellowWithOpacity(double opacity) => 
      primaryYellow.withOpacity(opacity);
  
  static Color primaryBlackWithOpacity(double opacity) => 
      primaryBlack.withOpacity(opacity);
  
  static Color primaryWhiteWithOpacity(double opacity) => 
      primaryWhite.withOpacity(opacity);
}

