import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() {
    const primary = Color(0xFFFF9500);
    const background = Color(0xFFF2F2F7);
    const surface = Color(0xFFFFFFFF);

    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFE0B2),
      secondary: primary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: Colors.black,
      onSurfaceVariant: const Color(0xFF6C6C70),
      error: const Color(0xFFFF3B30),
      onError: Colors.white,
      outline: const Color(0xFFD1D1D6),
      surfaceContainerHighest: const Color(0xFFE5E5EA),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: Color(0x40FF9500),
        selectionHandleColor: primary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        indicatorColor: primary,
        unselectedLabelColor: Color(0xFF8E8E93),
      ),
      appBarTheme: const AppBarThemeData(
        backgroundColor: background,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }

  static ThemeData darkTheme() {
    const primary = Color(0xFFFF9F0A);
    const background = Color(0xFF000000);
    const surface = Color(0xFF1C1C1E);

    final colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.black,
      primaryContainer: const Color(0xFF3A2D00),
      secondary: primary,
      onSecondary: Colors.black,
      surface: surface,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFF8E8E93),
      error: const Color(0xFFFF453A),
      onError: Colors.black,
      outline: const Color(0xFF38383A),
      surfaceContainerHighest: const Color(0xFF2C2C2E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.black,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: Color(0x40FF9F0A),
        selectionHandleColor: primary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        indicatorColor: primary,
        unselectedLabelColor: Color(0xFF636366),
      ),
      appBarTheme: const AppBarThemeData(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
