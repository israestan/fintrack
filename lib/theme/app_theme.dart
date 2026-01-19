import 'package:flutter/material.dart';

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
