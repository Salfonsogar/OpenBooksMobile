import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/login_request.dart';

void main() {
  group('LoginRequest', () {
    test('toJson returns correct map', () {
      final request = LoginRequest(
        correo: 'test@example.com',
        contrasena: 'Password1!',
      );

      final json = request.toJson();

      expect(json, {
        'correo': 'test@example.com',
        'contrasena': 'Password1!',
      });
    });
  });
}
