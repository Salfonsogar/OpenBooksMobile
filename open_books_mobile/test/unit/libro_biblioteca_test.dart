import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/biblioteca/data/models/libro_biblioteca.dart';

void main() {
  group('LibroBiblioteca', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'id': 1,
          'titulo': 'Test Book',
          'autor': 'Test Author',
          'descripcion': 'Test Description',
          'portadaBase64': 'base64data',
          'categorias': ['Fiction', 'Drama'],
          'progreso': 0.5,
          'page': 10,
          'syncStatus': 'synced',
          'lastReadAt': 1700000000000,
          'readingStreak': 5,
        };

        final libro = LibroBiblioteca.fromJson(json);

        expect(libro.id, equals(1));
        expect(libro.titulo, equals('Test Book'));
        expect(libro.autor, equals('Test Author'));
        expect(libro.descripcion, equals('Test Description'));
        expect(libro.portadaBase64, equals('base64data'));
        expect(libro.categorias, equals(['Fiction', 'Drama']));
        expect(libro.progreso, equals(0.5));
        expect(libro.page, equals(10));
        expect(libro.syncStatus, equals('synced'));
        expect(libro.lastReadAt, equals(1700000000000));
        expect(libro.readingStreak, equals(5));
      });

      test('handles missing optional fields with defaults', () {
        final json = {
          'id': 1,
          'titulo': 'Test Book',
          'autor': 'Test Author',
          'descripcion': 'Test Description',
        };

        final libro =LibroBiblioteca.fromJson(json);

        expect(libro.id, equals(1));
        expect(libro.titulo, equals('Test Book'));
        expect(libro.portadaBase64, isNull);
        expect(libro.categorias, isEmpty);
        expect(libro.progreso, equals(0.0));
        expect(libro.page, isNull);
        expect(libro.syncStatus, isNull);
      });

      test('handles null titulo and autor', () {
        final json = {
          'id': 1,
          'titulo': null,
          'autor': null,
          'descripcion': null,
        };

        final libro = LibroBiblioteca.fromJson(json);

        expect(libro.titulo, equals(''));
        expect(libro.autor, equals(''));
        expect(libro.descripcion, equals(''));
      });

      test('handles wrong progreso type (converts to double)', () {
        final json = {
          'id': 1,
          'titulo': 'Test',
          'autor': 'Author',
          'descripcion': 'Desc',
          'progreso': 50,
        };

        final libro =LibroBiblioteca.fromJson(json);

        expect(libro.progreso, equals(50.0));
        expect(libro.progreso, isA<double>());
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        final libro = LibroBiblioteca(
          id: 1,
          titulo: 'Test Book',
          autor: 'Test Author',
          descripcion: 'Test Description',
          portadaBase64: 'base64data',
          categorias: ['Fiction'],
          progreso: 0.5,
          page: 10,
          syncStatus: 'synced',
          lastReadAt: 1700000000000,
          readingStreak: 3,
        );

        final json = libro.toJson();

        expect(json['id'], equals(1));
        expect(json['titulo'], equals('Test Book'));
        expect(json['autor'], equals('Test Author'));
        expect(json['descripcion'], equals('Test Description'));
        expect(json['portadaBase64'], equals('base64data'));
        expect(json['categorias'], equals(['Fiction']));
        expect(json['progreso'], equals(0.5));
        expect(json['page'], equals(10));
        expect(json['syncStatus'], equals('synced'));
        expect(json['lastReadAt'], equals(1700000000000));
        expect(json['readingStreak'], equals(3));
      });
    });
  });
}