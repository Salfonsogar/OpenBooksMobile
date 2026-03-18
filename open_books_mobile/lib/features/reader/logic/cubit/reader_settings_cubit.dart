import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/reader_settings.dart';

class ReaderSettingsCubit extends Cubit<ReaderSettings> {
  static const String _settingsKey = 'reader_settings';

  ReaderSettingsCubit() : super(ReaderSettings.defaultSettings);

  Future<void> cargarSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_settingsKey);
    
    if (json != null) {
      try {
        final settings = ReaderSettings.fromJson(jsonDecode(json));
        emit(settings);
      } catch (e) {
        emit(ReaderSettings.defaultSettings);
      }
    }
  }

  Future<void> actualizarFontSize(double size) async {
    final newSettings = state.copyWith(fontSize: size);
    emit(newSettings);
    await _guardarSettings(newSettings);
  }

  Future<void> actualizarLineHeight(double height) async {
    final newSettings = state.copyWith(lineHeight: height);
    emit(newSettings);
    await _guardarSettings(newSettings);
  }

  Future<void> actualizarMarginMode(String mode) async {
    final newSettings = state.copyWith(marginMode: mode);
    emit(newSettings);
    await _guardarSettings(newSettings);
  }

  Future<void> actualizarTheme(String theme) async {
    final newSettings = state.copyWith(theme: theme);
    emit(newSettings);
    await _guardarSettings(newSettings);
  }

  Future<void> _guardarSettings(ReaderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
