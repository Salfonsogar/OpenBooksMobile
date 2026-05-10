import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/reader/data/datasources/bookmark_datasource.dart';
import 'package:open_books_mobile/features/reader/data/models/bookmark.dart';
import 'package:open_books_mobile/features/reader/data/repositories/bookmark_repository.dart';

class MockBookmarkDataSource extends Mock implements BookmarkDataSource {}

void main() {
  group('BookmarkRepository', () {
    late BookmarkDataSource dataSource;
    late BookmarkRepository repository;

    final now = DateTime(2026, 5, 10);
    final bookmarks = [
      Bookmark(id: 1, bookId: 42, chapterIndex: 1, title: 'Chapter 1', createdAt: now),
      Bookmark(id: 2, bookId: 42, chapterIndex: 2, title: 'Chapter 2', createdAt: now),
    ];

    setUpAll(() {
      registerFallbackValue(Bookmark(
        bookId: 0,
        chapterIndex: 0,
        title: '',
        createdAt: now,
      ));
    });

    setUp(() {
      dataSource = MockBookmarkDataSource();
      repository = BookmarkRepository(dataSource);
    });

    test('crearBookmark creates Bookmark and calls dataSource.insertBookmark', () async {
      when(() => dataSource.insertBookmark(any())).thenAnswer((_) async => 3);

      final id = await repository.crearBookmark(
        bookId: 42,
        chapterIndex: 3,
        title: 'Chapter 3',
      );

      expect(id, 3);
      verify(() => dataSource.insertBookmark(any())).called(1);
    });

    test('crearBookmark passes Bookmark with correct fields', () async {
      when(() => dataSource.insertBookmark(any())).thenAnswer((_) async => 1);

      await repository.crearBookmark(
        bookId: 42,
        chapterIndex: 3,
        title: 'Chapter 3',
      );

      verify(() => dataSource.insertBookmark(
        any(),
      )).called(1);
    });

    test('obtenerPorLibro calls dataSource.getBookmarksByBook', () async {
      when(() => dataSource.getBookmarksByBook(42)).thenAnswer((_) async => bookmarks);

      final result = await repository.obtenerPorLibro(42);

      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[1].id, 2);
      verify(() => dataSource.getBookmarksByBook(42)).called(1);
    });

    test('obtenerPorLibro returns empty list when no bookmarks', () async {
      when(() => dataSource.getBookmarksByBook(99)).thenAnswer((_) async => []);

      final result = await repository.obtenerPorLibro(99);

      expect(result, isEmpty);
    });

    test('eliminarBookmark calls dataSource.deleteBookmark', () async {
      when(() => dataSource.deleteBookmark(1)).thenAnswer((_) async => 1);

      final result = await repository.eliminarBookmark(1);

      expect(result, 1);
      verify(() => dataSource.deleteBookmark(1)).called(1);
    });

    test('eliminarBookmark returns 0 when bookmark not found', () async {
      when(() => dataSource.deleteBookmark(999)).thenAnswer((_) async => 0);

      final result = await repository.eliminarBookmark(999);

      expect(result, 0);
    });

    test('actualizarBookmark calls dataSource.updateBookmark', () async {
      when(() => dataSource.updateBookmark(id: 1, title: 'Updated')).thenAnswer((_) async => {});

      await repository.actualizarBookmark(id: 1, title: 'Updated');

      verify(() => dataSource.updateBookmark(id: 1, title: 'Updated')).called(1);
    });

    test('eliminarTodosDeLibro calls dataSource.deleteBookmarksByBook', () async {
      when(() => dataSource.deleteBookmarksByBook(42)).thenAnswer((_) async => 2);

      await repository.eliminarTodosDeLibro(42);

      verify(() => dataSource.deleteBookmarksByBook(42)).called(1);
    });

    test('obtenerPorCapitulo calls dataSource.getBookmarkByChapter', () async {
      when(() => dataSource.getBookmarkByChapter(42, 1)).thenAnswer((_) async => bookmarks[0]);

      final result = await repository.obtenerPorCapitulo(42, 1);

      expect(result, isNotNull);
      expect(result!.id, 1);
      verify(() => dataSource.getBookmarkByChapter(42, 1)).called(1);
    });

    test('obtenerPorCapitulo returns null when no bookmark found', () async {
      when(() => dataSource.getBookmarkByChapter(42, 99)).thenAnswer((_) async => null);

      final result = await repository.obtenerPorCapitulo(42, 99);

      expect(result, isNull);
    });
  });
}
