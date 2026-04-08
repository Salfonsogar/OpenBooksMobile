import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/services/tts_service.dart';
import '../../data/models/audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlaybackState> {
  final TtsService _ttsService;
  final int bookId;
  List<String> _paragraphs = [];
  int _currentIndex = 0;
  StreamSubscription? _ttsSubscription;
  
  AudioPlayerCubit(this._ttsService, this.bookId) : super(const AudioPlaybackState()) {
    _ttsSubscription = _ttsService.events.listen(_handleTtsEvent);
    _loadPosition();
  }
  
  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final position = prefs.getInt('audio_position_$bookId') ?? 0;
    _currentIndex = position;
  }

  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('audio_position_$bookId', _currentIndex);
  }
  
  void _handleTtsEvent(TtsEvent event) {
    switch (event.type) {
      case TtsEventType.completed:
        _nextParagraph();
        break;
      case TtsEventType.error:
        emit(state.copyWith(
          status: AudioStatus.error,
          errorMessage: event.errorMessage,
        ));
        break;
      case TtsEventType.cancelled:
        break;
      default:
        break;
    }
  }
  
  void loadParagraphs(List<String> paragraphs) {
    _paragraphs = paragraphs;
    _currentIndex = 0;
    emit(state.copyWith(
      status: AudioStatus.idle,
      currentParagraphIndex: 0,
      totalParagraphs: paragraphs.length,
      errorMessage: null,
    ));
  }
  
  Future<void> play() async {
    if (_paragraphs.isEmpty) return;
    
    try {
      final text = _paragraphs[_currentIndex];
      await _ttsService.speak(text);
      emit(state.copyWith(status: AudioStatus.playing, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: 'Error al reproducir: $e',
      ));
    }
  }
  
  Future<void> _nextParagraph() async {
    if (_currentIndex < _paragraphs.length - 1) {
      _currentIndex++;
      emit(state.copyWith(currentParagraphIndex: _currentIndex));
      
      try {
        await _ttsService.speak(_paragraphs[_currentIndex]);
      } catch (e) {
        emit(state.copyWith(status: AudioStatus.error, errorMessage: e.toString()));
      }
    } else {
      emit(state.copyWith(status: AudioStatus.stopped));
    }
  }
  
  Future<void> pause() async {
    try {
      await _ttsService.pause();
      emit(state.copyWith(status: AudioStatus.paused));
      await _savePosition();
    } catch (e) {
      emit(state.copyWith(status: AudioStatus.error, errorMessage: e.toString()));
    }
  }
  
  Future<void> stop() async {
    try {
      await _ttsService.stop();
      _currentIndex = 0;
      emit(state.copyWith(status: AudioStatus.stopped, currentParagraphIndex: 0));
      await _savePosition();
    } catch (e) {
      emit(state.copyWith(status: AudioStatus.error, errorMessage: e.toString()));
    }
  }
  
  Future<void> nextParagraph() async {
    await _ttsService.stop();
    if (_currentIndex < _paragraphs.length - 1) {
      _currentIndex++;
      emit(state.copyWith(currentParagraphIndex: _currentIndex));
    }
  }
  
  Future<void> previousParagraph() async {
    await _ttsService.stop();
    if (_currentIndex > 0) {
      _currentIndex--;
      emit(state.copyWith(currentParagraphIndex: _currentIndex));
    }
  }
  
  Future<void> setSpeed(double speed) async {
    try {
      await _ttsService.setSpeed(speed);
      emit(state.copyWith(speed: speed));
    } catch (e) {
      // Error de velocidad no es crítico, continuar
    }
  }
  
  @override
  Future<void> close() {
    _ttsSubscription?.cancel();
    _ttsService.stop();
    return super.close();
  }
}