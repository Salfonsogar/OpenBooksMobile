import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/auth/data/models/login_response.dart';
import 'package:open_books_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:open_books_mobile/features/auth/logic/cubit/auth_cubit.dart';
import 'package:open_books_mobile/features/auth/logic/cubit/auth_state.dart';
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  const testEmail = 'test@example.com';
  const testPassword = 'Password1!';
  const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwczovL3NjaGVtYXMud29yZHByb3RvLm9yZy9jbGFpbXMvbmFtZWlkZW50aWZpZXIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJodHRwczovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjpbIkFkbWluaXN0cmFkb3IiXSwiaWF0IjoxNzA0MDgwMDAwfQ.signature';
  const testUserId = '550e8400-e29b-41d4-a716-446655440000';

  late MockAuthRepository mockAuthRepository;
  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(Usuario(
      id: testUserId,
      userName: '',
      nombreCompleto: '',
      email: '',
      estado: true,
      fechaRegistro: DateTime.now(),
      nombreRol: 'Usuario',
    ));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSessionCubit = MockSessionCubit();
  });

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'initial state is AuthInitial',
      build: () => AuthCubit(
        authRepository: mockAuthRepository,
        sessionCubit: mockSessionCubit,
      ),
      verify: (cubit) {
        expect(cubit.state, isA<AuthInitial>());
      },
    );

    group('login', () {
      final usuario = Usuario(
        id: testUserId,
        userName: 'testuser',
        nombreCompleto: 'Test User',
        email: testEmail,
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
      );
      final loginResponse = LoginResponse(
        token: testToken,
        username: 'testuser',
        correo: testEmail,
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthLoginSuccess] when login succeeds',
        setUp: () {
          when(() => mockAuthRepository.login(any(), any()))
              .thenAnswer((_) async => loginResponse);
          when(
            () => mockSessionCubit.login(
              user: any(named: 'user'),
              token: any(named: 'token'),
            ),
          ).thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.login(testEmail, testPassword),
        expect: () => [
          AuthLoading(),
          isA<AuthLoginSuccess>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when login fails',
        setUp: () {
          when(() => mockAuthRepository.login(any(), any()))
              .thenThrow(Exception('Credenciales inválidas'));
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.login(testEmail, 'wrong'),
        expect: () => [
          AuthLoading(),
          const AuthError('Credenciales inválidas'),
        ],
      );
    });

    group('register', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthLoginSuccess] when register succeeds',
        setUp: () {
          when(
            () => mockAuthRepository.register(
              userName: any(named: 'userName'),
              correo: any(named: 'correo'),
              contrasena: any(named: 'contrasena'),
            ),
          ).thenAnswer((_) async {});
          final loginResponse = LoginResponse(
            token: testToken,
            username: 'newuser',
            correo: testEmail,
          );
          when(() => mockAuthRepository.login(any(), any()))
              .thenAnswer((_) async => loginResponse);
          when(
            () => mockSessionCubit.login(
              user: any(named: 'user'),
              token: any(named: 'token'),
            ),
          ).thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.register(
          userName: 'newuser',
          correo: testEmail,
          contrasena: testPassword,
        ),
        expect: () => [
          AuthLoading(),
          isA<AuthLoginSuccess>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when register fails',
        setUp: () {
          when(
            () => mockAuthRepository.register(
              userName: any(named: 'userName'),
              correo: any(named: 'correo'),
              contrasena: any(named: 'contrasena'),
            ),
          ).thenThrow(Exception('El usuario ya existe'));
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.register(
          userName: 'newuser',
          correo: testEmail,
          contrasena: testPassword,
        ),
        expect: () => [
          AuthLoading(),
          const AuthError('El usuario ya existe'),
        ],
      );
    });

    group('solicitarRecuperacion', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthRecoverySent] on success',
        setUp: () {
          when(() => mockAuthRepository.solicitarRecuperacion(any()))
              .thenAnswer((_) async => {'message': 'success'});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.solicitarRecuperacion(testEmail),
        expect: () => [
          AuthLoading(),
          const AuthRecoverySent(
            'Se ha enviado un correo de recuperación a tu email',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        setUp: () {
          when(() => mockAuthRepository.solicitarRecuperacion(any()))
              .thenThrow(Exception('Correo no encontrado'));
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.solicitarRecuperacion(testEmail),
        expect: () => [
          AuthLoading(),
          const AuthError('Correo no encontrado'),
        ],
      );
    });

    group('resetearContrasena', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthPasswordResetSuccess] on success',
        setUp: () {
          when(() => mockAuthRepository.resetearContrasena(any(), any(), any()))
              .thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.resetearContrasena(testEmail, 'token123', testPassword),
        expect: () => [
          AuthLoading(),
          AuthPasswordResetSuccess(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        setUp: () {
          when(() => mockAuthRepository.resetearContrasena(any(), any(), any()))
              .thenThrow(Exception('Token inválido'));
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.resetearContrasena(testEmail, 'token123', testPassword),
        expect: () => [
          AuthLoading(),
          const AuthError('Token inválido'),
        ],
      );
    });
  });
}