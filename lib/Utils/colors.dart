import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF673AB7); // Deep Purple
  static const Color primaryLight = Color(0xFF9A67EA);
  static const Color primaryDark = Color(0xFF320B86);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF2196F3); // Blue
  static const Color secondaryLight = Color(0xFF6EC6FF);
  static const Color secondaryDark = Color(0xFF0069C0);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Duress Alert Colors
  static const Color duressRed = Color(0xFFD32F2F);
  static const Color duressRedLight = Color(0xFFFFEBEE);
  static const Color duressRedDark = Color(0xFFB71C1C);
  
  // Privacy Policy Colors
  static const Color privacyBlue = Color(0xFFE3F2FD);
  static const Color privacyBlueBorder = Color(0xFF90CAF9);
  
  // Error Colors
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorBorder = Color(0xFFEF9A9A);
  
  // Success Colors
  static const Color successLight = Color(0xFFE8F5E8);
  static const Color successBorder = Color(0xFFA5D6A7);
  
  // Neutral Colors
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Transparent Colors
  static const Color transparent = Color(0x00000000);
  static const Color overlay = Color(0x80000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient duressGradient = LinearGradient(
    colors: [duressRed, duressRedDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 