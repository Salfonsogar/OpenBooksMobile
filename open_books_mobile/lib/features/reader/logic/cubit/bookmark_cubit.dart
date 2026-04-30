import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/bookmark_repository.dart';
import 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  final BookmarkRepository _repository;

  BookmarkCubit(this._repository) : super(BookmarkInitial());

  Future<void> cargarBookmarks(int bookId) async {
    emit(BookmarkLoading());
    try {
      final bookmarks = await _repository.obtenerPorLibro(bookId);
      emit(BookmarkLoaded(bookmarks: bookmarks, bookId: bookId));
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<void> crearBookmark({
    required int bookId,
    required int chapterIndex,
    required String title,
  }) async {
    try {
      await _repository.crearBookmark(
        bookId: bookId,
        chapterIndex: chapterIndex,
        title: title,
      );
      
      // Recargar para obtener el ID generado
      final bookmarks = await _repository.obtenerPorLibro(bookId);
      emit(BookmarkLoaded(bookmarks: bookmarks, bookId: bookId));
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<void> eliminarBookmark(int id, int bookId) async {
    final currentState = state;
    try {
      await _repository.eliminarBookmark(id);
      
      if (currentState is BookmarkLoaded && currentState.bookId == bookId) {
        final updatedBookmarks = currentState.bookmarks
            .where((b) => b.id != id)
            .toList();
        emit(BookmarkLoaded(
          bookmarks: updatedBookmarks,
          bookId: bookId,
        ));
      } else {
        await cargarBookmarks(bookId);
      }
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<void> actualizarBookmark({
    required int id,
    required int bookId,
    required int chapterIndex,
    required String title,
  }) async {
    final currentState = state;
    try {
      await _repository.actualizarBookmark(id: id, title: title);
      
      if (currentState is BookmarkLoaded && currentState.bookId == bookId) {
        final updatedBookmarks = currentState.bookmarks.map((b) {
          if (b.id == id) {
            return b.copyWith(title: title);
          }
          return b;
        }).toList();
        emit(BookmarkLoaded(
          bookmarks: updatedBookmarks,
          bookId: bookId,
        ));
      } else {
        await cargarBookmarks(bookId);
      }
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<bool> tieneMarcadorEnCapitulo(int bookId, int chapterIndex) async {
    final bookmark = await _repository.obtenerPorCapitulo(bookId, chapterIndex);
    return bookmark != null;
  }
}
