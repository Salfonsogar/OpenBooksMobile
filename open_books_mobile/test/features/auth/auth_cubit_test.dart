import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/auth/data/models/rol.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/auth/data/models/login_response.dart';
import 'package:open_books_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:open_books_mobile/features/auth/data/repositories/roles_repository.dart';
import 'package:open_books_mobile/features/auth/logic/cubit/auth_cubit.dart';
import 'package:open_books_mobile/features/auth/logic/cubit/auth_state.dart';
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockRolesRepository extends Mock implements RolesRepository {}

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  const testEmail = 'test@example.com';
  const testPassword = 'Password1!';
  const testToken = 'jwt_token_123';

  late MockAuthRepository mockAuthRepository;
  late MockRolesRepository mockRolesRepository;
  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(Usuario(
      id: 0,
      userName: '',
      nombreCompleto: '',
      email: '',
      estado: true,
      sancionado: false,
      fechaRegistro: DateTime.now(),
      nombreRol: '',
      rolId: 0,
    ));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockRolesRepository = MockRolesRepository();
    mockSessionCubit = MockSessionCubit();
  });

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'initial state is AuthInitial',
      build: () => AuthCubit(
        authRepository: mockAuthRepository,
        rolesRepository: mockRolesRepository,
        sessionCubit: mockSessionCubit,
      ),
      verify: (cubit) {
        expect(cubit.state, isA<AuthInitial>());
      },
    );

    group('login', () {
      final usuario = Usuario(
        id: 1,
        userName: 'testuser',
        nombreCompleto: 'Test User',
        email: testEmail,
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      final loginResponse = LoginResponse(usuario: usuario, token: testToken);

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthLoginSuccess] when login succeeds',
        setUp: () {
          when(() => mockAuthRepository.login(any(), any()))
              .thenAnswer((_) async => loginResponse);
          when(() => mockRolesRepository.getRol(any()))
              .thenAnswer((_) async => const Rol(id: 2, nombre: 'Usuario'));
          when(
            () => mockSessionCubit.login(
              user: any(named: 'user'),
              token: any(named: 'token'),
            ),
          ).thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          rolesRepository: mockRolesRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.login(testEmail, testPassword),
        expect: () => [
          AuthLoading(),
          AuthLoginSuccess(usuario: usuario, token: testToken),
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
          rolesRepository: mockRolesRepository,
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
      final usuario = Usuario(
        id: 1,
        userName: 'newuser',
        nombreCompleto: 'New User',
        email: testEmail,
        estado: true,
        sancionado: false,
        fechaRegistro: DateTime.now(),
        nombreRol: 'Usuario',
        rolId: 2,
      );
      final registerResponse = LoginResponse(usuario: usuario, token: testToken);

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthRegisterSuccess] when register succeeds',
        setUp: () {
          when(
            () => mockAuthRepository.register(
              nombreUsuario: any(named: 'nombreUsuario'),
              correo: any(named: 'correo'),
              contrasena: any(named: 'contrasena'),
              rolId: any(named: 'rolId'),
              nombreCompleto: any(named: 'nombreCompleto'),
            ),
          ).thenAnswer((_) async => registerResponse);
          when(() => mockRolesRepository.getRol(any()))
              .thenAnswer((_) async => const Rol(id: 2, nombre: 'Usuario'));
          when(
            () => mockSessionCubit.login(
              user: any(named: 'user'),
              token: any(named: 'token'),
            ),
          ).thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          rolesRepository: mockRolesRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.register(
          nombreUsuario: 'newuser',
          correo: testEmail,
          contrasena: testPassword,
          rolId: 2,
          nombreCompleto: 'New User',
        ),
        expect: () => [
          AuthLoading(),
          AuthRegisterSuccess(usuario: usuario, token: testToken),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when register fails',
        setUp: () {
          when(
            () => mockAuthRepository.register(
              nombreUsuario: any(named: 'nombreUsuario'),
              correo: any(named: 'correo'),
              contrasena: any(named: 'contrasena'),
              rolId: any(named: 'rolId'),
              nombreCompleto: any(named: 'nombreCompleto'),
            ),
          ).thenThrow(Exception('El usuario ya existe'));
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          rolesRepository: mockRolesRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.register(
          nombreUsuario: 'newuser',
          correo: testEmail,
          contrasena: testPassword,
          rolId: 2,
          nombreCompleto: 'New User',
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
              .thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          rolesRepository: mockRolesRepository,
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
          rolesRepository: mockRolesRepository,
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
          when(() => mockAuthRepository.resetearContrasena(any(), any()))
              .thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          rolesRepository: mockRolesRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.resetearContrasena('token123', testPassword),
        expect: () => [
          AuthLoading(),
          AuthPasswordResetSuccess(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        setUp: () {
          when(() => mockAuthRepository.resetearContrasena(any(), any()))
              .thenThrow(Exception('Token inválido'));
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          rolesRepository: mockRolesRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) => cubit.resetearContrasena('token123', testPassword),
        expect: () => [
          AuthLoading(),
          const AuthError('Token inválido'),
        ],
      );
    });
  });
}
