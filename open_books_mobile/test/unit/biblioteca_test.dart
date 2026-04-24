import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/biblioteca/data/models/libro_biblioteca.dart';
import 'package:open_books_mobile/features/biblioteca/logic/cubit/biblioteca_cubit.dart';
import 'package:open_books_mobile/shared/core/enums/download_status.dart';

void main() {
  group('BibliotecaState', () {
    test('BibliotecaInitial supports value equality', () {
      expect(BibliotecaInitial(), equals(BibliotecaInitial()));
    });

    test('BibliotecaLoading supports value equality', () {
      expect(BibliotecaLoading(), equals(BibliotecaLoading()));
    });

    test('BibliotecaError supports value equality', () {
      const error1 = BibliotecaError('Error message');
      const error2 = BibliotecaError('Error message');
      expect(error1, equals(error2));
      expect(error1.props, ['Error message']);
    });
  });

  group('BibliotecaLoaded', () {
    final testLibros = [
      const LibroBiblioteca(
        id: 1,
        titulo: 'Book 1',
        autor: 'Author 1',
        descripcion: 'Desc 1',
        categorias: ['Fiction'],
      ),
      const LibroBiblioteca(
        id: 2,
        titulo: 'Book 2',
        autor: 'Author 2',
        descripcion: 'Desc 2',
        categorias: ['Drama'],
      ),
    ];

    test('supports value equality', () {
      final loaded1 = BibliotecaLoaded(
        libros: testLibros,
        downloadedStatus: const {1: true},
      );
      final loaded2 = BibliotecaLoaded(
        libros: testLibros,
        downloadedStatus: const {1: true},
      );
      expect(loaded1, equals(loaded2));
    });

    test('tieneLibro returns true when book exists', () {
      final state = BibliotecaLoaded(libros: testLibros);
      expect(state.tieneLibro(1), isTrue);
      expect(state.tieneLibro(2), isTrue);
    });

    test('tieneLibro returns false when book does not exist', () {
      final state = BibliotecaLoaded(libros: testLibros);
      expect(state.tieneLibro(999), isFalse);
    });

    test('isDownloaded returns correct status', () {
      final state = BibliotecaLoaded(
        libros: testLibros,
        downloadedStatus: const {1: true, 2: false},
      );
      expect(state.isDownloaded(1), isTrue);
      expect(state.isDownloaded(2), isFalse);
    });

    test('isDownloaded returns false for unknown books', () {
      final state = BibliotecaLoaded(libros: testLibros);
      expect(state.isDownloaded(999), isFalse);
    });

    test('getDownloadStatus returns correct status', () {
      final state = BibliotecaLoaded(
        libros: testLibros,
        downloadStatuses: const {
          1: DownloadStatus.completed,
          2: DownloadStatus.downloading,
        },
      );
      expect(state.getDownloadStatus(1), equals(DownloadStatus.completed));
      expect(state.getDownloadStatus(2), equals(DownloadStatus.downloading));
    });

    test('getDownloadStatus returns notDownloaded for unknown books', () {
      final state = BibliotecaLoaded(libros: testLibros);
      expect(state.getDownloadStatus(999), equals(DownloadStatus.notDownloaded));
    });

    test('copyWith creates new instance with updated values', () {
      final original = BibliotecaLoaded(
        libros: testLibros,
        downloadedStatus: const {1: true},
      );
      final updated = original.copyWith(
        downloadedStatus: const {1: false, 2: true},
      );

      expect(original.downloadedStatus, equals({1: true}));
      expect(updated.downloadedStatus, equals({1: false, 2: true}));
      expect(updated.libros, equals(testLibros));
    });
  });
}