import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/chapter_cache.dart';
import '../../data/models/epub_manifest.dart';
import '../../data/models/reader_mode.dart';
import '../../data/repositories/epub_repository.dart';

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

  double get progressPercent => manifest.readingOrder.isEmpty
      ? 0.0
      : ((currentChapterIndex + 1) / manifest.readingOrder.length) * 100;
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
  final int initialPage;

  ReaderCubit(this._repository, this.libroId, {this.initialPage = 0}) : super(ReaderInitial());

  ReaderMode get currentMode => _currentMode;

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

  Future<void> cargarLibro({int? initialPage}) async {
    emit(ReaderLoading());
    try {
      final manifest = await _repository.getManifest(libroId);

      if (manifest.readingOrder.isEmpty) {
        emit(const ReaderError('El libro no tiene capitulos'));
        return;
      }

      final startIndex = (initialPage ?? this.initialPage) > 0 &&
              (initialPage ?? this.initialPage) < manifest.readingOrder.length
          ? (initialPage ?? this.initialPage) - 1
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
      _optimizeCache(currentState.currentChapterIndex, currentState.manifest.readingOrder.length);
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
        debugPrint('[ReaderCubit] Error precargando: $e');
      }
    });
  }

  void _optimizeCache(int currentIndex, int totalChapters) {
    const windowSize = 5;
    final indicesToKeep = <int>{};

    for (int i = currentIndex - windowSize; i <= currentIndex + windowSize; i++) {
      if (i >= 0 && i < totalChapters) {
        indicesToKeep.add(i);
      }
    }

    _chapterCache.keepOnlyIndices(indicesToKeep);
  }

  int get cachedChaptersCount => _chapterCache.length;
  List<int> get cachedIndices => _chapterCache.cachedIndices;
}
