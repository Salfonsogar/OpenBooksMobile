import 'package:flutter_test/flutter_test.dart';

import 'package:open_books_mobile/features/admin/moderacion/data/models/admin_rol.dart';

void main() {
  group('AdminRol', () {
    test('fromJson creates AdminRol correctly', () {
      final json = {
        'id': 1,
        'name': 'Administrador',
      };

      final rol = AdminRol.fromJson(json);

      expect(rol.id, 1);
      expect(rol.nombre, 'Administrador');
    });

    test('fromJson uses name field from API', () {
      final json = {
        'id': 2,
        'name': 'Usuario',
      };

      final rol = AdminRol.fromJson(json);

      expect(rol.id, 2);
      expect(rol.nombre, 'Usuario');
    });

    test('fromJson handles missing name with default', () {
      final json = {'id': 3};

      final rol = AdminRol.fromJson(json);

      expect(rol.nombre, '');
    });

    test('toJson returns correct map with name key', () {
      const rol = AdminRol(id: 1, nombre: 'Administrador');

      final json = rol.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Administrador');
    });

    test('isAdministrador returns true for administrador role', () {
      const rol = AdminRol(id: 1, nombre: 'Administrador');

      expect(rol.isAdministrador, isTrue);
    });

    test('isAdministrador returns false for non-administrador role', () {
      const rol = AdminRol(id: 2, nombre: 'Usuario');

      expect(rol.isAdministrador, isFalse);
    });

    test('isAdministrador is case insensitive', () {
      const rol = AdminRol(id: 1, nombre: 'administrador');

      expect(rol.isAdministrador, isTrue);
    });

    test('supports value equality', () {
      const r1 = AdminRol(id: 1, nombre: 'Admin');
      const r2 = AdminRol(id: 1, nombre: 'Admin');

      expect(r1, equals(r2));
    });
  });
}
