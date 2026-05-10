import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/perfil/data/models/sugerencia.dart';
import 'package:open_books_mobile/features/perfil/data/models/update_perfil_request.dart';
import 'package:open_books_mobile/features/perfil/data/repositories/perfil_repository.dart';
import 'package:open_books_mobile/features/perfil/logic/cubit/perfil_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';

class MockPerfilRepository extends Mock implements PerfilRepository {}

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  final testUser = Usuario(
    id: 1,
    userName: 'testuser',
    nombreCompleto: 'Test User',
    email: 'test@example.com',
    estado: true,
    sancionado: false,
    fechaRegistro: DateTime(2026, 1, 1),
    nombreRol: 'Usuario',
    rolId: 2,
  );

  late MockPerfilRepository mockRepository;
  late MockSessionCubit mockSessionCubit;
  late StreamController<SessionState> sessionController;

  setUpAll(() {
    registerFallbackValue(0);
    registerFallbackValue(UpdatePerfilRequest());
    registerFallbackValue(Sugerencia(id: 0, idUsuario: 0, nombreUsuario: '', comentario: ''));
  });

  setUp(() {
    mockRepository = MockPerfilRepository();
    mockSessionCubit = MockSessionCubit();
    sessionController = StreamController<SessionState>.broadcast();

    when(() => mockSessionCubit.stream).thenAnswer((_) => sessionController.stream);
    when(() => mockSessionCubit.state).thenReturn(SessionUnauthenticated());
  });

  tearDown(() {
    sessionController.close();
  });

  group('PerfilCubit', () {
    blocTest<PerfilCubit, PerfilState>(
      'initial state is PerfilInitial',
      build: () => PerfilCubit(
        repository: mockRepository,
        sessionCubit: mockSessionCubit,
      ),
      verify: (cubit) {
        expect(cubit.state, isA<PerfilInitial>());
      },
    );

    group('cargarPerfil', () {
      blocTest<PerfilCubit, PerfilState>(
        'emits [PerfilLoading, PerfilLoaded] on success',
        setUp: () {
          when(() => mockRepository.getPerfil(any())).thenAnswer((_) async => testUser);
        },
        build: () => PerfilCubit(
          repository: mockRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) async {
          when(() => mockSessionCubit.state).thenReturn(
            SessionAuthenticated(user: testUser, token: 'token'),
          );
          await cubit.cargarPerfil();
        },
        expect: () => [
          isA<PerfilLoading>(),
          isA<PerfilLoaded>(),
        ],
      );

      blocTest<PerfilCubit, PerfilState>(
        'emits [PerfilLoading, PerfilError] on failure',
        setUp: () {
          when(() => mockRepository.getPerfil(any())).thenThrow(Exception('Error de red'));
        },
        build: () => PerfilCubit(
          repository: mockRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) async {
          when(() => mockSessionCubit.state).thenReturn(
            SessionAuthenticated(user: testUser, token: 'token'),
          );
          await cubit.cargarPerfil();
        },
        expect: () => [
          isA<PerfilLoading>(),
          isA<PerfilError>(),
        ],
      );
    });

    group('actualizarPerfil', () {
      blocTest<PerfilCubit, PerfilState>(
        'updates profile and emits PerfilLoaded',
        setUp: () {
          when(() => mockRepository.updatePerfil(any(), any()))
              .thenAnswer((_) async => testUser);
          when(() => mockRepository.getPerfil(any()))
              .thenAnswer((_) async => testUser);
        },
        build: () => PerfilCubit(
          repository: mockRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) async {
          when(() => mockSessionCubit.state).thenReturn(
            SessionAuthenticated(user: testUser, token: 'token'),
          );
          await cubit.actualizarPerfil(userName: 'newuser');
        },
        expect: () => [
          isA<PerfilLoaded>(),
        ],
      );

      blocTest<PerfilCubit, PerfilState>(
        'emits PerfilError on failure',
        setUp: () {
          when(() => mockRepository.updatePerfil(any(), any()))
              .thenThrow(Exception('Error'));
          when(() => mockRepository.getPerfil(any()))
              .thenAnswer((_) async => testUser);
        },
        build: () => PerfilCubit(
          repository: mockRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) async {
          when(() => mockSessionCubit.state).thenReturn(
            SessionAuthenticated(user: testUser, token: 'token'),
          );
          await cubit.actualizarPerfil(userName: 'newuser');
        },
        expect: () => [
          isA<PerfilError>(),
          isA<PerfilLoading>(),
          isA<PerfilLoaded>(),
        ],
      );
    });

    group('enviarSugerencia', () {
      blocTest<PerfilCubit, PerfilState>(
        'emits [SugerenciaSending, SugerenciaSuccess] on success',
        setUp: () {
          when(() => mockRepository.crearSugerencia(any())).thenAnswer(
            (_) async => Sugerencia(
              id: 1,
              idUsuario: 1,
              nombreUsuario: 'testuser',
              comentario: 'Great app!',
            ),
          );
          when(() => mockRepository.getPerfil(any()))
              .thenAnswer((_) async => testUser);
        },
        build: () => PerfilCubit(
          repository: mockRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) async {
          when(() => mockSessionCubit.state).thenReturn(
            SessionAuthenticated(user: testUser, token: 'token'),
          );
          await cubit.enviarSugerencia('Great app!');
        },
        expect: () => [
          isA<SugerenciaSending>(),
          isA<SugerenciaSuccess>(),
          isA<PerfilLoading>(),
          isA<PerfilLoaded>(),
        ],
      );

      blocTest<PerfilCubit, PerfilState>(
        'emits PerfilError on failure',
        setUp: () {
          when(() => mockRepository.crearSugerencia(any()))
              .thenThrow(Exception('Error'));
          when(() => mockRepository.getPerfil(any()))
              .thenAnswer((_) async => testUser);
        },
        build: () => PerfilCubit(
          repository: mockRepository,
          sessionCubit: mockSessionCubit,
        ),
        act: (cubit) async {
          when(() => mockSessionCubit.state).thenReturn(
            SessionAuthenticated(user: testUser, token: 'token'),
          );
          await cubit.enviarSugerencia('Great app!');
        },
        expect: () => [
          isA<SugerenciaSending>(),
          isA<PerfilError>(),
          isA<PerfilLoading>(),
          isA<PerfilLoaded>(),
        ],
      );
    });
  });
}
