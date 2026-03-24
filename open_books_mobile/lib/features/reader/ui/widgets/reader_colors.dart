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

  const ReaderColors({
    required this.background,
    required this.text,
    required this.header,
    required this.icon,
    required this.accent,
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
        );
      case ReaderThemeType.dark:
        return ReaderColors(
          background: Colors.grey[900]!,
          text: Colors.grey[300]!,
          header: Colors.black,
          icon: Colors.white,
          accent: Colors.white,
        );
      case ReaderThemeType.light:
        return const ReaderColors(
          background: Colors.white,
          text: Colors.black87,
          header: Colors.white,
          icon: Colors.black87,
          accent: Color(0xFF2196F3),
        );
    }
  }
}
