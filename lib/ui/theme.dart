import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData build() {
    // Azul mais forte e vibrante (próximo ao Azure corporativo)
    const seed = Color(0xFF0B5FFF);
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      useMaterial3: true,
    );

    final textTheme = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(fontFamily: 'Roboto', fontWeight: FontWeight.w700),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontFamily: 'Roboto', fontWeight: FontWeight.w800, fontSize: 22),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontFamily: 'Roboto', fontWeight: FontWeight.w800),
      titleSmall: base.textTheme.titleSmall?.copyWith(fontFamily: 'Roboto', fontWeight: FontWeight.w800),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
      bodySmall: base.textTheme.bodySmall?.copyWith(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
      labelMedium: base.textTheme.labelMedium?.copyWith(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
      labelSmall: base.textTheme.labelSmall?.copyWith(fontFamily: 'Roboto', fontWeight: FontWeight.w700),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.white,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(),
      dividerColor: Colors.grey.shade200,
    );
  }
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
}

BoxShadow appShadow([double opacity = 0.08]) => BoxShadow(
  color: Colors.black.withValues(alpha: opacity),
  blurRadius: 14,
  spreadRadius: 0.5,
  offset: const Offset(0, 6),
);
