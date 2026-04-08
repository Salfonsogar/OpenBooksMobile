import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsEventType { started, completed, cancelled, paused, error }

class TtsEvent {
  final TtsEventType type;
  final String? errorMessage;
  
  TtsEvent(this.type, [this.errorMessage]);
}

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final _eventController = StreamController<TtsEvent>.broadcast();
  
  double _speed = 1.0;
  double get speed => _speed;
  
  Stream<TtsEvent> get events => _eventController.stream;
  
  Future<void> init() async {
    await _flutterTts.setLanguage('es-ES');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      _eventController.add(TtsEvent(TtsEventType.started));
    });
    
    _flutterTts.setCompletionHandler(() {
      _eventController.add(TtsEvent(TtsEventType.completed));
    });
    
    _flutterTts.setCancelHandler(() {
      _eventController.add(TtsEvent(TtsEventType.cancelled));
    });
    
    _flutterTts.setPauseHandler(() {
      _eventController.add(TtsEvent(TtsEventType.paused));
    });
    
    _flutterTts.setErrorHandler((message) {
      _eventController.add(TtsEvent(TtsEventType.error, message.toString()));
    });
  }
  
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      _eventController.add(TtsEvent(TtsEventType.error, e.toString()));
    }
  }
  
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      _eventController.add(TtsEvent(TtsEventType.error, e.toString()));
    }
  }
  
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      _eventController.add(TtsEvent(TtsEventType.error, e.toString()));
    }
  }
  
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    final ttsSpeed = speed * 0.5;
    await _flutterTts.setSpeechRate(ttsSpeed.clamp(0.0, 1.0));
  }
  
  void dispose() {
    _flutterTts.stop();
    _eventController.close();
  }
}