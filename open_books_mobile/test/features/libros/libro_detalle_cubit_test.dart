import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/biblioteca/data/datasources/biblioteca_datasource.dart';
import 'package:open_books_mobile/features/biblioteca/data/models/libro_biblioteca.dart';
import 'package:open_books_mobile/features/libros/data/models/index.dart';
import 'package:open_books_mobile/features/libros/data/repositories/libros_repository.dart';
import 'package:open_books_mobile/features/libros/logic/cubit/libro_detalle_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';

class MockLibrosRepository extends Mock implements LibrosRepository {}
class MockBibliotecaDataSource extends Mock implements BibliotecaDataSource {}
class MockSessionCubit extends Mock implements SessionCubit {}

Usuario createTestUser() => Usuario(
      id: 1,
      userName: 'testuser',
      nombreCompleto: 'Test User',
      email: 'test@test.com',
      estado: true,
      sancionado: false,
      fechaRegistro: DateTime(2024, 1, 1),
      nombreRol: 'Usuario',
      rolId: 2,
    );

LibroDetalle createTestDetalle({int id = 1}) => LibroDetalle(
      id: id,
      titulo: 'Test Book',
      autor: 'Test Author',
      descripcion: 'Test Description',
      promedioValoraciones: 4.0,
      cantidadValoraciones: 10,
      resenas: [],
      totalResenas: 0,
      categorias: ['Ficción'],
    );

