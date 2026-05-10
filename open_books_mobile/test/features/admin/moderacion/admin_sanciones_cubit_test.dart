import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/admin/moderacion/data/models/admin_sancion.dart';
import 'package:open_books_mobile/features/admin/moderacion/data/repositories/admin_sanciones_repository.dart';
import 'package:open_books_mobile/features/admin/moderacion/logic/cubit/admin_sanciones_cubit.dart';

class MockAdminSancionesRepository extends Mock implements AdminSancionesRepository {}

void main() {
  late MockAdminSancionesRepository repository;

  setUpAll(() {
    registerFallbackValue(CreateSancionRequest(usuarioId: 0, tipoSancion: ''));
  });

  setUp(() {
    repository = MockAdminSancionesRepository();
  });

  final testSancion = AdminSancion(
    id: 1,
    usuarioId: 10,
    nombreUsuario: 'UserA',
    tipoSancion: 'Suspensión',
    descripcion: 'Desc',
    fechaInicio: DateTime(2024, 1, 1),
    fechaFin: DateTime(2024, 1, 15),
    activa: true,
  );

  final pagedSanciones = PagedSanciones(
    items: [testSancion],
    pageNumber: 1,
    pageSize: 10,
    totalCount: 1,
    totalPages: 1,
  );

  group('AdminSancionesCubit', () {
    blocTest<AdminSancionesCubit, AdminSancionesState>(
      'initial state is AdminSancionesInitial',
      build: () => AdminSancionesCubit(repository),
      verify: (cubit) => expect(cubit.state, isA<AdminSancionesInitial>()),
    );

    blocTest<AdminSancionesCubit, AdminSancionesState>(
      'loadSanciones success emits [AdminSancionesLoading, AdminSancionesLoaded]',
      setUp: () {
        when(
          () => repository.getSanciones(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => pagedSanciones);
      },
      build: () => AdminSancionesCubit(repository),
      act: (cubit) => cubit.loadSanciones(),
      expect: () => [
        isA<AdminSancionesLoading>(),
        isA<AdminSancionesLoaded>().having(
          (s) => s.sanciones.items.length,
          'items length',
          1,
        ),
      ],
    );

    blocTest<AdminSancionesCubit, AdminSancionesState>(
      'loadSanciones failure emits [AdminSancionesLoading, AdminSancionesError]',
      setUp: () {
        when(
          () => repository.getSanciones(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenThrow(Exception('Error'));
      },
      build: () => AdminSancionesCubit(repository),
      act: (cubit) => cubit.loadSanciones(),
      expect: () => [
        isA<AdminSancionesLoading>(),
        isA<AdminSancionesError>().having(
          (s) => s.message,
          'message',
          'Exception: Error',
        ),
      ],
    );

    blocTest<AdminSancionesCubit, AdminSancionesState>(
      'createSancion adds sancion and refreshes',
      setUp: () {
        when(() => repository.createSancion(any()))
            .thenAnswer((_) async => testSancion);
        when(
          () => repository.getSanciones(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => pagedSanciones);
      },
      build: () => AdminSancionesCubit(repository),
      act: (cubit) => cubit.createSancion(
        CreateSancionRequest(usuarioId: 10, tipoSancion: 'Suspensión'),
      ),
      expect: () => [
        isA<AdminSancionesCreating>(),
        isA<AdminSancionesCreated>(),
        isA<AdminSancionesLoading>(),
        isA<AdminSancionesLoaded>(),
      ],
    );

    blocTest<AdminSancionesCubit, AdminSancionesState>(
      'deleteSancion removes sancion and refreshes',
      setUp: () {
        when(() => repository.deleteSancion(any())).thenAnswer((_) async => true);
        when(
          () => repository.getSanciones(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => pagedSanciones);
      },
      build: () => AdminSancionesCubit(repository),
      act: (cubit) => cubit.deleteSancion(1),
      expect: () => [
        isA<AdminSancionesDeleting>(),
        isA<AdminSancionesDeleted>(),
        isA<AdminSancionesLoading>(),
        isA<AdminSancionesLoaded>(),
      ],
    );
  });
}
