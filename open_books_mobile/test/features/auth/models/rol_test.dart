import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/rol.dart';

void main() {
  group('Rol', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Administrador',
      };

      final rol = Rol.fromJson(json);

      expect(rol.id, 1);
      expect(rol.nombre, 'Administrador');
    });

    test('supports value equality', () {
      expect(
        const Rol(id: 1, nombre: 'Administrador'),
        equals(const Rol(id: 1, nombre: 'Administrador')),
      );
    });

    test('does not equal with different id', () {
      expect(
        const Rol(id: 1, nombre: 'Usuario'),
        isNot(equals(const Rol(id: 2, nombre: 'Usuario'))),
      );
    });

    test('does not equal with different nombre', () {
      expect(
        const Rol(id: 1, nombre: 'Administrador'),
        isNot(equals(const Rol(id: 1, nombre: 'Usuario'))),
      );
    });

    test('props are correct', () {
      const rol = Rol(id: 1, nombre: 'Administrador');
      expect(rol.props, [1, 'Administrador']);
    });

    test('isAdministrador returns true for Administrador', () {
      const rol = Rol(id: 1, nombre: 'Administrador');
      expect(rol.isAdministrador, isTrue);
    });

    test('isAdministrador returns false for other roles', () {
      const rol = Rol(id: 2, nombre: 'Usuario');
      expect(rol.isAdministrador, isFalse);
    });
  });
}
