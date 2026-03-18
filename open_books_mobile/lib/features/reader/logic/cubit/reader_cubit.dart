import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/epub_manifest.dart';
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
  final Map<int, String> chapterContents;

  const ReaderLoaded({
    required this.manifest,
    required this.currentChapterIndex,
    required this.currentContent,
    this.chapterContents = const {},
  });

  @override
  List<Object?> get props => [manifest, currentChapterIndex, currentContent, chapterContents];

  ReaderLoaded copyWith({
    EpubManifest? manifest,
    int? currentChapterIndex,
    String? currentContent,
    Map<int, String>? chapterContents,
  }) {
    return ReaderLoaded(
      manifest: manifest ?? this.manifest,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentContent: currentContent ?? this.currentContent,
      chapterContents: chapterContents ?? this.chapterContents,
    );
  }

  String? getContentForChapter(int index) => chapterContents[index];
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

  ReaderCubit(this._repository, this.libroId) : super(ReaderInitial());

  Future<void> cargarLibro() async {
    emit(ReaderLoading());
    try {
      final manifest = await _repository.getManifest(libroId);
      
      if (manifest.readingOrder.isEmpty) {
        emit(const ReaderError('El libro no tiene capítulos'));
        return;
      }

      final firstChapter = manifest.readingOrder.first.href;
      final content = await _repository.getResource(libroId, firstChapter);

      emit(ReaderLoaded(
        manifest: manifest,
        currentChapterIndex: 0,
        currentContent: content,
        chapterContents: {0: content},
      ));
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

    try {
      final chapterPath = currentState.manifest.readingOrder[index].href;
      final content = await _repository.getResource(libroId, chapterPath);

      final newContents = Map<int, String>.from(currentState.chapterContents);
      newContents[index] = content;

      emit(currentState.copyWith(
        currentChapterIndex: index,
        currentContent: content,
        chapterContents: newContents,
      ));
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
    
    if (currentState.chapterContents.containsKey(index)) {
      return currentState.chapterContents[index];
    }
    
    await cargarCapitulo(index);
    final newState = state;
    if (newState is ReaderLoaded) {
      return newState.chapterContents[index];
    }
    return null;
  }
}
