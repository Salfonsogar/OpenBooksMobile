import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/register_request.dart';

void main() {
  group('RegisterRequest', () {
    test('toJson returns correct map', () {
      final request = RegisterRequest(
        nombreUsuario: 'newuser',
        correo: 'new@example.com',
        contrasena: 'Password1!',
        rolId: 2,
        nombreCompleto: 'New User',
      );

      final json = request.toJson();

      expect(json, {
        'nombreUsuario': 'newuser',
        'correo': 'new@example.com',
        'contrasena': 'Password1!',
        'rolId': 2,
        'nombreCompleto': 'New User',
      });
    });
  });
}
