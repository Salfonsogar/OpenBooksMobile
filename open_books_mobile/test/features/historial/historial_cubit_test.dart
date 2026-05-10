import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/historial/logic/cubit/historial_cubit.dart';
import 'package:open_books_mobile/features/historial/domain/usecases/get_historial_usecase.dart';
import 'package:open_books_mobile/features/historial/domain/usecases/add_to_historial_usecase.dart';
import 'package:open_books_mobile/features/historial/domain/entities/historial_entry_entity.dart';
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';
import 'package:open_books_mobile/shared/services/local_database.dart';
import 'package:open_books_mobile/shared/services/models/biblioteca_local_model.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/libros/data/models/libro.dart';
import 'package:open_books_mobile/shared/services/datasources/biblioteca_local_datasource.dart';

class MockGetHistorialUseCase extends Mock implements GetHistorialUseCase {}
class MockAddToHistorialUseCase extends Mock implements AddToHistorialUseCase {}
class MockSessionCubit extends Mock implements SessionCubit {}
class MockLocalDatabase extends Mock implements LocalDatabase {}
class MockBibliotecaLocalDataSource extends Mock implements BibliotecaLocalDataSource {}

Usuario createTestUsuario() => Usuario(
  id: 100,
  userName: 'testuser',
  nombreCompleto: 'Test User',
  email: 'test@test.com',
  estado: true,
  sancionado: false,
  fechaRegistro: DateTime(2026, 1, 1),
  nombreRol: 'user',
  rolId: 1,
);

