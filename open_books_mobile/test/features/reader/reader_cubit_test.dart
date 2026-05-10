import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/reader/data/models/epub_manifest.dart';
import 'package:open_books_mobile/features/reader/data/models/reader_mode.dart';
import 'package:open_books_mobile/features/reader/data/repositories/epub_repository.dart';
import 'package:open_books_mobile/features/reader/logic/cubit/reader_cubit.dart';
import 'package:open_books_mobile/shared/services/datasources/historial_local_datasource.dart';

class MockEpubRepository extends Mock implements EpubRepository {}

class MockHistorialLocalDataSource extends Mock implements HistorialLocalDataSource {}

void main() {
  group('ReaderCubit', () {
    late EpubRepository repository;

    final readingOrder = [
      ReadingOrderItem(href: 'chapter1.xhtml', type: 'application/xhtml+xml'),
      ReadingOrderItem(href: 'chapter2.xhtml', type: 'application/xhtml+xml'),
      ReadingOrderItem(href: 'chapter3.xhtml', type: 'application/xhtml+xml'),
    ];

    final manifest = EpubManifest(
      id: 1,
      titulo: 'Test Book',
      autor: 'Test Author',
      readingOrder: readingOrder,
      toc: [
        TocItem(titulo: 'Chapter 1', href: 'chapter1.xhtml'),
        TocItem(titulo: 'Chapter 2', href: 'chapter2.xhtml'),
        TocItem(titulo: 'Chapter 3', href: 'chapter3.xhtml'),
      ],
    );

    setUp(() {
      repository = MockEpubRepository();
    });

    blocTest<ReaderCubit, ReaderState>(
      'initial state is ReaderInitial',
      build: () => ReaderCubit(repository, 1),
      verify: (cubit) {
        expect(cubit.state, isA<ReaderInitial>());
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'cargarLibro with empty reading order emits ReaderError',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer(
          (_) async => EpubManifest(
            id: 1,
            titulo: 'Empty Book',
            autor: 'Author',
            readingOrder: [],
            toc: [],
          ),
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) => cubit.cargarLibro(),
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderError('El libro no tiene capitulos'),
      ],
    );

    blocTest<ReaderCubit, ReaderState>(
      'cargarLibro with valid manifest emits ReaderLoaded',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Chapter 1 content</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) => cubit.cargarLibro(),
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.manifest.id, 1);
        expect(state.currentChapterIndex, 0);
        expect(state.currentContent, contains('Chapter 1 content'));
        expect(state.cachedChapterIndices, {0});
        expect(state.mode, ReaderMode.reading);
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'cargarCapitulo loads a different chapter',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Chapter 1</p></body></html>',
        );
        when(() => repository.getResource(1, 'chapter2.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Chapter 2</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) async {
        await cubit.cargarLibro();
        await cubit.cargarCapitulo(1);
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.currentChapterIndex, 1);
        expect(state.currentContent, contains('Chapter 2'));
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'siguienteCapitulo moves to next chapter',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Chapter 1</p></body></html>',
        );
        when(() => repository.getResource(1, 'chapter2.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Chapter 2</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) async {
        await cubit.cargarLibro();
        await cubit.siguienteCapitulo();
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.currentChapterIndex, 1);
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'siguienteCapitulo does nothing on last chapter',
      setUp: () {
        final singleChapter = EpubManifest(
          id: 1,
          titulo: 'Single',
          autor: 'Author',
          readingOrder: [
            ReadingOrderItem(href: 'ch1.xhtml', type: 'application/xhtml+xml'),
          ],
          toc: [
            TocItem(titulo: 'Ch1', href: 'ch1.xhtml'),
          ],
        );
        when(() => repository.getManifest(1)).thenAnswer((_) async => singleChapter);
        when(() => repository.getResource(1, 'ch1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Only chapter</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) async {
        await cubit.cargarLibro();
        await cubit.siguienteCapitulo();
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.currentChapterIndex, 0);
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'capituloAnterior moves to previous chapter',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Chapter 1</p></body></html>',
        );
        when(() => repository.getResource(1, 'chapter2.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Chapter 2</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) async {
        await cubit.cargarLibro();
        await cubit.cargarCapitulo(1);
        await cubit.capituloAnterior();
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
        isA<ReaderLoaded>(),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.currentChapterIndex, 0);
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'capituloAnterior does nothing on first chapter',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Chapter 1</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) async {
        await cubit.cargarLibro();
        await cubit.capituloAnterior();
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.currentChapterIndex, 0);
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'toggleMode switches between reading and audio modes',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Content</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) async {
        await cubit.cargarLibro();
        await cubit.toggleMode();
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.mode, ReaderMode.audio);
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'toggleMode switches back from audio to reading',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Content</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) async {
        await cubit.cargarLibro();
        await cubit.toggleMode();
        await cubit.toggleMode();
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
        isA<ReaderLoaded>(),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.mode, ReaderMode.reading);
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'saveProgress updates scroll positions',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Content</p></body></html>',
        );
      },
      build: () {
        final historial = MockHistorialLocalDataSource();
        when(() => historial.getProgress(1, 1)).thenAnswer((_) async => null);
        return ReaderCubit(repository, 1, historialDataSource: historial);
      },
      act: (cubit) async {
        await cubit.cargarLibro(usuarioId: 1);
        await cubit.saveProgress(0.5);
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'progress'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.scrollPositions[0], 0.5);
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'cargarLibro with repository error emits ReaderError',
      setUp: () {
        when(() => repository.getManifest(1)).thenThrow(Exception('Network error'));
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) => cubit.cargarLibro(),
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderError('Network error'),
      ],
    );

    blocTest<ReaderCubit, ReaderState>(
      'cargarCapitulo with invalid index does nothing',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Content</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) async {
        await cubit.cargarLibro();
        await cubit.cargarCapitulo(-1);
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.currentChapterIndex, 0);
      },
    );

    blocTest<ReaderCubit, ReaderState>(
      'cargarCapitulo with out-of-range index does nothing',
      setUp: () {
        when(() => repository.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => repository.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Content</p></body></html>',
        );
      },
      build: () => ReaderCubit(repository, 1),
      act: (cubit) async {
        await cubit.cargarLibro();
        await cubit.cargarCapitulo(100);
      },
      expect: () => [
        const ReaderLoading(step: 'manifest'),
        const ReaderLoading(step: 'chapter'),
        isA<ReaderLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ReaderLoaded;
        expect(state.currentChapterIndex, 0);
      },
    );
  });
}
