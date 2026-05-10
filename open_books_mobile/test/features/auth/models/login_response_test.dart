import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/login_response.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';

void main() {
  group('LoginResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'usuario': {
          'id': 1,
          'userName': 'testuser',
          'nombreCompleto': 'Test User',
          'email': 'test@test.com',
          'estado': true,
          'sancionado': false,
          'fechaRegistro': '2024-01-15T10:30:00.000',
          'nombreRol': 'Usuario',
          'rolId': 2,
        },
        'token': 'jwt_token_123',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.usuario.id, 1);
      expect(response.usuario.userName, 'testuser');
      expect(response.usuario.email, 'test@test.com');
      expect(response.token, 'jwt_token_123');
    });

    test('toJson serializes correctly', () {
      final usuario = Usuario(
        id: 1,
        userName: 'testuser',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime(2024, 1, 15, 10, 30),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      final response = LoginResponse(usuario: usuario, token: 'jwt_token_123');

      final json = response.toJson();

      expect(json['usuario']['id'], 1);
      expect(json['token'], 'jwt_token_123');
    });
  });
}
