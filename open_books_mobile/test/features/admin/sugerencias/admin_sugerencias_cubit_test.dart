import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/admin/sugerencias/data/models/admin_sugerencia.dart';
import 'package:open_books_mobile/features/admin/sugerencias/data/repositories/admin_sugerencias_repository.dart';
import 'package:open_books_mobile/features/admin/sugerencias/logic/cubit/admin_sugerencias_cubit.dart';

class MockAdminSugerenciasRepository extends Mock implements AdminSugerenciasRepository {}

void main() {
  late MockAdminSugerenciasRepository repository;

  setUp(() {
    repository = MockAdminSugerenciasRepository();
  });

  final testSugerencia = AdminSugerencia(
    id: 1,
    usuarioId: 10,
    nombreUsuario: 'UserA',
    titulo: 'Sugerencia 1',
    descripcion: 'Desc',
    fechaCreacion: DateTime(2024, 1, 1),
  );

  final pagedSugerencias = PagedSugerencias(
    items: [testSugerencia],
    pageNumber: 1,
    pageSize: 10,
    totalCount: 1,
    totalPages: 1,
  );

  group('AdminSugerenciasCubit', () {
    blocTest<AdminSugerenciasCubit, AdminSugerenciasState>(
      'initial state is AdminSugerenciasInitial',
      build: () => AdminSugerenciasCubit(repository),
      verify: (cubit) => expect(cubit.state, isA<AdminSugerenciasInitial>()),
    );

    blocTest<AdminSugerenciasCubit, AdminSugerenciasState>(
      'loadSugerencias success emits [AdminSugerenciasLoading, AdminSugerenciasLoaded]',
      setUp: () {
        when(
          () => repository.getSugerencias(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => pagedSugerencias);
      },
      build: () => AdminSugerenciasCubit(repository),
      act: (cubit) => cubit.loadSugerencias(),
      expect: () => [
        isA<AdminSugerenciasLoading>(),
        isA<AdminSugerenciasLoaded>().having(
          (s) => s.sugerencias.items.length,
          'items length',
          1,
        ),
      ],
    );

    blocTest<AdminSugerenciasCubit, AdminSugerenciasState>(
      'loadSugerencias failure emits [AdminSugerenciasLoading, AdminSugerenciasError]',
      setUp: () {
        when(
          () => repository.getSugerencias(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenThrow(Exception('Error'));
      },
      build: () => AdminSugerenciasCubit(repository),
      act: (cubit) => cubit.loadSugerencias(),
      expect: () => [
        isA<AdminSugerenciasLoading>(),
        isA<AdminSugerenciasError>().having(
          (s) => s.message,
          'message',
          'Exception: Error',
        ),
      ],
    );

    blocTest<AdminSugerenciasCubit, AdminSugerenciasState>(
      'deleteSugerencia removes sugerencia and refreshes',
      setUp: () {
        when(() => repository.deleteSugerencia(any())).thenAnswer((_) async => true);
        when(
          () => repository.getSugerencias(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => pagedSugerencias);
      },
      build: () => AdminSugerenciasCubit(repository),
      act: (cubit) => cubit.deleteSugerencia(1),
      expect: () => [
        isA<AdminSugerenciasDeleting>(),
        isA<AdminSugerenciasDeleted>(),
        isA<AdminSugerenciasLoading>(),
        isA<AdminSugerenciasLoaded>(),
      ],
    );
  });
}
