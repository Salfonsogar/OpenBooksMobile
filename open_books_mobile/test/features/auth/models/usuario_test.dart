import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';

void main() {
  group('Usuario.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 1,
        'userName': 'johndoe',
        'nombreCompleto': 'John Doe',
        'email': 'john@example.com',
        'estado': true,
        'sancionado': false,
        'fechaRegistro': '2024-06-15T08:30:00.000',
        'nombreRol': 'Administrador',
        'rolId': 1,
        'fotoPerfil': 'base64encodedstring',
      };

      final usuario = Usuario.fromJson(json);

      expect(usuario.id, 1);
      expect(usuario.userName, 'johndoe');
      expect(usuario.nombreCompleto, 'John Doe');
      expect(usuario.email, 'john@example.com');
      expect(usuario.estado, isTrue);
      expect(usuario.sancionado, isFalse);
      expect(usuario.fechaRegistro, DateTime(2024, 6, 15, 8, 30));
      expect(usuario.nombreRol, 'Administrador');
      expect(usuario.rolId, 1);
      expect(usuario.fotoPerfilBase64, 'base64encodedstring');
    });

    test('uses defaults for missing or null fields', () {
      final json = <String, dynamic>{
        'id': 1,
      };

      final usuario = Usuario.fromJson(json);

      expect(usuario.id, 1);
      expect(usuario.userName, '');
      expect(usuario.nombreCompleto, '');
      expect(usuario.email, '');
      expect(usuario.estado, isTrue);
      expect(usuario.sancionado, isFalse);
      expect(usuario.nombreRol, 'Usuario');
      expect(usuario.rolId, 2);
      expect(usuario.fotoPerfilBase64, isNull);
    });
  });

  group('Usuario.toJson', () {
    test('serializes correctly', () {
      final usuario = Usuario(
        id: 1,
        userName: 'johndoe',
        nombreCompleto: 'John Doe',
        email: 'john@example.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime(2024, 6, 15, 8, 30),
        nombreRol: 'Administrador',
        rolId: 1,
        fotoPerfilBase64: 'base64string',
      );

      final json = usuario.toJson();

      expect(json['id'], 1);
      expect(json['userName'], 'johndoe');
      expect(json['nombreCompleto'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['estado'], isTrue);
      expect(json['sancionado'], isFalse);
      expect(json['fechaRegistro'], '2024-06-15T08:30:00.000');
      expect(json['nombreRol'], 'Administrador');
      expect(json['rolId'], 1);
      expect(json['fotoPerfil'], 'base64string');
    });
  });

  group('Usuario.isAdmin', () {
    test('returns true when rolId is 1', () {
      final usuario = Usuario(
        id: 1,
        userName: 'admin',
        nombreCompleto: 'Admin User',
        email: 'admin@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 1,
      );
      expect(usuario.isAdmin, isTrue);
    });

    test('returns false when rolId is 2 and role is not Administrador', () {
      final usuario = Usuario(
        id: 2,
        userName: 'user',
        nombreCompleto: 'Regular User',
        email: 'user@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      expect(usuario.isAdmin, isFalse);
    });

    test('returns true when nombreRol is Administrador regardless of rolId', () {
      final usuario = Usuario(
        id: 3,
        userName: 'superadmin',
        nombreCompleto: 'Super Admin',
        email: 'super@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Administrador',
        rolId: 2,
      );
      expect(usuario.isAdmin, isTrue);
    });
  });
}
