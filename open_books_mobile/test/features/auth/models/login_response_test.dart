import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/login_response.dart';

void main() {
  group('LoginResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'token': 'jwt_token_123',
        'username': 'testuser',
        'correo': 'test@test.com',
        'fotoPerfilUrl': null,
      };

      final response = LoginResponse.fromJson(json);

      expect(response.username, 'testuser');
      expect(response.correo, 'test@test.com');
      expect(response.token, 'jwt_token_123');
    });

    test('toJson serializes correctly', () {
      final response = LoginResponse(
        token: 'jwt_token_123',
        username: 'testuser',
        correo: 'test@test.com',
      );

      final json = response.toJson();

      expect(json['username'], 'testuser');
      expect(json['token'], 'jwt_token_123');
    });

    test('fromJson handles missing fotoPerfilUrl', () {
      final json = {
        'token': 'jwt_token_123',
        'username': 'testuser',
        'correo': 'test@test.com',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.fotoPerfilUrl, isNull);
    });
  });
}