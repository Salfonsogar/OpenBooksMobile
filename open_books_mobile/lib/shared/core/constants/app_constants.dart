import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'OpenBooks';
  static const String appVersion = '1.0.0';

  // Tiempos
  static const int defaultTimeout = 30000;
  static const int uploadTimeout = 300000;

  // Paginación
  static const int defaultPageSize = 10;

  // Rutas
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String readerRoute = '/reader';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String readerSettingsKey = 'reader_settings';
}

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Neutral
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Reader Themes
  static const Color readerLight = Color(0xFFF8F9FA);
  static const Color readerDark = Color(0xFF121212);
  static const Color readerSepia = Color(0xFFF4ECD8);

  // Highlight Colors
  static const Color highlightYellow = Color(0xFFFFEB3B);
  static const Color highlightGreen = Color(0xFF4CAF50);
  static const Color highlightBlue = Color(0xFF2196F3);
  static const Color highlightPink = Color(0xFFE91E63);
  static const Color highlightOrange = Color(0xFFFF9800);
}
