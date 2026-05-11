import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/register_request.dart';

void main() {
  group('RegisterRequest', () {
    test('toJson returns correct map', () {
      final request = RegisterRequest(
        userName: 'newuser',
        correo: 'new@example.com',
        contrasena: 'Password1!',
      );

      final json = request.toJson();

      expect(json['UserName'], 'newuser');
      expect(json['Correo'], 'new@example.com');
      expect(json['Contrasena'], 'Password1!');
    });
  });
}