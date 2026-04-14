import 'package:flutter/material.dart';

enum ReaderThemeType {
  light,
  dark,
  sepia,
}

class ReaderColors {
  final Color background;
  final Color text;
  final Color header;
  final Color icon;
  final Color accent;
  final Color surface;

  const ReaderColors({
    required this.background,
    required this.text,
    required this.header,
    required this.icon,
    required this.accent,
    required this.surface,
  });

  static ReaderColors fromTheme(ReaderThemeType theme) {
    switch (theme) {
      case ReaderThemeType.sepia:
        return const ReaderColors(
          background: Color(0xFFF4ECD8),
          text: Color(0xFF5B4636),
          header: Color(0xFFF4ECD8),
          icon: Color(0xFF5B4636),
          accent: Color(0xFF8B4513),
          surface: Color(0xFFE8DFC8),
        );
      case ReaderThemeType.dark:
        return ReaderColors(
          background: Colors.grey[900]!,
          text: Colors.grey[300]!,
          header: Colors.black,
          icon: Colors.white,
          accent: Colors.white,
          surface: Colors.grey[800]!,
        );
      case ReaderThemeType.light:
        return const ReaderColors(
          background: Colors.white,
          text: Colors.black87,
          header: Colors.white,
          icon: Colors.black87,
          accent: Color(0xFF2196F3),
          surface: Color(0xFFF1F5F9),
        );
    }
  }
}
