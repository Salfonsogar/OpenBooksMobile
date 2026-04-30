import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/highlight_datasource.dart';
import '../../data/models/highlight.dart';
import 'highlight_state.dart';

class HighlightCubit extends Cubit<HighlightState> {
  final HighlightDataSource _dataSource;
  int? _currentBookId;

  HighlightCubit(this._dataSource) : super(HighlightInitial());

  Future<void> cargarHighlights(int bookId, {int? chapterIndex}) async {
    emit(HighlightLoading());
    try {
      _currentBookId = bookId;
      final highlights = chapterIndex != null
          ? await _dataSource.getHighlightsByChapter(bookId, chapterIndex)
          : await _dataSource.getHighlightsByBook(bookId);
      emit(HighlightLoaded(
        highlights: highlights,
        currentChapter: chapterIndex ?? 0,
      ));
    } catch (e) {
      emit(HighlightError(e.toString()));
    }
  }

  Future<void> cargarHighlightsPorCapitulo(int chapterIndex) async {
    if (_currentBookId == null) return;
    emit(HighlightLoading());
    try {
      final highlights = await _dataSource.getHighlightsByChapter(
        _currentBookId!,
        chapterIndex,
      );
      emit(HighlightLoaded(
        highlights: highlights,
        currentChapter: chapterIndex,
      ));
    } catch (e) {
      emit(HighlightError(e.toString()));
    }
  }

  Future<Highlight?> crearHighlight({
    required int bookId,
    required int chapterIndex,
    required String text,
    required int startIndex,
    required int endIndex,
    required String color,
  }) async {
    try {
      final highlight = Highlight(
        bookId: bookId,
        chapterIndex: chapterIndex,
        text: text,
        startIndex: startIndex,
        endIndex: endIndex,
        color: color,
        createdAt: DateTime.now(),
      );

      final id = await _dataSource.insertHighlight(highlight);
      final newHighlight = highlight.copyWith(id: id);

      final currentState = state;
      if (currentState is HighlightLoaded && 
          currentState.currentChapter == chapterIndex) {
        final updatedHighlights = [...currentState.highlights, newHighlight];
        updatedHighlights.sort((a, b) {
          if (a.startIndex != b.startIndex) {
            return a.startIndex.compareTo(b.startIndex);
          }
          return a.endIndex.compareTo(b.endIndex);
        });
        emit(HighlightLoaded(
          highlights: updatedHighlights,
          currentChapter: currentState.currentChapter,
        ));
      } else {
        await cargarHighlightsPorCapitulo(chapterIndex);
      }

      return newHighlight;
    } catch (e) {
      return null;
    }
  }

  Future<void> eliminarHighlight(int id) async {
    try {
      await _dataSource.deleteHighlight(id);

      final currentState = state;
      if (currentState is HighlightLoaded) {
        final updatedHighlights = currentState.highlights
            .where((h) => h.id != id)
            .toList();
        emit(HighlightLoaded(
          highlights: updatedHighlights,
          currentChapter: currentState.currentChapter,
        ));
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> eliminarHighlightsPorCapitulo(int bookId, int chapterIndex) async {
    try {
      await _dataSource.deleteHighlightsByChapter(bookId, chapterIndex);

      final currentState = state;
      if (currentState is HighlightLoaded && 
          currentState.currentChapter == chapterIndex) {
        emit(HighlightLoaded(
          highlights: const [],
          currentChapter: chapterIndex,
        ));
      }
    } catch (e) {
      // Silently fail
    }
  }
}
