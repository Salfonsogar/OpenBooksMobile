import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/reader_settings.dart';

class ReaderSettingsCubit extends Cubit<ReaderSettings> {
  static const String _settingsKey = 'reader_settings';
  Timer? _saveTimer;
  static const _debounceDelay = Duration(milliseconds: 500);

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

  void actualizarFontSize(double size) {
    final newSettings = state.copyWith(fontSize: size);
    emit(newSettings);
    _debounceSave(newSettings);
  }

  void actualizarLineHeight(double height) {
    final newSettings = state.copyWith(lineHeight: height);
    emit(newSettings);
    _debounceSave(newSettings);
  }

  void actualizarMarginMode(String mode) {
    final newSettings = state.copyWith(marginMode: mode);
    emit(newSettings);
    _debounceSave(newSettings);
  }

  void actualizarTheme(String theme) {
    final newSettings = state.copyWith(theme: theme);
    emit(newSettings);
    _debounceSave(newSettings);
  }

  void actualizarFontFamily(String family) {
    final newSettings = state.copyWith(fontFamily: family);
    emit(newSettings);
    _debounceSave(newSettings);
  }

  void actualizarAppTheme(String theme) {
    final newSettings = state.copyWith(appTheme: theme);
    emit(newSettings);
    _debounceSave(newSettings);
  }

  void _debounceSave(ReaderSettings settings) {
    _saveTimer?.cancel();
    _saveTimer = Timer(_debounceDelay, () => _guardarSettings(settings));
  }

  Future<void> _guardarSettings(ReaderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<void> close() {
    _saveTimer?.cancel();
    return super.close();
  }
}
