import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';

class MockStorage extends Mock {
  Future<String?> read({required String key}) async => null;
  Future<void> write({required String key, required String value}) async {}
  Future<void> delete({required String key}) async {}
}

void main() {
  group('SessionCubit', () {
    late SessionCubit sessionCubit;

    setUp(() {
      sessionCubit = SessionCubit();
    });

    test('initial state is SessionInitial', () {
      expect(sessionCubit.state, isA<SessionInitial>());
    });

    test('SessionAuthenticated.isAdmin returns true for rolId 1', () {
      const state = SessionAuthenticated(
        userId: 1,
        userName: 'test',
        email: 'test@test.com',
        nombreCompleto: 'Test User',
        nombreRol: 'Usuario',
        rolId: 1,
        sancionado: false,
        token: 'token123',
      );
      expect(state.isAdmin, isTrue);
    });

    test('SessionAuthenticated.isAdmin returns true for administrator role', () {
      const state = SessionAuthenticated(
        userId: 1,
        userName: 'test',
        email: 'test@test.com',
        nombreCompleto: 'Test User',
        nombreRol: 'Administrador',
        rolId: 2,
        sancionado: false,
        token: 'token123',
      );
      expect(state.isAdmin, isTrue);
    });

    test('SessionAuthenticated.isAdmin returns false for regular user', () {
      const state = SessionAuthenticated(
        userId: 1,
        userName: 'test',
        email: 'test@test.com',
        nombreCompleto: 'Test User',
        nombreRol: 'Usuario',
        rolId: 2,
        sancionado: false,
        token: 'token123',
      );
      expect(state.isAdmin, isFalse);
    });

    test('SessionAuthenticated props are correct', () {
      const state = SessionAuthenticated(
        userId: 1,
        userName: 'test',
        email: 'test@test.com',
        nombreCompleto: 'Test User',
        nombreRol: 'Usuario',
        rolId: 2,
        sancionado: false,
        token: 'token123',
      );
      expect(state.props, [
        1,
        'test',
        'test@test.com',
        'Test User',
        'Usuario',
        2,
        false,
        'token123',
        null,
      ]);
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