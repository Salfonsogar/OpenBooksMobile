import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/reader/data/models/bookmark.dart';
import 'package:open_books_mobile/features/reader/data/repositories/bookmark_repository.dart';
import 'package:open_books_mobile/features/reader/logic/cubit/bookmark_cubit.dart';
import 'package:open_books_mobile/features/reader/logic/cubit/bookmark_state.dart';

class MockBookmarkRepository extends Mock implements BookmarkRepository {}

void main() {
  group('BookmarkCubit', () {
    late BookmarkRepository repository;

    final now = DateTime(2026, 5, 10);
    final bookmarks = [
      Bookmark(id: 1, bookId: 42, chapterIndex: 1, title: 'Chapter 1', createdAt: now),
      Bookmark(id: 2, bookId: 42, chapterIndex: 2, title: 'Chapter 2', createdAt: now),
    ];

    setUp(() {
      repository = MockBookmarkRepository();
    });

    blocTest<BookmarkCubit, BookmarkState>(
      'initial state is BookmarkInitial',
      build: () => BookmarkCubit(repository),
      verify: (cubit) {
        expect(cubit.state, isA<BookmarkInitial>());
      },
    );

    blocTest<BookmarkCubit, BookmarkState>(
      'cargarBookmarks success emits [BookmarkLoading, BookmarkLoaded]',
      setUp: () {
        when(() => repository.obtenerPorLibro(42)).thenAnswer((_) async => bookmarks);
      },
      build: () => BookmarkCubit(repository),
      act: (cubit) => cubit.cargarBookmarks(42),
      expect: () => [
        isA<BookmarkLoading>(),
        isA<BookmarkLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as BookmarkLoaded;
        expect(state.bookmarks.length, 2);
        expect(state.bookId, 42);
      },
    );

    blocTest<BookmarkCubit, BookmarkState>(
      'cargarBookmarks failure emits [BookmarkLoading, BookmarkError]',
      setUp: () {
        when(() => repository.obtenerPorLibro(42)).thenThrow(Exception('DB error'));
      },
      build: () => BookmarkCubit(repository),
      act: (cubit) => cubit.cargarBookmarks(42),
      expect: () => [
        isA<BookmarkLoading>(),
        isA<BookmarkError>(),
      ],
    );

    blocTest<BookmarkCubit, BookmarkState>(
      'crearBookmark refreshes list when on same bookId',
      setUp: () {
        when(() => repository.obtenerPorLibro(42)).thenAnswer((_) async => bookmarks);
        when(() => repository.crearBookmark(
          bookId: 42,
          chapterIndex: 3,
          title: 'Chapter 3',
        )).thenAnswer((_) async => 3);
      },
      build: () => BookmarkCubit(repository),
      act: (cubit) async {
        await cubit.cargarBookmarks(42);
        await cubit.crearBookmark(bookId: 42, chapterIndex: 3, title: 'Chapter 3');
      },
      verify: (cubit) {
        verify(() => repository.crearBookmark(
          bookId: 42,
          chapterIndex: 3,
          title: 'Chapter 3',
        )).called(1);
        verify(() => repository.obtenerPorLibro(42)).called(2);
      },
    );

    blocTest<BookmarkCubit, BookmarkState>(
      'eliminarBookmark removes bookmark from state',
      setUp: () {
        when(() => repository.obtenerPorLibro(42)).thenAnswer((_) async => bookmarks);
        when(() => repository.eliminarBookmark(1)).thenAnswer((_) async => 1);
      },
      build: () => BookmarkCubit(repository),
      act: (cubit) async {
        await cubit.cargarBookmarks(42);
        await cubit.eliminarBookmark(1, 42);
      },
      expect: () => [
        isA<BookmarkLoading>(),
        isA<BookmarkLoaded>(),
        isA<BookmarkLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as BookmarkLoaded;
        expect(state.bookmarks.length, 1);
        expect(state.bookmarks[0].id, 2);
      },
    );

    blocTest<BookmarkCubit, BookmarkState>(
      'eliminarBookmark with different bookId does not modify state',
      setUp: () {
        when(() => repository.obtenerPorLibro(42)).thenAnswer((_) async => bookmarks);
        when(() => repository.eliminarBookmark(1)).thenAnswer((_) async => 1);
      },
      build: () => BookmarkCubit(repository),
      act: (cubit) async {
        await cubit.cargarBookmarks(42);
        await cubit.eliminarBookmark(1, 99);
      },
      expect: () => [
        isA<BookmarkLoading>(),
        isA<BookmarkLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as BookmarkLoaded;
        expect(state.bookmarks.length, 2);
      },
    );

    blocTest<BookmarkCubit, BookmarkState>(
      'crearBookmark failure emits BookmarkError',
      setUp: () {
        when(() => repository.obtenerPorLibro(42)).thenAnswer((_) async => bookmarks);
        when(() => repository.crearBookmark(
          bookId: any(named: 'bookId'),
          chapterIndex: any(named: 'chapterIndex'),
          title: any(named: 'title'),
        )).thenThrow(Exception('Insert failed'));
      },
      build: () => BookmarkCubit(repository),
      act: (cubit) async {
        await cubit.cargarBookmarks(42);
        await cubit.crearBookmark(bookId: 42, chapterIndex: 4, title: 'Chapter 4');
      },
      expect: () => [
        isA<BookmarkLoading>(),
        isA<BookmarkLoaded>(),
        isA<BookmarkError>(),
      ],
    );

    blocTest<BookmarkCubit, BookmarkState>(
      'eliminarBookmark failure emits BookmarkError',
      setUp: () {
        when(() => repository.obtenerPorLibro(42)).thenAnswer((_) async => bookmarks);
        when(() => repository.eliminarBookmark(1)).thenThrow(Exception('Delete failed'));
      },
      build: () => BookmarkCubit(repository),
      act: (cubit) async {
        await cubit.cargarBookmarks(42);
        await cubit.eliminarBookmark(1, 42);
      },
      expect: () => [
        isA<BookmarkLoading>(),
        isA<BookmarkLoaded>(),
        isA<BookmarkError>(),
      ],
    );

    blocTest<BookmarkCubit, BookmarkState>(
      'tieneMarcadorEnCapitulo returns true when bookmark exists',
      setUp: () {
        when(() => repository.obtenerPorCapitulo(42, 1)).thenAnswer((_) async => bookmarks[0]);
      },
      build: () => BookmarkCubit(repository),
      act: (cubit) async {
        await cubit.tieneMarcadorEnCapitulo(42, 1);
      },
      verify: (cubit) {
        verify(() => repository.obtenerPorCapitulo(42, 1)).called(1);
      },
    );

    blocTest<BookmarkCubit, BookmarkState>(
      'tieneMarcadorEnCapitulo returns false when bookmark does not exist',
      setUp: () {
        when(() => repository.obtenerPorCapitulo(42, 99)).thenAnswer((_) async => null);
      },
      build: () => BookmarkCubit(repository),
      act: (cubit) async {
        final result = await cubit.tieneMarcadorEnCapitulo(42, 99);
        expect(result, isFalse);
      },
      verify: (cubit) {
        verify(() => repository.obtenerPorCapitulo(42, 99)).called(1);
      },
    );
  });
}