void main() {
  setUpAll(() {
    registerFallbackValue(Libro(id: 1, titulo: '', autor: '', descripcion: '', categorias: []));
  });

  group('HistorialCubit', () {
    late GetHistorialUseCase getHistorialUseCase;
    late AddToHistorialUseCase addToHistorialUseCase;
    late SessionCubit sessionCubit;
    late LocalDatabase localDatabase;
    late BibliotecaLocalDataSource bibliotecaLocalDataSource;

    final now = DateTime(2026, 5, 10);
    final entities = [
      HistorialEntryEntity(
        id: 1, libroId: 42, usuarioId: 100, titulo: 'Libro A',
        ultimaLectura: now, createdAt: now,
      ),
      HistorialEntryEntity(
        id: 2, libroId: 43, usuarioId: 100, titulo: 'Libro B',
        ultimaLectura: now.subtract(const Duration(hours: 1)), createdAt: now,
      ),
    ];

    setUp(() {
      getHistorialUseCase = MockGetHistorialUseCase();
      addToHistorialUseCase = MockAddToHistorialUseCase();
      sessionCubit = MockSessionCubit();
      localDatabase = MockLocalDatabase();
      bibliotecaLocalDataSource = MockBibliotecaLocalDataSource();

      when(() => localDatabase.bibliotecaLocalDataSource)
          .thenReturn(bibliotecaLocalDataSource);
    });

    blocTest<HistorialCubit, HistorialState>(
      'initial state is HistorialInitial',
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      verify: (cubit) {
        expect(cubit.state, isA<HistorialInitial>());
      },
    );

    blocTest<HistorialCubit, HistorialState>(
      'cargarHistorial with unauthenticated session emits HistorialLoaded with empty list',
      setUp: () {
        when(() => sessionCubit.state).thenReturn(SessionUnauthenticated());
      },
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      act: (cubit) => cubit.cargarHistorial(),
      expect: () => [const HistorialLoaded(libros: [])],
    );

    blocTest<HistorialCubit, HistorialState>(
      'cargarHistorial success emits [HistorialLoading, HistorialLoaded]',
      setUp: () {
        when(() => sessionCubit.state).thenReturn(
          SessionAuthenticated(
            user: createTestUsuario(),
            token: 'token',
          ),
        );
        when(() => getHistorialUseCase(100)).thenAnswer((_) async => entities);
        when(() => bibliotecaLocalDataSource.getByLibroId(any(), any()))
            .thenAnswer((_) async => null);
      },
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      act: (cubit) => cubit.cargarHistorial(),
      expect: () => [
        isA<HistorialLoading>(),
        isA<HistorialLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HistorialLoaded;
        expect(state.libros.length, 2);
      },
    );

    blocTest<HistorialCubit, HistorialState>(
      'cargarHistorial sorts by ultimaLectura descending',
      setUp: () {
        when(() => sessionCubit.state).thenReturn(
          SessionAuthenticated(
            user: createTestUsuario(),
            token: 'token',
          ),
        );
        when(() => getHistorialUseCase(100)).thenAnswer((_) async => entities);
        when(() => bibliotecaLocalDataSource.getByLibroId(any(), any()))
            .thenAnswer((_) async => null);
      },
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      act: (cubit) => cubit.cargarHistorial(),
      expect: () => [
        isA<HistorialLoading>(),
        isA<HistorialLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HistorialLoaded;
        expect(state.libros[0].titulo, 'Libro A');
        expect(state.libros[1].titulo, 'Libro B');
      },
    );

    blocTest<HistorialCubit, HistorialState>(
      'cargarHistorial merges progreso from bibliotecaLocalDataSource',
      setUp: () {
        when(() => sessionCubit.state).thenReturn(
          SessionAuthenticated(
            user: createTestUsuario(),
            token: 'token',
          ),
        );
        when(() => getHistorialUseCase(100)).thenAnswer((_) async => entities);
        when(() => bibliotecaLocalDataSource.getByLibroId(42, 100)).thenAnswer(
          (_) async => BibliotecaLocalModel(
            libroId: 42, usuarioId: 100, titulo: 'Libro A',
            progreso: 0.85, page: 200, createdAt: now.millisecondsSinceEpoch,
          ),
        );
        when(() => bibliotecaLocalDataSource.getByLibroId(43, 100))
            .thenAnswer((_) async => null);
      },
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      act: (cubit) => cubit.cargarHistorial(),
      expect: () => [
        isA<HistorialLoading>(),
        isA<HistorialLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HistorialLoaded;
        expect(state.libros[0].progreso, 0.85);
        expect(state.libros[0].page, 200);
        expect(state.libros[1].progreso, 0.0);
      },
    );

    blocTest<HistorialCubit, HistorialState>(
      'cargarHistorial failure emits [HistorialLoading, HistorialError]',
      setUp: () {
        when(() => sessionCubit.state).thenReturn(
          SessionAuthenticated(
            user: createTestUsuario(),
            token: 'token',
          ),
        );
        when(() => getHistorialUseCase(100)).thenThrow(Exception('Error de red'));
      },
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      act: (cubit) => cubit.cargarHistorial(),
      expect: () => [
        isA<HistorialLoading>(),
        isA<HistorialError>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HistorialError;
        expect(state.message, 'Error de red');
      },
    );

    blocTest<HistorialCubit, HistorialState>(
      'addToHistorial calls useCase when authenticated',
      setUp: () {
        when(() => sessionCubit.state).thenReturn(
          SessionAuthenticated(
            user: createTestUsuario(),
            token: 'token',
          ),
        );
        when(() => addToHistorialUseCase(100, any())).thenAnswer((_) async {});
      },
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      act: (cubit) => cubit.addToHistorial(
        Libro(id: 1, titulo: 'T', autor: 'A', descripcion: 'D', categorias: []),
      ),
      verify: (cubit) {
        verify(() => addToHistorialUseCase(100, any())).called(1);
      },
    );

    blocTest<HistorialCubit, HistorialState>(
      'addToHistorial does nothing when unauthenticated',
      setUp: () {
        when(() => sessionCubit.state).thenReturn(SessionUnauthenticated());
      },
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      act: (cubit) => cubit.addToHistorial(
        Libro(id: 1, titulo: 'T', autor: 'A', descripcion: 'D', categorias: []),
      ),
      verify: (cubit) {
        verifyNever(() => addToHistorialUseCase(any(), any()));
      },
    );

    blocTest<HistorialCubit, HistorialState>(
      'refresh calls cargarHistorial',
      setUp: () {
        when(() => sessionCubit.state).thenReturn(
          SessionAuthenticated(
            user: createTestUsuario(),
            token: 'token',
          ),
        );
        when(() => getHistorialUseCase(100)).thenAnswer((_) async => entities);
        when(() => bibliotecaLocalDataSource.getByLibroId(any(), any()))
            .thenAnswer((_) async => null);
      },
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<HistorialLoading>(),
        isA<HistorialLoaded>(),
      ],
    );

    blocTest<HistorialCubit, HistorialState>(
      'addToHistorial silences errors',
      setUp: () {
        when(() => sessionCubit.state).thenReturn(
          SessionAuthenticated(
            user: createTestUsuario(),
            token: 'token',
          ),
        );
        when(() => addToHistorialUseCase(100, any())).thenThrow(Exception('fail'));
      },
      build: () => HistorialCubit(
        getHistorialUseCase: getHistorialUseCase,
        addToHistorialUseCase: addToHistorialUseCase,
        sessionCubit: sessionCubit,
        localDatabase: localDatabase,
      ),
      act: (cubit) => cubit.addToHistorial(
        Libro(id: 1, titulo: 'T', autor: 'A', descripcion: 'D', categorias: []),
      ),
      expect: () => [],
    );
  });
}


