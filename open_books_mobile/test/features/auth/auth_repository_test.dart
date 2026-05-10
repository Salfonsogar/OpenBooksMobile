import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/auth/data/datasources/auth_datasource.dart';
import 'package:open_books_mobile/features/auth/data/models/login_request.dart';
import 'package:open_books_mobile/features/auth/data/models/login_response.dart';
import 'package:open_books_mobile/features/auth/data/models/recovery_request.dart';
import 'package:open_books_mobile/features/auth/data/models/register_request.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/auth/data/repositories/auth_repository.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  late MockAuthDataSource mockDataSource;
  late AuthRepository repository;

  setUpAll(() {
    registerFallbackValue(LoginRequest(correo: '', contrasena: ''));
    registerFallbackValue(RegisterRequest(
      nombreUsuario: '',
      correo: '',
      contrasena: '',
      rolId: 0,
      nombreCompleto: '',
    ));
    registerFallbackValue(RecoveryRequest(correo: ''));
    registerFallbackValue(ResetPasswordRequest(token: '', nuevaContrasena: ''));
  });

  setUp(() {
    mockDataSource = MockAuthDataSource();
    repository = AuthRepository(mockDataSource);
  });

  group('AuthRepository.login', () {
    test('delegates to datasource with LoginRequest', () async {
      final usuario = Usuario(
        id: 1,
        userName: 'testuser',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      final response = LoginResponse(usuario: usuario, token: 'token123');

      when(() => mockDataSource.login(any()))
          .thenAnswer((_) async => response);

      final result = await repository.login('test@test.com', 'Password1!');

      expect(result.usuario.id, 1);
      expect(result.token, 'token123');
      verify(() => mockDataSource.login(any<LoginRequest>())).called(1);
    });
  });

  group('AuthRepository.register', () {
    test('delegates to datasource with RegisterRequest', () async {
      final usuario = Usuario(
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
      final response = LoginResponse(usuario: usuario, token: 'token456');

      when(() => mockDataSource.register(any()))
          .thenAnswer((_) async => response);

      final result = await repository.register(
        nombreUsuario: 'newuser',
        correo: 'new@test.com',
        contrasena: 'Password1!',
        rolId: 2,
        nombreCompleto: 'New User',
      );

      expect(result.usuario.id, 2);
      expect(result.token, 'token456');
      verify(() => mockDataSource.register(any<RegisterRequest>())).called(1);
    });
  });

  group('AuthRepository.solicitarRecuperacion', () {
    test('delegates to datasource with RecoveryRequest', () async {
      when(() => mockDataSource.solicitarRecuperacion(any()))
          .thenAnswer((_) async {});

      await repository.solicitarRecuperacion('user@test.com');

      verify(
        () => mockDataSource.solicitarRecuperacion(any<RecoveryRequest>()),
      ).called(1);
    });
  });

  group('AuthRepository.resetearContrasena', () {
    test('delegates to datasource with ResetPasswordRequest', () async {
      when(() => mockDataSource.resetearContrasena(any()))
          .thenAnswer((_) async {});

      await repository.resetearContrasena('token123', 'NewPass1!');

      verify(
        () => mockDataSource.resetearContrasena(any<ResetPasswordRequest>()),
      ).called(1);
    });
  });

  group('AuthRepository.getUsuario', () {
    test('delegates to datasource', () async {
      final usuario = Usuario(
        id: 1,
        userName: 'testuser',
        nombreCompleto: 'Test User',
        email: 'test@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );

      when(() => mockDataSource.getUsuario(any()))
          .thenAnswer((_) async => usuario);

      final result = await repository.getUsuario(1);

      expect(result.id, 1);
      verify(() => mockDataSource.getUsuario(1)).called(1);
    });
  });

  group('AuthRepository.updateUsuario', () {
    test('delegates to datasource with update data', () async {
      final updated = Usuario(
        id: 1,
        userName: 'newname',
        nombreCompleto: 'Updated Name',
        email: 'test@test.com',
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );

      when(() => mockDataSource.updateUsuario(any(), any()))
          .thenAnswer((_) async => updated);

      final result = await repository.updateUsuario(
        1,
        userName: 'newname',
        nombreCompleto: 'Updated Name',
      );

      expect(result.userName, 'newname');
      verify(
        () => mockDataSource.updateUsuario(1, {
          'userName': 'newname',
          'nombreCompleto': 'Updated Name',
        }),
      ).called(1);
    });
  });
}
