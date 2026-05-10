import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/reader/data/datasources/highlight_datasource.dart';
import 'package:open_books_mobile/features/reader/data/models/highlight.dart';
import 'package:open_books_mobile/features/reader/logic/cubit/highlight_cubit.dart';
import 'package:open_books_mobile/features/reader/logic/cubit/highlight_state.dart';

class MockHighlightDataSource extends Mock implements HighlightDataSource {}

void main() {
  group('HighlightCubit', () {
    late HighlightDataSource dataSource;

    final now = DateTime(2026, 5, 10);
    final highlights = [
      Highlight(id: 1, bookId: 42, chapterIndex: 1, text: 'first highlight', startIndex: 0, endIndex: 5, color: 'yellow', createdAt: now),
      Highlight(id: 2, bookId: 42, chapterIndex: 2, text: 'second highlight', startIndex: 10, endIndex: 18, color: 'green', createdAt: now),
    ];

    setUpAll(() {
      registerFallbackValue(Highlight(
        bookId: 0,
        chapterIndex: 0,
        text: '',
        startIndex: 0,
        endIndex: 0,
        color: '',
        createdAt: now,
      ));
    });

    setUp(() {
      dataSource = MockHighlightDataSource();
    });

    blocTest<HighlightCubit, HighlightState>(
      'initial state is HighlightInitial',
      build: () => HighlightCubit(dataSource),
      verify: (cubit) {
        expect(cubit.state, isA<HighlightInitial>());
      },
    );

    blocTest<HighlightCubit, HighlightState>(
      'cargarHighlights by book success emits [HighlightLoading, HighlightLoaded]',
      setUp: () {
        when(() => dataSource.getHighlightsByBook(42)).thenAnswer((_) async => highlights);
      },
      build: () => HighlightCubit(dataSource),
      act: (cubit) => cubit.cargarHighlights(42),
      expect: () => [
        isA<HighlightLoading>(),
        isA<HighlightLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HighlightLoaded;
        expect(state.highlights.length, 2);
        expect(state.currentChapter, 0);
      },
    );

    blocTest<HighlightCubit, HighlightState>(
      'cargarHighlights by chapter success emits [HighlightLoading, HighlightLoaded]',
      setUp: () {
        when(() => dataSource.getHighlightsByChapter(42, 1)).thenAnswer(
          (_) async => [highlights[0]],
        );
      },
      build: () => HighlightCubit(dataSource),
      act: (cubit) => cubit.cargarHighlights(42, chapterIndex: 1),
      expect: () => [
        isA<HighlightLoading>(),
        isA<HighlightLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HighlightLoaded;
        expect(state.highlights.length, 1);
        expect(state.currentChapter, 1);
      },
    );

    blocTest<HighlightCubit, HighlightState>(
      'cargarHighlights failure emits [HighlightLoading, HighlightError]',
      setUp: () {
        when(() => dataSource.getHighlightsByBook(42)).thenThrow(Exception('DB error'));
      },
      build: () => HighlightCubit(dataSource),
      act: (cubit) => cubit.cargarHighlights(42),
      expect: () => [
        isA<HighlightLoading>(),
        isA<HighlightError>(),
      ],
    );

    blocTest<HighlightCubit, HighlightState>(
      'crearHighlight adds highlight to current list',
      setUp: () {
        when(() => dataSource.getHighlightsByBook(42)).thenAnswer((_) async => highlights);
        when(() => dataSource.insertHighlight(any())).thenAnswer((_) async => 3);
      },
      build: () => HighlightCubit(dataSource),
      act: (cubit) async {
        await cubit.cargarHighlights(42);
        await cubit.crearHighlight(
          bookId: 42,
          chapterIndex: 0,
          text: 'new highlight',
          startIndex: 20,
          endIndex: 33,
          color: 'blue',
        );
      },
      expect: () => [
        isA<HighlightLoading>(),
        isA<HighlightLoaded>(),
        isA<HighlightLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HighlightLoaded;
        expect(state.highlights.length, 3);
      },
    );

    blocTest<HighlightCubit, HighlightState>(
      'crearHighlight does not add when on different chapter',
      setUp: () {
        when(() => dataSource.getHighlightsByBook(42)).thenAnswer((_) async => highlights);
        when(() => dataSource.insertHighlight(any())).thenAnswer((_) async => 3);
      },
      build: () => HighlightCubit(dataSource),
      act: (cubit) async {
        await cubit.cargarHighlights(42);
        await cubit.crearHighlight(
          bookId: 42,
          chapterIndex: 5,
          text: 'different chapter',
          startIndex: 0,
          endIndex: 10,
          color: 'red',
        );
      },
      expect: () => [
        isA<HighlightLoading>(),
        isA<HighlightLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HighlightLoaded;
        expect(state.highlights.length, 2);
      },
    );

    blocTest<HighlightCubit, HighlightState>(
      'crearHighlight failure returns null and does not change state',
      setUp: () {
        when(() => dataSource.getHighlightsByBook(42)).thenAnswer((_) async => highlights);
        when(() => dataSource.insertHighlight(any())).thenThrow(Exception('Insert failed'));
      },
      build: () => HighlightCubit(dataSource),
      act: (cubit) async {
        await cubit.cargarHighlights(42);
        final result = await cubit.crearHighlight(
          bookId: 42,
          chapterIndex: 0,
          text: 'failing',
          startIndex: 0,
          endIndex: 4,
          color: 'yellow',
        );
        expect(result, isNull);
      },
      expect: () => [
        isA<HighlightLoading>(),
        isA<HighlightLoaded>(),
      ],
    );

    blocTest<HighlightCubit, HighlightState>(
      'eliminarHighlight removes highlight from state',
      setUp: () {
        when(() => dataSource.getHighlightsByBook(42)).thenAnswer((_) async => highlights);
        when(() => dataSource.deleteHighlight(1)).thenAnswer((_) async => 1);
      },
      build: () => HighlightCubit(dataSource),
      act: (cubit) async {
        await cubit.cargarHighlights(42);
        await cubit.eliminarHighlight(1);
      },
      expect: () => [
        isA<HighlightLoading>(),
        isA<HighlightLoaded>(),
        isA<HighlightLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HighlightLoaded;
        expect(state.highlights.length, 1);
        expect(state.highlights[0].id, 2);
      },
    );

    test('eliminarHighlight with non-existent id refreshes state', () async {
      when(() => dataSource.getHighlightsByBook(42)).thenAnswer((_) async => highlights);
      when(() => dataSource.deleteHighlight(999)).thenAnswer((_) async => 0);

      final cubit = HighlightCubit(dataSource);
      await cubit.cargarHighlights(42);
      await cubit.eliminarHighlight(999);

      final state = cubit.state;
      expect(state, isA<HighlightLoaded>());
      expect((state as HighlightLoaded).highlights.length, 2);
    });

    blocTest<HighlightCubit, HighlightState>(
      'eliminarHighlightsPorCapitulo clears chapter highlights',
      setUp: () {
        when(() => dataSource.getHighlightsByBook(42)).thenAnswer((_) async => highlights);
        when(() => dataSource.deleteHighlightsByChapter(42, 1)).thenAnswer((_) async => 1);
      },
      build: () => HighlightCubit(dataSource),
      act: (cubit) async {
        await cubit.cargarHighlights(42);
        await cubit.eliminarHighlightsPorCapitulo(42, 1);
      },
      expect: () => [
        isA<HighlightLoading>(),
        isA<HighlightLoaded>(),
      ],
    );

    blocTest<HighlightCubit, HighlightState>(
      'cargarHighlightsPorCapitulo after book load succeeds',
      setUp: () {
        when(() => dataSource.getHighlightsByBook(42)).thenAnswer((_) async => highlights);
        when(() => dataSource.getHighlightsByChapter(42, 1)).thenAnswer(
          (_) async => [highlights[0]],
        );
      },
      build: () => HighlightCubit(dataSource),
      act: (cubit) async {
        await cubit.cargarHighlights(42);
        await cubit.cargarHighlightsPorCapitulo(1);
      },
      expect: () => [
        isA<HighlightLoading>(),
        isA<HighlightLoaded>(),
        isA<HighlightLoading>(),
        isA<HighlightLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HighlightLoaded;
        expect(state.highlights.length, 1);
        expect(state.currentChapter, 1);
      },
    );
  });
}
