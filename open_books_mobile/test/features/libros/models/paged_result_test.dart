import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/libros/data/models/libro.dart';
import 'package:open_books_mobile/features/libros/data/models/paged_result.dart';

void main() {
  group('PagedResult', () {
    group('fromJson', () {
      test('creates correct instance with proper types', () {
        final json = {
          'page': 2,
          'pageSize': 10,
          'total': 25,
          'totalPages': 3,
          'data': [
            {
              'id': 1,
              'titulo': 'Libro 1',
              'autor': 'Autor 1',
              'descripcion': 'Desc 1',
              'categorias': [],
            },
            {
              'id': 2,
              'titulo': 'Libro 2',
              'autor': 'Autor 2',
              'descripcion': 'Desc 2',
              'categorias': [],
            },
          ],
        };

        final result = PagedResult.fromJson(json, Libro.fromJson);

        expect(result.page, equals(2));
        expect(result.pageSize, equals(10));
        expect(result.total, equals(25));
        expect(result.totalPages, equals(3));
        expect(result.data.length, equals(2));
        expect(result.data, isA<List<Libro>>());
        expect(result.data.first.id, equals(1));
        expect(result.data.last.id, equals(2));
      });

      test('handles empty data list', () {
        final json = {
          'page': 1,
          'pageSize': 10,
          'total': 0,
          'totalPages': 0,
          'data': [],
        };

        final result = PagedResult.fromJson(json, Libro.fromJson);

        expect(result.data, isEmpty);
        expect(result.total, equals(0));
      });

      test('handles missing fields with defaults', () {
        final Map<String, dynamic> json = {};

        final result = PagedResult.fromJson(json, Libro.fromJson);

        expect(result.page, equals(1));
        expect(result.pageSize, equals(10));
        expect(result.total, equals(0));
        expect(result.totalPages, equals(0));
        expect(result.data, isEmpty);
      });

      test('handles null fields with defaults', () {
        final Map<String, dynamic> json = {
          'page': null,
          'pageSize': null,
          'total': null,
          'totalPages': null,
          'data': null,
        };

        final result = PagedResult.fromJson(json, Libro.fromJson);

        expect(result.page, equals(1));
        expect(result.pageSize, equals(10));
        expect(result.total, equals(0));
        expect(result.totalPages, equals(0));
        expect(result.data, isEmpty);
      });
    });
  });
}
