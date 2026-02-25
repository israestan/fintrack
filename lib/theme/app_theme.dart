import 'package:flutter/material.dart';

class AppFontSizes {
  // Base font sizes reduced by 15% as requested (multiplied by 0.85)
  static const double extraSmall = 9.35; // 11.0 * 0.85
  static const double small = 10.2; // 12.0 * 0.85
  static const double bodySmall = 11.05; // 13.0 * 0.85
  static const double body = 11.9; // 14.0 * 0.85
  static const double subtitle = 13.6; // 16.0 * 0.85
  static const double title = 15.3; // 18.0 * 0.85
  static const double titleLarge = 17.0; // 20.0 * 0.85
  static const double headline = 18;   // 24.0 * 0.85
  static const double display = 24;    // 40.0 * 0.85
}

class AppTheme {
  // Colores definidos
  static const Color primaryColor = Color(0xFF4D1717);
  static const Color secondaryColor = Color(0xFFFBF2F3);
  static const Color unselectedColor = Colors.grey;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      surface: Colors.white,
    ),

    // Configuración global de Splash y Highlight (ripple effect)
    splashColor: primaryColor.withValues(alpha: 0.1),
    highlightColor: primaryColor.withValues(alpha: 0.1),

    // Configuración centralizada del BottomNavigationBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: secondaryColor.withValues(alpha: 0.9),
      selectedItemColor: primaryColor,
      unselectedItemColor: unselectedColor,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Aquí puedes añadir más temas (AppBar, Buttons, Text, etc.)
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}
