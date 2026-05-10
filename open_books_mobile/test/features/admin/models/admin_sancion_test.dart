import 'package:flutter_test/flutter_test.dart';

import 'package:open_books_mobile/features/admin/moderacion/data/models/admin_sancion.dart';

void main() {
  group('AdminSancion', () {
    test('fromJson creates AdminSancion correctly', () {
      final json = {
        'id': 1,
        'usuarioId': 10,
        'nombreUsuario': 'UserA',
        'tipoSancion': 'Suspensión',
        'descripcion': 'Descripción',
        'fechaInicio': '2024-01-01T00:00:00.000',
        'fechaFin': '2024-01-15T00:00:00.000',
        'activa': true,
      };

      final sancion = AdminSancion.fromJson(json);

      expect(sancion.id, 1);
      expect(sancion.usuarioId, 10);
      expect(sancion.nombreUsuario, 'UserA');
      expect(sancion.tipoSancion, 'Suspensión');
      expect(sancion.descripcion, 'Descripción');
      expect(sancion.fechaInicio, DateTime(2024, 1, 1));
      expect(sancion.fechaFin, DateTime(2024, 1, 15));
      expect(sancion.activa, isTrue);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {
        'id': 2,
        'usuarioId': 20,
        'fechaInicio': '2024-02-01T00:00:00.000',
      };

      final sancion = AdminSancion.fromJson(json);

      expect(sancion.nombreUsuario, '');
      expect(sancion.tipoSancion, '');
      expect(sancion.descripcion, isNull);
      expect(sancion.fechaFin, isNull);
      expect(sancion.activa, isTrue);
    });

    test('fromJson handles null fechaFin', () {
      final json = {
        'id': 3,
        'usuarioId': 30,
        'fechaInicio': '2024-03-01T00:00:00.000',
        'fechaFin': null,
      };

      final sancion = AdminSancion.fromJson(json);

      expect(sancion.fechaFin, isNull);
    });

    test('toJson returns correct map', () {
      final sancion = AdminSancion(
        id: 1,
        usuarioId: 10,
        nombreUsuario: 'UserA',
        tipoSancion: 'Suspensión',
        descripcion: 'Desc',
        fechaInicio: DateTime(2024, 1, 1),
        fechaFin: DateTime(2024, 1, 15),
        activa: true,
      );

      final json = sancion.toJson();

      expect(json['id'], 1);
      expect(json['usuarioId'], 10);
      expect(json['tipoSancion'], 'Suspensión');
      expect(json['descripcion'], 'Desc');
      expect(json['fechaInicio'], '2024-01-01T00:00:00.000');
      expect(json['fechaFin'], '2024-01-15T00:00:00.000');
      expect(json['activa'], isTrue);
    });

    test('toJson omits fechaFin when null', () {
      final sancion = AdminSancion(
        id: 2,
        usuarioId: 20,
        nombreUsuario: 'UserB',
        tipoSancion: 'Advertencia',
        fechaInicio: DateTime(2024, 2, 1),
        activa: false,
      );

      final json = sancion.toJson();

      expect(json.containsKey('fechaFin'), isFalse);
      expect(json['activa'], isFalse);
    });

    test('supports value equality', () {
      final s1 = AdminSancion(
        id: 1,
        usuarioId: 10,
        nombreUsuario: 'User',
        tipoSancion: 'Tipo',
        fechaInicio: DateTime(2024, 1, 1),
        activa: true,
      );
      final s2 = AdminSancion(
        id: 1,
        usuarioId: 10,
        nombreUsuario: 'User',
        tipoSancion: 'Tipo',
        fechaInicio: DateTime(2024, 1, 1),
        activa: true,
      );

      expect(s1, equals(s2));
    });
  });
}
