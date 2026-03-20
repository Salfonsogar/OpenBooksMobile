import '../datasources/bookmark_datasource.dart';
import '../models/bookmark.dart';

class BookmarkRepository {
  final BookmarkDataSource _dataSource;

  BookmarkRepository(this._dataSource);

  Future<int> crearBookmark({
    required int bookId,
    required int chapterIndex,
    required String title,
  }) async {
    final bookmark = Bookmark(
      bookId: bookId,
      chapterIndex: chapterIndex,
      title: title,
      createdAt: DateTime.now(),
    );
    return await _dataSource.insertBookmark(bookmark);
  }

  Future<List<Bookmark>> obtenerPorLibro(int bookId) async {
    return await _dataSource.getBookmarksByBook(bookId);
  }

  Future<int> eliminarBookmark(int id) async {
    return await _dataSource.deleteBookmark(id);
  }

  Future<void> actualizarBookmark({required int id, required String title}) async {
    await _dataSource.updateBookmark(id: id, title: title);
  }

  Future<void> eliminarTodosDeLibro(int bookId) async {
    await _dataSource.deleteBookmarksByBook(bookId);
  }

  Future<Bookmark?> obtenerPorCapitulo(int bookId, int chapterIndex) async {
    return await _dataSource.getBookmarkByChapter(bookId, chapterIndex);
  }
}
