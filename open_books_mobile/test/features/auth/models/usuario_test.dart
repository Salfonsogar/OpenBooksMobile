import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';

void main() {
  const testUserId = '550e8400-e29b-41d4-a716-446655440000';

  group('Usuario.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': testUserId,
        'userName': 'johndoe',
        'nombreCompleto': 'John Doe',
        'email': 'john@example.com',
        'estado': true,
        'fechaRegistro': '2024-06-15T08:30:00.000',
        'nombreRol': 'Administrador',
        'fotoPerfilUrl': 'https://example.com/photo.jpg',
      };

      final usuario = Usuario.fromJson(json);

      expect(usuario.id, testUserId);
      expect(usuario.userName, 'johndoe');
      expect(usuario.nombreCompleto, 'John Doe');
      expect(usuario.email, 'john@example.com');
      expect(usuario.estado, isTrue);
      expect(usuario.fechaRegistro, DateTime(2024, 6, 15, 8, 30));
      expect(usuario.nombreRol, 'Administrador');
      expect(usuario.fotoPerfilUrl, 'https://example.com/photo.jpg');
    });

    test('uses defaults for missing or null fields', () {
      final json = <String, dynamic>{
        'id': testUserId,
      };

      final usuario = Usuario.fromJson(json);

      expect(usuario.id, testUserId);
      expect(usuario.userName, '');
      expect(usuario.nombreCompleto, '');
      expect(usuario.email, '');
      expect(usuario.estado, isTrue);
      expect(usuario.nombreRol, 'Usuario');
      expect(usuario.fotoPerfilUrl, isNull);
    });

    test('parses with Id (PascalCase)', () {
      final json = {
        'Id': 'different-id-123',
        'UserName': 'testuser',
        'NombreCompleto': 'Test User',
        'Email': 'test@test.com',
        'Estado': false,
        'FechaRegistro': '2024-01-01T00:00:00.000',
        'NombreRol': 'Usuario',
      };

      final usuario = Usuario.fromJson(json);

      expect(usuario.id, 'different-id-123');
      expect(usuario.userName, 'testuser');
      expect(usuario.nombreRol, 'Usuario');
    });
  });

  group('Usuario.toJson', () {
    test('serializes correctly', () {
      final usuario = Usuario(
        id: testUserId,
        userName: 'johndoe',
        nombreCompleto: 'John Doe',
        email: 'john@example.com',
        estado: true,
        fechaRegistro: DateTime(2024, 6, 15, 8, 30),
        nombreRol: 'Administrador',
        fotoPerfilUrl: 'https://example.com/photo.jpg',
      );

      final json = usuario.toJson();

      expect(json['id'], testUserId);
      expect(json['userName'], 'johndoe');
      expect(json['nombreCompleto'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['estado'], isTrue);
      expect(json['nombreRol'], 'Administrador');
      expect(json['fotoPerfilUrl'], 'https://example.com/photo.jpg');
    });
  });

  group('Usuario.isAdmin', () {
    test('returns true when nombreRol is Administrador', () {
      final usuario = Usuario(
        id: testUserId,
        userName: 'admin',
        nombreCompleto: 'Admin User',
        email: 'admin@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Administrador',
      );
      expect(usuario.isAdmin, isTrue);
    });

    test('returns false when nombreRol is Usuario', () {
      final usuario = Usuario(
        id: testUserId,
        userName: 'user',
        nombreCompleto: 'Regular User',
        email: 'user@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
      );
      expect(usuario.isAdmin, isFalse);
    });

    test('returns false for unknown role', () {
      final usuario = Usuario(
        id: testUserId,
        userName: 'unknown',
        nombreCompleto: 'Unknown User',
        email: 'unknown@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Moderador',
      );
      expect(usuario.isAdmin, isFalse);
    });
  });
}