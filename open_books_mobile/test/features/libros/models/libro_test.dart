import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/libros/data/models/libro.dart';

void main() {
  group('Libro', () {
    group('fromJson', () {
      test('parses valid JSON with all fields correctly', () {
        final json = {
          'id': 1,
          'titulo': 'El Quijote',
          'autor': 'Miguel de Cervantes',
          'descripcion': 'Una novela clásica',
          'portadaBase64': 'base64data',
          'categorias': ['Clásico', 'Aventura'],
        };

        final libro = Libro.fromJson(json);

        expect(libro.id, equals(1));
        expect(libro.titulo, equals('El Quijote'));
        expect(libro.autor, equals('Miguel de Cervantes'));
        expect(libro.descripcion, equals('Una novela clásica'));
        expect(libro.portadaBase64, equals('base64data'));
        expect(libro.categorias, equals(['Clásico', 'Aventura']));
      });

      test('handles missing optional fields with defaults', () {
        final json = {'id': 1};

        final libro = Libro.fromJson(json);

        expect(libro.id, equals(1));
        expect(libro.titulo, equals(''));
        expect(libro.autor, equals(''));
        expect(libro.descripcion, equals(''));
        expect(libro.portadaBase64, isNull);
        expect(libro.categorias, isEmpty);
      });

      test('handles null values with defaults', () {
        final json = {
          'id': 1,
          'titulo': null,
          'autor': null,
          'descripcion': null,
          'categorias': null,
        };

        final libro = Libro.fromJson(json);

        expect(libro.titulo, equals(''));
        expect(libro.autor, equals(''));
        expect(libro.descripcion, equals(''));
        expect(libro.categorias, isEmpty);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        final libro = Libro(
          id: 1,
          titulo: 'El Quijote',
          autor: 'Miguel de Cervantes',
          descripcion: 'Una novela clásica',
          portadaBase64: 'base64data',
          categorias: ['Clásico', 'Aventura'],
        );

        final json = libro.toJson();

        expect(json['id'], equals(1));
        expect(json['titulo'], equals('El Quijote'));
        expect(json['autor'], equals('Miguel de Cervantes'));
        expect(json['descripcion'], equals('Una novela clásica'));
        expect(json['portadaBase64'], equals('base64data'));
        expect(json['categorias'], equals(['Clásico', 'Aventura']));
      });

      test('serializes without optional portadaBase64', () {
        final libro = Libro(
          id: 2,
          titulo: 'Test',
          autor: 'Author',
          descripcion: 'Desc',
          categorias: [],
        );

        final json = libro.toJson();

        expect(json['portadaBase64'], isNull);
        expect(json['categorias'], isEmpty);
      });
    });
  });
}
