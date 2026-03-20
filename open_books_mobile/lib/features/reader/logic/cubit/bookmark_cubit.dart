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
      await cargarBookmarks(bookId);
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<void> eliminarBookmark(int id, int bookId) async {
    try {
      await _repository.eliminarBookmark(id);
      await cargarBookmarks(bookId);
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
    try {
      await _repository.actualizarBookmark(id: id, title: title);
      await cargarBookmarks(bookId);
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<bool> tieneMarcadorEnCapitulo(int bookId, int chapterIndex) async {
    final bookmark = await _repository.obtenerPorCapitulo(bookId, chapterIndex);
    return bookmark != null;
  }
}
