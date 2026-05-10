import 'package:flutter_test/flutter_test.dart';

import 'package:open_books_mobile/features/admin/libros/data/models/admin_libro.dart';

void main() {
  group('AdminLibro', () {
    test('fromJson creates AdminLibro correctly', () {
      final json = {
        'id': 1,
        'titulo': 'Test Book',
        'autor': 'Test Author',
        'descripcion': 'A description',
        'portadaBase64': 'base64data',
        'fechaPublicacion': '2024-01-15T00:00:00.000',
        'activo': true,
        'categorias': ['Ficción', 'Aventura'],
      };

      final libro = AdminLibro.fromJson(json);

      expect(libro.id, 1);
      expect(libro.titulo, 'Test Book');
      expect(libro.autor, 'Test Author');
      expect(libro.descripcion, 'A description');
      expect(libro.portadaBase64, 'base64data');
      expect(libro.fechaPublicacion, DateTime(2024, 1, 15));
      expect(libro.activo, isTrue);
      expect(libro.categorias, const ['Ficción', 'Aventura']);
      expect(libro.portadaUrl, 'base64data');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {
        'id': 2,
        'titulo': 'Test',
        'autor': 'Author',
        'fechaPublicacion': '2024-01-01T00:00:00.000',
      };

      final libro = AdminLibro.fromJson(json);

      expect(libro.descripcion, isNull);
      expect(libro.portadaBase64, isNull);
      expect(libro.activo, isTrue);
      expect(libro.categorias, isEmpty);
      expect(libro.portadaUrl, isNull);
    });

    test('fromJson handles categorias as strings', () {
      final json = {
        'id': 3,
        'titulo': 'Test',
        'autor': 'Author',
        'fechaPublicacion': '2024-01-01T00:00:00.000',
        'categorias': ['Ficción'],
      };

      final libro = AdminLibro.fromJson(json);

      expect(libro.categorias, ['Ficción']);
    });

    test('supports value equality', () {
      final l1 = AdminLibro(
        id: 1,
        titulo: 'Book',
        autor: 'Author',
        fechaPublicacion: DateTime(2024, 1, 1),
        activo: true,
        categorias: const [],
      );
      final l2 = AdminLibro(
        id: 1,
        titulo: 'Book',
        autor: 'Author',
        fechaPublicacion: DateTime(2024, 1, 1),
        activo: true,
        categorias: const [],
      );

      expect(l1, equals(l2));
    });
  });
}
