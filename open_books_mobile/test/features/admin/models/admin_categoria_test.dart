import 'package:flutter_test/flutter_test.dart';

import 'package:open_books_mobile/features/admin/categorias/data/models/admin_categoria.dart';

void main() {
  group('AdminCategoria', () {
    test('fromJson creates AdminCategoria correctly', () {
      final json = {
        'id': 1,
        'nombre': 'Ficción',
        'descripcion': 'Libros de ficción',
        'libros': [1, 2, 3],
      };

      final categoria = AdminCategoria.fromJson(json);

      expect(categoria.id, 1);
      expect(categoria.nombre, 'Ficción');
      expect(categoria.descripcion, 'Libros de ficción');
      expect(categoria.cantidadLibros, 3);
    });

    test('fromJson handles libros as int', () {
      final json = {
        'id': 2,
        'nombre': 'Drama',
        'libros': 5,
      };

      final categoria = AdminCategoria.fromJson(json);

      expect(categoria.id, 2);
      expect(categoria.nombre, 'Drama');
      expect(categoria.descripcion, isNull);
      expect(categoria.cantidadLibros, 5);
    });

    test('fromJson handles missing libros', () {
      final json = {
        'id': 3,
        'nombre': 'Poesía',
      };

      final categoria = AdminCategoria.fromJson(json);

      expect(categoria.id, 3);
      expect(categoria.cantidadLibros, 0);
    });

    test('toJson returns correct map', () {
      const categoria = AdminCategoria(
        id: 1,
        nombre: 'Ficción',
        descripcion: 'Libros de ficción',
        cantidadLibros: 10,
      );

      final json = categoria.toJson();

      expect(json['id'], 1);
      expect(json['nombre'], 'Ficción');
      expect(json['descripcion'], 'Libros de ficción');
      expect(json['cantidadLibros'], 10);
    });

    test('supports value equality', () {
      const c1 = AdminCategoria(id: 1, nombre: 'Ficción', cantidadLibros: 10);
      const c2 = AdminCategoria(id: 1, nombre: 'Ficción', cantidadLibros: 10);

      expect(c1, equals(c2));
    });
  });
}