void main() {
  group('LibroDetalleCubit', () {
    late MockLibrosRepository repository;
    late MockBibliotecaDataSource bibliotecaDataSource;
    late MockSessionCubit sessionCubit;

    setUp(() {
      repository = MockLibrosRepository();
      bibliotecaDataSource = MockBibliotecaDataSource();
      sessionCubit = MockSessionCubit();
    });

    blocTest<LibroDetalleCubit, LibroDetalleState>(
      'initial state is LibroDetalleInitial',
      build: () =>
          LibroDetalleCubit(repository, bibliotecaDataSource, sessionCubit),
      verify: (cubit) => expect(cubit.state, isA<LibroDetalleInitial>()),
    );

    blocTest<LibroDetalleCubit, LibroDetalleState>(
      'cargarDetalle success emits [LibroDetalleLoading, LibroDetalleLoaded]',
      setUp: () {
        when(
          () => repository.getLibroDetalle(
            any(),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => createTestDetalle());
        when(() => sessionCubit.state).thenReturn(SessionInitial());
      },
      build: () =>
          LibroDetalleCubit(repository, bibliotecaDataSource, sessionCubit),
      act: (cubit) => cubit.cargarDetalle(1),
      expect: () => [
        isA<LibroDetalleLoading>(),
        isA<LibroDetalleLoaded>().having(
          (s) => s.libro.id,
          'libro id',
          1,
        ),
      ],
    );

    blocTest<LibroDetalleCubit, LibroDetalleState>(
      'cargarDetalle failure emits [LibroDetalleLoading, LibroDetalleError]',
      setUp: () {
        when(
          () => repository.getLibroDetalle(
            any(),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) => Future.error(Exception('Error de conexión')));
      },
      build: () =>
          LibroDetalleCubit(repository, bibliotecaDataSource, sessionCubit),
      act: (cubit) => cubit.cargarDetalle(1),
      expect: () => [
        isA<LibroDetalleLoading>(),
        isA<LibroDetalleError>(),
      ],
    );

    blocTest<LibroDetalleCubit, LibroDetalleState>(
      'cargarDetalle checks biblioteca when authenticated',
      setUp: () {
        final user = createTestUser();
        when(
          () => repository.getLibroDetalle(
            any(),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => createTestDetalle());
        when(() => sessionCubit.state)
            .thenReturn(SessionAuthenticated(user: user, token: 'token'));
        when(() => bibliotecaDataSource.getLibrosBiblioteca(user.id))
            .thenAnswer((_) async => [
                  LibroBiblioteca(
                    id: 1,
                    titulo: 'Test Book',
                    autor: 'Author',
                    descripcion: 'Desc',
                    categorias: [],
                  ),
                ]);
      },
      build: () =>
          LibroDetalleCubit(repository, bibliotecaDataSource, sessionCubit),
      act: (cubit) => cubit.cargarDetalle(1),
      expect: () => [
        isA<LibroDetalleLoading>(),
        isA<LibroDetalleLoaded>().having(
          (s) => s.estaEnBiblioteca,
          'esta en biblioteca',
          isTrue,
        ),
      ],
    );

    blocTest<LibroDetalleCubit, LibroDetalleState>(
      'valorar calls repository and updates state',
      setUp: () {
        final user = createTestUser();
        when(() => sessionCubit.state)
            .thenReturn(SessionAuthenticated(user: user, token: 'token'));
        when(
          () => repository.getLibroDetalle(
            any(),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => createTestDetalle());
        when(() => repository.crearValoracion(1, 4)).thenAnswer((_) async {});
      },
      build: () =>
          LibroDetalleCubit(repository, bibliotecaDataSource, sessionCubit),
      act: (cubit) async {
        await cubit.cargarDetalle(1);
        await cubit.valorar(4);
      },
      expect: () => [
        isA<LibroDetalleLoading>(),
        isA<LibroDetalleLoaded>(),
        isA<LibroDetalleLoaded>().having(
          (s) => s.isValoracionSuccess,
          'valoracion success',
          isTrue,
        ),
      ],
    );

    blocTest<LibroDetalleCubit, LibroDetalleState>(
      'escribirResena calls repository and updates state',
      setUp: () {
        final user = createTestUser();
        when(() => sessionCubit.state)
            .thenReturn(SessionAuthenticated(user: user, token: 'token'));
        when(
          () => repository.getLibroDetalle(
            any(),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => createTestDetalle());
        when(() => repository.crearResena(1, 'Buen libro')).thenAnswer(
          (_) async => Resena(
            id: 1,
            usuarioId: user.id,
            nombreUsuario: user.nombreCompleto,
            texto: 'Buen libro',
            fecha: DateTime.now(),
          ),
        );
      },
      build: () =>
          LibroDetalleCubit(repository, bibliotecaDataSource, sessionCubit),
      act: (cubit) async {
        await cubit.cargarDetalle(1);
        await cubit.escribirResena('Buen libro');
      },
      expect: () => [
        isA<LibroDetalleLoading>(),
        isA<LibroDetalleLoaded>(),
        isA<LibroDetalleLoaded>().having(
          (s) => s.isResenaSuccess,
          'resena success',
          isTrue,
        ),
      ],
    );

    blocTest<LibroDetalleCubit, LibroDetalleState>(
      'agregarABiblioteca calls biblioteca datasource and updates state',
      setUp: () {
        final user = createTestUser();
        when(() => sessionCubit.state)
            .thenReturn(SessionAuthenticated(user: user, token: 'token'));
        when(
          () => repository.getLibroDetalle(
            any(),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => createTestDetalle());
        when(() => bibliotecaDataSource.agregarLibro(user.id, 1))
            .thenAnswer((_) async {});
      },
      build: () =>
          LibroDetalleCubit(repository, bibliotecaDataSource, sessionCubit),
      act: (cubit) async {
        await cubit.cargarDetalle(1);
        await cubit.agregarABiblioteca();
      },
      expect: () => [
        isA<LibroDetalleLoading>(),
        isA<LibroDetalleLoaded>().having(
          (s) => s.estaEnBiblioteca,
          'initial not in library',
          isFalse,
        ),
        isA<LibroDetalleLoaded>().having(
          (s) => s.estaEnBiblioteca,
          'after add in library',
          isTrue,
        ),
      ],
    );

    blocTest<LibroDetalleCubit, LibroDetalleState>(
      'cargarDetalle handles 401 error by logging out',
      setUp: () {
        when(
          () => repository.getLibroDetalle(
            any(),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) => Future.error(Exception('401')));
        when(() => sessionCubit.logout()).thenAnswer((_) async {});
      },
      build: () =>
          LibroDetalleCubit(repository, bibliotecaDataSource, sessionCubit),
      act: (cubit) => cubit.cargarDetalle(1),
      expect: () => [
        isA<LibroDetalleLoading>(),
        isA<LibroDetalleError>(),
      ],
    );
  });
}
