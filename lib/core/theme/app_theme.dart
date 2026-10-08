import 'package:flutter/material.dart';

class AppTheme {
  // Liquid Glass color palette
  static const Color bgDark = Color(0xFF080C1A);
  static const Color bgDeep = Color(0xFF0D1226);
  static const Color aquamarine = Color(0xFF00D4C8);
  static const Color indigo = Color(0xFF5B61FF);
  static const Color coral = Color(0xFFFF6B8A);
  static const Color emerald = Color(0xFF2ECC71);
  static const Color ruby = Color(0xFFE74C3C);
  static const Color amber = Color(0xFFF39C12);
  static const Color glassWhite = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        colorScheme: const ColorScheme.dark(
          primary: aquamarine,
          secondary: indigo,
          error: ruby,
          surface: bgDeep,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      );
}
