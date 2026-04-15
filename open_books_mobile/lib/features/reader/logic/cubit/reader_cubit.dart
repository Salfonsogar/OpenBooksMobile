import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/chapter_cache.dart';
import '../../data/models/epub_manifest.dart';
import '../../data/models/reader_mode.dart';
import '../../data/repositories/epub_repository.dart';

typedef OnProgressChanged = void Function({
  required int libroId,
  required double progreso,
  required int page,
  required int totalPages,
});

abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object?> get props => [];
}

class ReaderInitial extends ReaderState {}

class ReaderLoading extends ReaderState {}

class ReaderLoaded extends ReaderState {
  final EpubManifest manifest;
  final int currentChapterIndex;
  final String currentContent;
  final Set<int> cachedChapterIndices;
  final ReaderMode mode;

  const ReaderLoaded({
    required this.manifest,
    required this.currentChapterIndex,
    required this.currentContent,
    this.cachedChapterIndices = const {},
    this.mode = ReaderMode.reading,
  });

  @override
  List<Object?> get props => [manifest, currentChapterIndex, currentContent, cachedChapterIndices, mode];

  ReaderLoaded copyWith({
    EpubManifest? manifest,
    int? currentChapterIndex,
    String? currentContent,
    Set<int>? cachedChapterIndices,
    ReaderMode? mode,
  }) {
    return ReaderLoaded(
      manifest: manifest ?? this.manifest,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentContent: currentContent ?? this.currentContent,
      cachedChapterIndices: cachedChapterIndices ?? this.cachedChapterIndices,
      mode: mode ?? this.mode,
    );
  }

  bool hasChapterCached(int index) => cachedChapterIndices.contains(index);
}

class ReaderError extends ReaderState {
  final String message;

