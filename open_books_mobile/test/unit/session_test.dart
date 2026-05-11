import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';

class MockStorage extends Mock {
  Future<String?> read({required String key}) async => null;
  Future<void> write({required String key, required String value}) async {}
  Future<void> delete({required String key}) async {}
}

void main() {
  const testUserId = '550e8400-e29b-41d4-a716-446655440000';

  group('SessionCubit', () {
    late SessionCubit sessionCubit;

    setUp(() {
      sessionCubit = SessionCubit();
    });

    test('initial state is SessionInitial', () {
      expect(sessionCubit.state, isA<SessionInitial>());
    });

    test('SessionAuthenticated.isAdmin returns true for Administrador', () {
      final user = Usuario(
        id: testUserId,
        userName: 'test',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Administrador',
      );
      final state = SessionAuthenticated(user: user, token: 'token123');
      expect(state.isAdmin, isTrue);
    });

    test('SessionAuthenticated.isAdmin returns false for regular user', () {
      final user = Usuario(
        id: testUserId,
        userName: 'test',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
      );
      final state = SessionAuthenticated(user: user, token: 'token123');
      expect(state.isAdmin, isFalse);
    });

    test('SessionAuthenticated props are correct', () {
      final user = Usuario(
        id: testUserId,
        userName: 'test',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
      );
      final state = SessionAuthenticated(user: user, token: 'token123');
      expect(state.props, [user, 'token123']);
    });

    test('SessionAuthenticated.userId returns correct String id', () {
      final user = Usuario(
        id: testUserId,
        userName: 'test',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
      );
      final state = SessionAuthenticated(user: user, token: 'token123');
      expect(state.userId, testUserId);
    });
  });

  group('SessionState', () {
    test('SessionInitial supports value equality', () {
      expect(SessionInitial(), equals(SessionInitial()));
    });

    test('SessionLoading supports value equality', () {
      expect(SessionLoading(), equals(SessionLoading()));
    });

    test('SessionUnauthenticated supports value equality', () {
      expect(SessionUnauthenticated(), equals(SessionUnauthenticated()));
    });

    test('SessionError supports value equality', () {
      const error1 = SessionError('Error message');
      const error2 = SessionError('Error message');
      expect(error1, equals(error2));
      expect(error1.props, ['Error message']);
    });
  });
}