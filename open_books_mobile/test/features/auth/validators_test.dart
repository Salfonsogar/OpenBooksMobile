import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/logic/validators.dart';

void main() {
  group('AuthValidators.validateEmail', () {
    test('returns error for empty email', () {
      expect(AuthValidators.validateEmail(''), 'Ingresa tu correo electrónico');
    });

    test('returns error for invalid email', () {
      expect(
        AuthValidators.validateEmail('not-an-email'),
        'Ingresa un correo electrónico válido',
      );
    });

    test('returns null for valid email', () {
      expect(AuthValidators.validateEmail('test@example.com'), isNull);
    });
  });

  group('AuthValidators.validatePassword', () {
    test('returns error for empty password', () {
      expect(AuthValidators.validatePassword(''), 'Ingresa tu contraseña');
    });

    test('returns error for too short password', () {
      expect(
        AuthValidators.validatePassword('Ab1!'),
        'Mínimo 8 caracteres, mayúscula, minúscula y carácter especial',
      );
    });

    test('returns error for password missing uppercase', () {
      expect(
        AuthValidators.validatePassword('abcdef1!'),
        'Mínimo 8 caracteres, mayúscula, minúscula y carácter especial',
      );
    });

    test('returns error for password missing special character', () {
      expect(
        AuthValidators.validatePassword('Abcdefgh1'),
        'Mínimo 8 caracteres, mayúscula, minúscula y carácter especial',
      );
    });

    test('returns null for valid password', () {
      expect(AuthValidators.validatePassword('Abcdef1!'), isNull);
    });
  });

  group('AuthValidators.validateRequired', () {
    test('returns error for empty value', () {
      expect(AuthValidators.validateRequired('', 'nombre'), 'Ingresa tu nombre');
    });

    test('returns null for non-empty value', () {
      expect(AuthValidators.validateRequired('something', 'nombre'), isNull);
    });
  });

  group('AuthValidators.validateMinLength', () {
    test('returns error when value is too short', () {
      expect(
        AuthValidators.validateMinLength('ab', 5, 'nombre'),
        'El nombre debe tener al menos 5 caracteres',
      );
    });

    test('returns null for exact minimum length', () {
      expect(AuthValidators.validateMinLength('abcde', 5, 'nombre'), isNull);
    });

    test('returns null when value is long enough', () {
      expect(AuthValidators.validateMinLength('abcdef', 5, 'nombre'), isNull);
    });
  });

  group('AuthValidators.validateConfirmPassword', () {
    test('returns error for empty confirmation', () {
      expect(
        AuthValidators.validateConfirmPassword('', 'Password1!'),
        'Confirma tu contraseña',
      );
    });

    test('returns error when passwords do not match', () {
      expect(
        AuthValidators.validateConfirmPassword('Password2@', 'Password1!'),
        'Las contraseñas no coinciden',
      );
    });

    test('returns null when passwords match', () {
      expect(
        AuthValidators.validateConfirmPassword('Password1!', 'Password1!'),
        isNull,
      );
    });
  });
}
