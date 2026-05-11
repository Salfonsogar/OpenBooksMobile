import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/auth/data/datasources/auth_datasource.dart';
import 'package:open_books_mobile/features/auth/data/models/login_request.dart';
import 'package:open_books_mobile/features/auth/data/models/login_response.dart';
import 'package:open_books_mobile/features/auth/data/models/recovery_request.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/auth/data/repositories/auth_repository.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  const testUserId = '550e8400-e29b-41d4-a716-446655440000';

  late MockAuthDataSource mockDataSource;
  late AuthRepository repository;

  setUpAll(() {
    registerFallbackValue(LoginRequest(correo: '', contrasena: ''));
    registerFallbackValue(RecoveryRequest(correo: ''));
  });

  setUp(() {
    mockDataSource = MockAuthDataSource();
    repository = AuthRepository(mockDataSource);
  });

  group('AuthRepository.login', () {
    test('delegates to datasource with LoginRequest', () async {
      final response = LoginResponse(
        token: 'token123',
        username: 'testuser',
        correo: 'test@test.com',
      );

      when(() => mockDataSource.login(any()))
          .thenAnswer((_) async => response);

      final result = await repository.login('test@test.com', 'Password1!');

      expect(result.token, 'token123');
      expect(result.username, 'testuser');
      verify(() => mockDataSource.login(any<LoginRequest>())).called(1);
    });
  });

  group('AuthRepository.register', () {
    test('delegates to datasource with RegisterRequest', () async {
      when(() => mockDataSource.register(any()))
          .thenAnswer((_) async {});

      await repository.register(
        userName: 'newuser',
        correo: 'new@test.com',
        contrasena: 'Password1!',
      );

      verify(() => mockDataSource.register(any())).called(1);
    });
  });

  group('AuthRepository.solicitarRecuperacion', () {
    test('delegates to datasource with RecoveryRequest', () async {
      when(() => mockDataSource.solicitarRecuperacion(any()))
          .thenAnswer((_) async => {'message': 'success'});

      final result = await repository.solicitarRecuperacion('user@test.com');

      expect(result['message'], 'success');
      verify(
        () => mockDataSource.solicitarRecuperacion(any<RecoveryRequest>()),
      ).called(1);
    });
  });

  group('AuthRepository.resetearContrasena', () {
    test('delegates to datasource with ResetPasswordRequest', () async {
      when(() => mockDataSource.resetearContrasena(any()))
          .thenAnswer((_) async {});

      await repository.resetearContrasena('user@test.com', 'token123', 'NewPass1!');

      verify(
        () => mockDataSource.resetearContrasena(any()),
      ).called(1);
    });
  });

  group('AuthRepository.getUsuario', () {
    test('delegates to datasource', () async {
      final usuario = Usuario(
        id: testUserId,
        userName: 'testuser',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
      );

      when(() => mockDataSource.getUsuario(any()))
          .thenAnswer((_) async => usuario);

      final result = await repository.getUsuario(testUserId);

      expect(result.id, testUserId);
      verify(() => mockDataSource.getUsuario(testUserId)).called(1);
    });
  });

  group('AuthRepository.updateUsuario', () {
    test('delegates to datasource with update data', () async {
      final updated = Usuario(
        id: testUserId,
        userName: 'newname',
        nombreCompleto: 'Updated Name',
        email: 'test@test.com',
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
      );

      when(() => mockDataSource.updateUsuario(any(), any()))
          .thenAnswer((_) async => updated);

      final result = await repository.updateUsuario(
        testUserId,
        userName: 'newname',
        nombreCompleto: 'Updated Name',
      );

      expect(result.userName, 'newname');
      verify(
        () => mockDataSource.updateUsuario(testUserId, {
          'userName': 'newname',
          'nombreCompleto': 'Updated Name',
        }),
      ).called(1);
    });
  });
}