  const ReaderError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReaderCubit extends Cubit<ReaderState> {
  final EpubRepository _repository;
  final int libroId;
  final ChapterCache _chapterCache = ChapterCache();
  ReaderMode _currentMode = ReaderMode.reading;
  
  OnProgressChanged? _onProgressChanged;
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(seconds: 1);
  int _lastSavedChapter = -1;

  ReaderMode get currentMode => _currentMode;

  void setOnProgressChanged(OnProgressChanged? callback) {
    print('[DEBUG] setOnProgressChanged called with: ${callback != null}');
    _onProgressChanged = callback;
  }

  void setReaderMode(ReaderMode mode) {
    _currentMode = mode;
    final currentState = state;
    if (currentState is ReaderLoaded) {
      emit(currentState.copyWith(mode: mode));
    }
  }

  void toggleMode() {
    _currentMode = _currentMode == ReaderMode.reading 
        ? ReaderMode.audio 
        : ReaderMode.reading;
    final currentState = state;
    if (currentState is ReaderLoaded) {
      emit(currentState.copyWith(mode: _currentMode));
    }
  }

ReaderCubit(this._repository, this.libroId, {this.initialPage = 0}) : super(ReaderInitial());

  final int initialPage;

  Future<void> cargarLibro() async {
    emit(ReaderLoading());
    try {
      final manifest = await _repository.getManifest(libroId);
      
      if (manifest.readingOrder.isEmpty) {
        emit(const ReaderError('El libro no tiene capitulos'));
        return;
      }

      final startIndex = initialPage > 0 && initialPage < manifest.readingOrder.length 
          ? initialPage - 1 
          : 0;
      
      final chapterPath = manifest.readingOrder[startIndex].href;
      final content = await _repository.getResource(libroId, chapterPath);
      
      _chapterCache.put(startIndex, content);

      emit(ReaderLoaded(
        manifest: manifest,
        currentChapterIndex: startIndex,
        currentContent: content,
        cachedChapterIndices: {startIndex},
        mode: _currentMode,
      ));

      _precargarSiguienteCapitulo(startIndex);
    } catch (e) {
      emit(ReaderError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> cargarCapitulo(int index) async {
    final currentState = state;
    if (currentState is! ReaderLoaded) return;

    if (index < 0 || index >= currentState.manifest.readingOrder.length) {
      return;
    }

    if (_chapterCache.has(index)) {
      final content = _chapterCache.get(index)!;
      emit(currentState.copyWith(
        currentChapterIndex: index,
        currentContent: content,
      ));
      _precargarSiguienteCapitulo(index);
      _onChapterChanged(index, currentState.manifest.readingOrder.length);
      return;
    }

    try {
      final chapterPath = currentState.manifest.readingOrder[index].href;
      final content = await _repository.getResource(libroId, chapterPath);

      _chapterCache.put(index, content);

      final newCachedIndices = Set<int>.from(currentState.cachedChapterIndices)..add(index);

      emit(currentState.copyWith(
        currentChapterIndex: index,
        currentContent: content,
        cachedChapterIndices: newCachedIndices,
      ));

      _precargarSiguienteCapitulo(index);
      _optimizeCache(currentState.currentChapterIndex);
      _onChapterChanged(index, currentState.manifest.readingOrder.length);
    } catch (e) {
      emit(ReaderError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> siguienteCapitulo() async {
    final currentState = state;
    if (currentState is! ReaderLoaded) return;

    final nextIndex = currentState.currentChapterIndex + 1;
    if (nextIndex < currentState.manifest.readingOrder.length) {
      await cargarCapitulo(nextIndex);
    }
  }

  Future<void> capituloAnterior() async {
    final currentState = state;
    if (currentState is! ReaderLoaded) return;

    final prevIndex = currentState.currentChapterIndex - 1;
    if (prevIndex >= 0) {
      await cargarCapitulo(prevIndex);
    }
  }

  Future<void> irACapitulo(int index) async {
    await cargarCapitulo(index);
  }

  Future<String?> obtenerContenido(int index) async {
    final currentState = state;
    if (currentState is! ReaderLoaded) return null;
    
    if (index < 0 || index >= currentState.manifest.readingOrder.length) {
      return null;
    }
    
    if (_chapterCache.has(index)) {
      return _chapterCache.get(index);
    }
    
    try {
      final chapterPath = currentState.manifest.readingOrder[index].href;
      final content = await _repository.getResource(libroId, chapterPath);
      _chapterCache.put(index, content);
      return content;
    } catch (e) {
      return null;
    }
  }

  void _precargarSiguienteCapitulo(int currentIndex) {
    final currentState = state;
    if (currentState is! ReaderLoaded) return;

    final nextIndex = currentIndex + 1;
    if (nextIndex >= currentState.manifest.readingOrder.length) return;
    if (_chapterCache.has(nextIndex)) return;

    Future.microtask(() async {
      try {
        final chapterPath = currentState.manifest.readingOrder[nextIndex].href;
        final content = await _repository.getResource(libroId, chapterPath);
        
        if (!isClosed) {
          _chapterCache.put(nextIndex, content);
        }
      } catch (e) {
      }
    });
  }

  void _optimizeCache(int currentIndex) {
    const windowSize = 5;
    final indicesToKeep = <int>{};
    
    for (int i = currentIndex - windowSize; i <= currentIndex + windowSize; i++) {
      if (i >= 0 && i < _chapterCache.length) {
        indicesToKeep.add(i);
      }
    }
    
    _chapterCache.keepOnlyIndices(indicesToKeep);
  }

  int get cachedChaptersCount => _chapterCache.length;
  List<int> get cachedIndices => _chapterCache.cachedIndices;

  void _onChapterChanged(int newChapterIndex, int totalChapters) {
    print('[DEBUG] _onChapterChanged called: chapter=$newChapterIndex, total=$totalChapters');
    if (_lastSavedChapter == newChapterIndex) return;
    _lastSavedChapter = newChapterIndex;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _saveProgress(newChapterIndex, totalChapters);
    });
  }

  void _saveProgress(int currentChapter, int totalChapters) {
    print('[DEBUG] _saveProgress called: chapter=$currentChapter, total=$totalChapters, callback=${_onProgressChanged != null}');
    if (_onProgressChanged == null) return;

    final progreso = totalChapters > 0 ? ((currentChapter + 1) / totalChapters) * 100 : 0.0;
    print('[DEBUG] Sending progress: $progreso%, page: ${currentChapter + 1}');
    
    _onProgressChanged!(
      libroId: libroId,
      progreso: progreso,
      page: currentChapter + 1,
      totalPages: totalChapters,
    );
  }

  void saveProgressNow() {
    _debounceTimer?.cancel();
    final currentState = state;
    if (currentState is ReaderLoaded) {
      _saveProgress(
        currentState.currentChapterIndex,
        currentState.manifest.readingOrder.length,
      );
    }
  }

  void onReaderClosed() {
    saveProgressNow();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    saveProgressNow();
    return super.close();
  }
}
