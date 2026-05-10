import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/reader/data/datasources/epub_datasource.dart';
import 'package:open_books_mobile/features/reader/data/models/epub_manifest.dart';
import 'package:open_books_mobile/features/reader/data/repositories/epub_repository_impl.dart';
import 'package:open_books_mobile/shared/core/exceptions/offline_reading_exception.dart';
import 'package:open_books_mobile/shared/services/datasources/book_content_local_datasource.dart';
import 'package:open_books_mobile/shared/services/network_info.dart';

class MockEpubDataSource extends Mock implements EpubDataSource {}

class MockBookContentLocalDataSource extends Mock implements BookContentLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  group('EpubRepositoryImpl', () {
    late EpubDataSource remoteDataSource;
    late BookContentLocalDataSource localDataSource;
    late NetworkInfo networkInfo;
    late EpubRepositoryImpl repository;

    final readingOrder = [
      ReadingOrderItem(href: 'chapter1.xhtml', type: 'application/xhtml+xml'),
    ];

    final manifest = EpubManifest(
      id: 1,
      titulo: 'Test Book',
      autor: 'Test Author',
      readingOrder: readingOrder,
      toc: [
        TocItem(titulo: 'Chapter 1', href: 'chapter1.xhtml'),
      ],
    );

    setUp(() {
      remoteDataSource = MockEpubDataSource();
      localDataSource = MockBookContentLocalDataSource();
      networkInfo = MockNetworkInfo();

      repository = EpubRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
        networkInfo: networkInfo,
      );
    });

    group('getManifest', () {
      test('returns local manifest when available', () async {
        when(() => localDataSource.getManifest(1)).thenAnswer((_) async => manifest);

        final result = await repository.getManifest(1);

        expect(result.id, 1);
        expect(result.titulo, 'Test Book');
        verify(() => localDataSource.getManifest(1)).called(1);
        verifyNever(() => remoteDataSource.getManifest(any()));
      });

      test('fetches from remote when not in local and saves', () async {
        when(() => localDataSource.getManifest(1)).thenAnswer((_) async => null);
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remoteDataSource.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => localDataSource.saveManifest(1, manifest)).thenAnswer((_) async => {});

        final result = await repository.getManifest(1);

        expect(result.id, 1);
        verify(() => remoteDataSource.getManifest(1)).called(1);
        verify(() => localDataSource.saveManifest(1, manifest)).called(1);
      });

      test('throws OfflineReadingException when offline and no local', () async {
        when(() => localDataSource.getManifest(1)).thenAnswer((_) async => null);
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        expect(
          () => repository.getManifest(1),
          throwsA(isA<OfflineReadingException>()),
        );
      });

      test('save failure propagates when remote fetch succeeds', () async {
        when(() => localDataSource.getManifest(1)).thenAnswer((_) async => null);
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remoteDataSource.getManifest(1)).thenAnswer((_) async => manifest);
        when(() => localDataSource.saveManifest(1, manifest)).thenThrow(Exception('Save error'));

        expect(() => repository.getManifest(1), throwsA(isA<Exception>()));
      });
    });

    group('getResource', () {
      test('returns local resource when available', () async {
        when(() => localDataSource.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Local content</p></body></html>',
        );

        final result = await repository.getResource(1, 'chapter1.xhtml');

        expect(result, '<html><body><p>Local content</p></body></html>');
        verify(() => localDataSource.getResource(1, 'chapter1.xhtml')).called(1);
        verifyNever(() => remoteDataSource.getResource(any(), any()));
      });

      test('fetches from remote when not in local and saves', () async {
        when(() => localDataSource.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => null,
        );
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remoteDataSource.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Remote content</p></body></html>',
        );
        when(() => localDataSource.saveResource(1, 'chapter1.xhtml', any())).thenAnswer((_) async => {});

        final result = await repository.getResource(1, 'chapter1.xhtml');

        expect(result, '<html><body><p>Remote content</p></body></html>');
        verify(() => remoteDataSource.getResource(1, 'chapter1.xhtml')).called(1);
        verify(() => localDataSource.saveResource(1, 'chapter1.xhtml', any())).called(1);
      });

      test('throws when offline and no local', () async {
        when(() => localDataSource.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => null,
        );
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        expect(
          () => repository.getResource(1, 'chapter1.xhtml'),
          throwsA(isA<OfflineReadingException>()),
        );
      });

      test('save failure propagates when remote fetch succeeds', () async {
        when(() => localDataSource.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => null,
        );
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remoteDataSource.getResource(1, 'chapter1.xhtml')).thenAnswer(
          (_) async => '<html><body><p>Remote content</p></body></html>',
        );
        when(() => localDataSource.saveResource(1, 'chapter1.xhtml', any())).thenThrow(
          Exception('Save error'),
        );

        expect(
          () => repository.getResource(1, 'chapter1.xhtml'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
