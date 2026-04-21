import 'dart:async';

class AudioHandler {
  static final AudioHandler _instance = AudioHandler._internal();
  factory AudioHandler() => _instance;
  AudioHandler._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _isInitialized = true;
  }

  Future<void> dispose() async {
    _isInitialized = false;
  }
}