import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/chapter_cache.dart';
import '../../data/models/epub_manifest.dart';
import '../../data/models/reader_mode.dart';
import '../../data/repositories/epub_repository.dart';
import '../../../../shared/services/datasources/historial_local_datasource.dart';

abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object?> get props => [];
}

class ReaderInitial extends ReaderState {}

class ReaderLoading extends ReaderState {
  final String step;

  const ReaderLoading({this.step = 'manifest'});

  @override
  List<Object?> get props => [step];
}

class ReaderLoaded extends ReaderState {
  final EpubManifest manifest;
  final int currentChapterIndex;
  final String currentContent;
  final Set<int> cachedChapterIndices;
  final ReaderMode mode;
  final Map<int, double> scrollPositions;

  const ReaderLoaded({
    required this.manifest,
    required this.currentChapterIndex,
    required this.currentContent,
    this.cachedChapterIndices = const {},
    this.mode = ReaderMode.reading,
    this.scrollPositions = const {},
  });

  @override
  List<Object?> get props => [manifest, currentChapterIndex, currentContent, cachedChapterIndices, mode, scrollPositions];

  ReaderLoaded copyWith({
    EpubManifest? manifest,
    int? currentChapterIndex,
    String? currentContent,
    Set<int>? cachedChapterIndices,
    ReaderMode? mode,
    Map<int, double>? scrollPositions,
  }) {
    return ReaderLoaded(
      manifest: manifest ?? this.manifest,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentContent: currentContent ?? this.currentContent,
      cachedChapterIndices: cachedChapterIndices ?? this.cachedChapterIndices,
      mode: mode ?? this.mode,
      scrollPositions: scrollPositions ?? this.scrollPositions,
    );
  }

  bool hasChapterCached(int index) => cachedChapterIndices.contains(index);

  double get scrollPosition => scrollPositions[currentChapterIndex] ?? 0.0;

  double get progressPercent => manifest.readingOrder.isEmpty
      ? 0.0
      : ((currentChapterIndex + scrollPosition) / manifest.readingOrder.length) * 100;
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
  final HistorialLocalDataSource? _historialDataSource;
  final int initialPage;
  int _usuarioId = 0;

  ReaderCubit(
    this._repository,
    this.libroId, {
    HistorialLocalDataSource? historialDataSource,
    this.initialPage = 0,
  }) : _historialDataSource = historialDataSource,
        super(ReaderInitial());

  HistorialLocalDataSource? get historialDataSource => _historialDataSource;

  ReaderMode get currentMode {
    final currentState = state;
    if (currentState is ReaderLoaded) {
      return currentState.mode;
    }
    return ReaderMode.reading;
  }

  Future<void> setReaderMode(ReaderMode mode) async {
    final currentState = state;
    if (currentState is ReaderLoaded && currentState.mode != mode) {
      await _saveProgressBeforeModeChange(currentState);
      emit(currentState.copyWith(mode: mode));
    }
  }

  Future<void> toggleMode() async {
    final currentState = state;
    if (currentState is ReaderLoaded) {
      final newMode = currentState.mode == ReaderMode.reading
          ? ReaderMode.audio
          : ReaderMode.reading;
      await _saveProgressBeforeModeChange(currentState);
      emit(currentState.copyWith(mode: newMode));
    }
  }

  Future<void> _saveProgressBeforeModeChange(ReaderLoaded state) async {
    if (_historialDataSource != null && _usuarioId > 0) {
      try {
        final scrollFraction = state.scrollPositions[state.currentChapterIndex] ?? 0.0;
        await _historialDataSource.saveProgress(
          libroId,
          _usuarioId,
          state.currentChapterIndex,
          scrollFraction,
          state.manifest.titulo,
        );
      } catch (e) {
        debugPrint('[ReaderCubit] Error saving progress before mode change: $e');
      }
    }
  }

  Future<void> cargarLibro({int? initialPage, int? usuarioId}) async {
    if (usuarioId != null && usuarioId > 0) {
      _usuarioId = usuarioId;
    }

    // Preserve current mode if already in ReaderLoaded
    ReaderMode modeToRestore = ReaderMode.reading;
    final currentState = state;
    if (currentState is ReaderLoaded) {
      modeToRestore = currentState.mode;
    }

    emit(const ReaderLoading(step: 'manifest'));
    try {
      final manifest = await _repository.getManifest(libroId);

      if (manifest.readingOrder.isEmpty) {
        emit(const ReaderError('El libro no tiene capitulos'));
        return;
      }

      int startIndex = 0;
      double scrollPosition = 0.0;
      final scrollPositions = <int, double>{};

      if (initialPage != null && initialPage > 0 && initialPage < manifest.readingOrder.length) {
        startIndex = initialPage - 1;
      } else if (this.initialPage > 0 && this.initialPage < manifest.readingOrder.length) {
        startIndex = this.initialPage - 1;
      } else if (_usuarioId > 0) {
        emit(const ReaderLoading(step: 'progress'));
        final progress = await _restoreProgress();
        if (progress != null) {
          startIndex = progress['chapterIndex'] as int;
          scrollPosition = progress['scrollPosition'] as double;
          scrollPositions[startIndex] = scrollPosition;
        }
      }

      emit(const ReaderLoading(step: 'chapter'));
      final chapterPath = manifest.readingOrder[startIndex].href;
      final content = await _repository.getResource(libroId, chapterPath);

      _chapterCache.put(startIndex, content);

      emit(ReaderLoaded(
        manifest: manifest,
        currentChapterIndex: startIndex,
        currentContent: content,
        cachedChapterIndices: {startIndex},
        mode: modeToRestore,
        scrollPositions: scrollPositions,
      ));

      _precargarSiguienteCapitulo(startIndex);
    } catch (e) {
      emit(ReaderError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<Map<String, dynamic>?> _restoreProgress() async {
    if (_historialDataSource == null || _usuarioId == 0) return null;

    try {
      final historial = await _historialDataSource.getProgress(libroId, _usuarioId);
      if (historial != null) {
        return {
          'chapterIndex': historial.currentChapterIndex,
          'scrollPosition': historial.scrollPosition,
        };
      }
    } catch (e) {
      debugPrint('[ReaderCubit] Error restoring progress: $e');
    }
    return null;
  }

  Future<void> saveProgress(double scrollPosition, {int? chapterIndex}) async {
    if (_historialDataSource == null || _usuarioId == 0) return;

    final currentState = state;
    if (currentState is! ReaderLoaded) return;

    final indexToSave = chapterIndex ?? currentState.currentChapterIndex;

    final newScrollPositions = Map<int, double>.from(currentState.scrollPositions);
    newScrollPositions[indexToSave] = scrollPosition;

    emit(currentState.copyWith(scrollPositions: newScrollPositions));

    try {
      await _historialDataSource.saveProgress(
        libroId,
        _usuarioId,
        indexToSave,
        scrollPosition,
        currentState.manifest.titulo,
      );
    } catch (e) {
      debugPrint('[ReaderCubit] Error saving progress: $e');
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
