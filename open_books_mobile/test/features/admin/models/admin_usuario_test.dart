import 'package:flutter_test/flutter_test.dart';

import 'package:open_books_mobile/features/admin/usuarios/data/models/admin_usuario.dart';

void main() {
  group('AdminUsuario', () {
    test('fromJson creates AdminUsuario correctly', () {
      final json = {
        'id': 1,
        'userName': 'testuser',
        'nombreCompleto': 'Test User',
        'email': 'test@example.com',
        'estado': true,
        'sancionado': false,
        'fechaRegistro': '2024-01-15T00:00:00.000',
        'nombreRol': 'Administrador',
        'rolId': 1,
        'fotoPerfil': 'base64data',
      };

      final usuario = AdminUsuario.fromJson(json);

      expect(usuario.id, 1);
      expect(usuario.userName, 'testuser');
      expect(usuario.nombreCompleto, 'Test User');
      expect(usuario.email, 'test@example.com');
      expect(usuario.estado, isTrue);
      expect(usuario.sancionado, isFalse);
      expect(usuario.fechaRegistro, DateTime(2024, 1, 15));
      expect(usuario.nombreRol, 'Administrador');
      expect(usuario.rolId, 1);
      expect(usuario.fotoPerfilBase64, 'base64data');
      expect(usuario.isAdmin, isTrue);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {
        'id': 2,
        'userName': 'user2',
        'email': 'user2@test.com',
        'fechaRegistro': '2024-02-01T00:00:00.000',
      };

      final usuario = AdminUsuario.fromJson(json);

      expect(usuario.nombreCompleto, '');
      expect(usuario.estado, isTrue);
      expect(usuario.sancionado, isFalse);
      expect(usuario.nombreRol, 'Usuario');
      expect(usuario.rolId, 2);
      expect(usuario.fotoPerfilBase64, isNull);
      expect(usuario.isAdmin, isFalse);
    });

    test('isAdmin returns true for admin role', () {
      final admin = AdminUsuario(
        id: 1,
        userName: 'admin',
        nombreCompleto: 'Admin',
        email: 'admin@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Administrador',
        rolId: 1,
      );

      expect(admin.isAdmin, isTrue);
    });

    test('isAdmin returns false for non-admin role', () {
      final user = AdminUsuario(
        id: 2,
        userName: 'user',
        nombreCompleto: 'User',
        email: 'user@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );

      expect(user.isAdmin, isFalse);
    });

    test('supports value equality', () {
      final u1 = AdminUsuario(
        id: 1,
        userName: 'test',
        nombreCompleto: 'Test',
        email: 'test@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime(2024, 1, 1),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      final u2 = AdminUsuario(
        id: 1,
        userName: 'test',
        nombreCompleto: 'Test',
        email: 'test@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime(2024, 1, 1),
        nombreRol: 'Usuario',
        rolId: 2,
      );

      expect(u1, equals(u2));
    });
  });
}
