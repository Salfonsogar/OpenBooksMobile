import 'package:flutter_test/flutter_test.dart';

import 'package:open_books_mobile/features/admin/sugerencias/data/models/admin_sugerencia.dart';

void main() {
  group('AdminSugerencia', () {
    test('fromJson creates AdminSugerencia correctly', () {
      final json = {
        'id': 1,
        'usuarioId': 10,
        'nombreUsuario': 'UserA',
        'titulo': 'Nueva funcionalidad',
        'descripcion': 'Agregar modo oscuro',
        'fechaCreacion': '2024-01-15T00:00:00.000',
      };

      final sugerencia = AdminSugerencia.fromJson(json);

      expect(sugerencia.id, 1);
      expect(sugerencia.usuarioId, 10);
      expect(sugerencia.nombreUsuario, 'UserA');
      expect(sugerencia.titulo, 'Nueva funcionalidad');
      expect(sugerencia.descripcion, 'Agregar modo oscuro');
      expect(sugerencia.fechaCreacion, DateTime(2024, 1, 15));
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {
        'id': 2,
      };

      final sugerencia = AdminSugerencia.fromJson(json);

      expect(sugerencia.usuarioId, 0);
      expect(sugerencia.nombreUsuario, '');
      expect(sugerencia.titulo, '');
      expect(sugerencia.descripcion, isNull);
    });

    test('fromJson handles missing fechaCreacion', () {
      final json = {'id': 3};

      final sugerencia = AdminSugerencia.fromJson(json);

      expect(sugerencia.fechaCreacion, isA<DateTime>());
    });

    test('supports value equality', () {
      final s1 = AdminSugerencia(
        id: 1,
        usuarioId: 10,
        nombreUsuario: 'User',
        titulo: 'Title',
        descripcion: 'Desc',
        fechaCreacion: DateTime(2024, 1, 1),
      );
      final s2 = AdminSugerencia(
        id: 1,
        usuarioId: 10,
        nombreUsuario: 'User',
        titulo: 'Title',
        descripcion: 'Desc',
        fechaCreacion: DateTime(2024, 1, 1),
      );

      expect(s1, equals(s2));
    });
  });
}
