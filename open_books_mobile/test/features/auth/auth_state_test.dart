import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/auth/logic/cubit/auth_state.dart';

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
        id: 1,
        userName: 'test',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      expect(
        AuthLoginSuccess(usuario: user, token: 'abc'),
        equals(AuthLoginSuccess(usuario: user, token: 'abc')),
      );
    });

    test('props are correct', () {
      final user = Usuario(
        id: 1,
        userName: 'test',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      final state = AuthLoginSuccess(usuario: user, token: 'token123');
      expect(state.props, [user, 'token123']);
    });
  });

  group('AuthRegisterSuccess', () {
    test('supports value equality with same user and token', () {
      final user = Usuario(
        id: 2,
        userName: 'newuser',
        nombreCompleto: 'New User',
        email: 'new@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      expect(
        AuthRegisterSuccess(usuario: user, token: 'def'),
        equals(AuthRegisterSuccess(usuario: user, token: 'def')),
      );
    });

    test('props are correct', () {
      final user = Usuario(
        id: 2,
        userName: 'newuser',
        nombreCompleto: 'New User',
        email: 'new@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      final state = AuthRegisterSuccess(usuario: user, token: 'token456');
      expect(state.props, [user, 'token456']);
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
