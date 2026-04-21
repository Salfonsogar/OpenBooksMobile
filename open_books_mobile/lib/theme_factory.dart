import 'package:flutter/material.dart';
import 'shared/core/theme/app_theme.dart';

class ThemeFactory {
  static ThemeData build(String theme, Brightness brightness) {
    final baseTheme = brightness == Brightness.light
        ? AppTheme.lightTheme
        : AppTheme.darkTheme;

    Color surfaceColor;
    Color surfaceContainerHighestColor;
    Color surfaceContainerLowColor;
    Color onSurfaceColor;
    Color onSurfaceVariantColor;
    Color primaryColor;
    Color onPrimaryColor;
    Color onPrimaryContainerColor;
    Color primaryContainerColor;

    switch (theme) {
      case 'sepia':
        surfaceColor = const Color(0xFFF4ECD8);
        surfaceContainerHighestColor = const Color(0xFFE8DFC8);
        surfaceContainerLowColor = const Color(0xFFFAF6EE);
        onSurfaceColor = const Color(0xFF5B4636);
        onSurfaceVariantColor = const Color(0xFF7D6652);
        primaryColor = const Color(0xFF6B4423);
        onPrimaryColor = const Color(0xFFF4ECD8);
        onPrimaryContainerColor = const Color(0xFF6B4423);
        primaryContainerColor = const Color(0xFFE8D5C0);
        break;
      case 'dark':
        surfaceColor = Colors.grey[900]!;
        surfaceContainerHighestColor = Colors.grey[800]!;
        surfaceContainerLowColor = Colors.grey[850]!;
        onSurfaceColor = Colors.grey[300]!;
        onSurfaceVariantColor = Colors.grey[400]!;
        primaryColor = Colors.grey[300]!;
        onPrimaryColor = Colors.grey[900]!;
        onPrimaryContainerColor = Colors.grey[300]!;
        primaryContainerColor = Colors.grey[700]!;
        break;
      default:
        return baseTheme;
    }

    if (brightness == Brightness.light) {
      return baseTheme.copyWith(
        scaffoldBackgroundColor: surfaceColor,
        colorScheme: ColorScheme.light(
          surface: surfaceColor,
          surfaceContainerHighest: surfaceContainerHighestColor,
          surfaceContainerLow: surfaceContainerLowColor,
          onSurface: onSurfaceColor,
          onSurfaceVariant: onSurfaceVariantColor,
          primary: primaryColor,
          onPrimary: onPrimaryColor,
          onPrimaryContainer: onPrimaryContainerColor,
          primaryContainer: primaryContainerColor,
        ),
        cardTheme: CardThemeData(
          color: surfaceContainerHighestColor,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: onPrimaryColor,
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: onSurfaceColor),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceContainerHighestColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: onSurfaceVariantColor.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(color: onSurfaceColor),
          bodyLarge: TextStyle(color: onSurfaceColor),
          bodyMedium: TextStyle(color: onSurfaceColor),
          bodySmall: TextStyle(color: onSurfaceVariantColor),
          titleLarge: TextStyle(color: onSurfaceColor),
          titleMedium: TextStyle(color: onSurfaceColor),
          titleSmall: TextStyle(color: onSurfaceColor),
          labelLarge: TextStyle(color: onSurfaceColor),
          labelMedium: TextStyle(color: onSurfaceVariantColor),
          labelSmall: TextStyle(color: onSurfaceVariantColor),
        ),
      );
    } else {
      return baseTheme.copyWith(
        scaffoldBackgroundColor: surfaceColor,
        colorScheme: ColorScheme.dark(
          surface: surfaceColor,
          surfaceContainerHighest: surfaceContainerHighestColor,
          surfaceContainerLow: surfaceContainerLowColor,
          onSurface: onSurfaceColor,
          onSurfaceVariant: onSurfaceVariantColor,
          primary: primaryColor,
          onPrimary: onPrimaryColor,
          onPrimaryContainer: onPrimaryContainerColor,
          primaryContainer: primaryContainerColor,
        ),
        cardTheme: CardThemeData(
          color: surfaceContainerHighestColor,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: onPrimaryColor,
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: onSurfaceColor),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceContainerHighestColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: onSurfaceVariantColor.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(color: onSurfaceColor),
          bodyLarge: TextStyle(color: onSurfaceColor),
          bodyMedium: TextStyle(color: onSurfaceColor),
          bodySmall: TextStyle(color: onSurfaceVariantColor),
          titleLarge: TextStyle(color: onSurfaceColor),
          titleMedium: TextStyle(color: onSurfaceColor),
          titleSmall: TextStyle(color: onSurfaceColor),
          labelLarge: TextStyle(color: onSurfaceColor),
          labelMedium: TextStyle(color: onSurfaceVariantColor),
          labelSmall: TextStyle(color: onSurfaceVariantColor),
        ),
      );
    }
  }

  static ThemeMode getMode(String theme) {
    switch (theme) {
      case 'dark':
      case 'sepia':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }
}