import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/auth/logic/cubit/auth_state.dart';

const testUserId = '550e8400-e29b-41d4-a716-446655440000';

void main() {
  group('AuthState equality', () {
    test('AuthInitial supports value equality', () {
      expect(AuthInitial(), equals(AuthInitial()));
    });

    test('AuthLoading supports value equality', () {
      expect(AuthLoading(), equals(AuthLoading()));
    });

    test('AuthPasswordResetSuccess supports value equality', () {
      expect(AuthPasswordResetSuccess(), equals(AuthPasswordResetSuccess()));
    });
  });

  group('AuthLoginSuccess', () {
    test('supports value equality with same user and token', () {
      final user = Usuario(
        id: testUserId,
        userName: 'test',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
      );
      expect(
        AuthLoginSuccess(usuario: user, token: 'abc'),
        equals(AuthLoginSuccess(usuario: user, token: 'abc')),
      );
    });

    test('props are correct', () {
      final user = Usuario(
        id: testUserId,
        userName: 'test',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
      );
      final state = AuthLoginSuccess(usuario: user, token: 'token123');
      expect(state.props, [user, 'token123']);
    });
  });

  group('AuthRecoverySent', () {
    test('supports value equality', () {
      expect(
        const AuthRecoverySent('message'),
        equals(const AuthRecoverySent('message')),
      );
    });

    test('does not equal with different message', () {
      expect(
        const AuthRecoverySent('message one'),
        isNot(equals(const AuthRecoverySent('message two'))),
      );
    });

    test('props are correct', () {
      const state = AuthRecoverySent('recovery email sent');
      expect(state.props, ['recovery email sent']);
    });
  });

  group('AuthError', () {
    test('supports value equality', () {
      expect(
        const AuthError('error message'),
        equals(const AuthError('error message')),
      );
    });

    test('does not equal with different message', () {
      expect(
        const AuthError('error one'),
        isNot(equals(const AuthError('error two'))),
      );
    });

    test('props are correct', () {
      const state = AuthError('some error');
      expect(state.props, ['some error']);
    });
  });
}