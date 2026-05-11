import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/recovery_request.dart';

void main() {
  group('RecoveryRequest', () {
    test('toJson returns correct map', () {
      final request = RecoveryRequest(correo: 'user@example.com');

      final json = request.toJson();

      expect(json, {'correo': 'user@example.com'});
    });
  });

  group('ResetPasswordRequest', () {
    test('toJson returns correct map', () {
      final request = ResetPasswordRequest(
        email: 'user@example.com',
        token: 'reset_token_abc',
        nuevaContrasena: 'NewPass1!',
      );

      final json = request.toJson();

      expect(json['Email'], 'user@example.com');
      expect(json['Token'], 'reset_token_abc');
      expect(json['NuevaContraseña'], 'NewPass1!');
    });
  });
}