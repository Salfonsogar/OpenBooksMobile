import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/admin/moderacion/data/models/admin_denuncia.dart';
import 'package:open_books_mobile/features/admin/moderacion/data/repositories/admin_denuncias_repository.dart';
import 'package:open_books_mobile/features/admin/moderacion/logic/cubit/admin_denuncias_cubit.dart';

class MockAdminDenunciasRepository extends Mock implements AdminDenunciasRepository {}

void main() {
  late MockAdminDenunciasRepository repository;

  setUp(() {
    repository = MockAdminDenunciasRepository();
  });

  final testDenuncia = AdminDenuncia(
    id: 1,
    usuarioDenuncianteId: 10,
    nombreUsuarioDenunciante: 'UserA',
    usuarioDenunciadoId: 20,
    nombreUsuarioDenunciado: 'UserB',
    motivo: 'Spam',
    descripcion: 'Desc',
    fechaCreacion: DateTime(2024, 1, 1),
    estado: 'Pendiente',
  );

  final pagedDenuncias = PagedDenuncias(
    items: [testDenuncia],
    pageNumber: 1,
    pageSize: 10,
    totalCount: 1,
    totalPages: 1,
  );

  group('AdminDenunciasCubit', () {
    blocTest<AdminDenunciasCubit, AdminDenunciasState>(
      'initial state is AdminDenunciasInitial',
      build: () => AdminDenunciasCubit(repository),
      verify: (cubit) => expect(cubit.state, isA<AdminDenunciasInitial>()),
    );

    blocTest<AdminDenunciasCubit, AdminDenunciasState>(
      'loadDenuncias success emits [AdminDenunciasLoading, AdminDenunciasLoaded]',
      setUp: () {
        when(
          () => repository.getDenuncias(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => pagedDenuncias);
      },
      build: () => AdminDenunciasCubit(repository),
      act: (cubit) => cubit.loadDenuncias(),
      expect: () => [
        isA<AdminDenunciasLoading>(),
        isA<AdminDenunciasLoaded>().having(
          (s) => s.denuncias.items.length,
          'items length',
          1,
        ),
      ],
    );

    blocTest<AdminDenunciasCubit, AdminDenunciasState>(
      'loadDenuncias failure emits [AdminDenunciasLoading, AdminDenunciasError]',
      setUp: () {
        when(
          () => repository.getDenuncias(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenThrow(Exception('Error'));
      },
      build: () => AdminDenunciasCubit(repository),
      act: (cubit) => cubit.loadDenuncias(),
      expect: () => [
        isA<AdminDenunciasLoading>(),
        isA<AdminDenunciasError>().having(
          (s) => s.message,
          'message',
          'Exception: Error',
        ),
      ],
    );

    blocTest<AdminDenunciasCubit, AdminDenunciasState>(
      'deleteDenuncia removes denuncia and refreshes',
      setUp: () {
        when(() => repository.deleteDenuncia(any())).thenAnswer((_) async => true);
        when(
          () => repository.getDenuncias(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => pagedDenuncias);
      },
      build: () => AdminDenunciasCubit(repository),
      act: (cubit) => cubit.deleteDenuncia(1),
      expect: () => [
        isA<AdminDenunciasDeleting>(),
        isA<AdminDenunciasDeleted>(),
        isA<AdminDenunciasLoading>(),
        isA<AdminDenunciasLoaded>(),
      ],
    );
  });
}
