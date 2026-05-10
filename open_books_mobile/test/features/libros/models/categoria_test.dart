import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/libros/data/models/categoria.dart';

void main() {
  group('Categoria', () {
    group('fromJson', () {
      test('parses valid JSON with all fields correctly', () {
        final json = {
          'id': 1,
          'nombre': 'Ficción',
          'descripcion': 'Libros de ficción literaria',
        };

        final categoria = Categoria.fromJson(json);

        expect(categoria.id, equals(1));
        expect(categoria.nombre, equals('Ficción'));
        expect(categoria.descripcion, equals('Libros de ficción literaria'));
      });

      test('handles missing optional descripcion with null', () {
        final json = {'id': 2, 'nombre': 'No Ficción'};

        final categoria = Categoria.fromJson(json);

        expect(categoria.id, equals(2));
        expect(categoria.nombre, equals('No Ficción'));
        expect(categoria.descripcion, isNull);
      });

      test('handles null values with defaults', () {
        final json = {'id': 3, 'nombre': null, 'descripcion': null};

        final categoria = Categoria.fromJson(json);

        expect(categoria.nombre, equals(''));
        expect(categoria.descripcion, isNull);
      });
    });

    group('toJson', () {
      test('serializes with all fields correctly', () {
        final categoria = Categoria(
          id: 1,
          nombre: 'Ficción',
          descripcion: 'Libros de ficción',
        );

        final json = categoria.toJson();

        expect(json['id'], equals(1));
        expect(json['nombre'], equals('Ficción'));
        expect(json['descripcion'], equals('Libros de ficción'));
      });

      test('serializes without descripcion', () {
        final categoria = Categoria(id: 2, nombre: 'No Ficción');

        final json = categoria.toJson();

        expect(json['id'], equals(2));
        expect(json['nombre'], equals('No Ficción'));
        expect(json['descripcion'], isNull);
      });
    });
  });
}
