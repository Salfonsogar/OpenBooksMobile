import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/admin/categorias/data/models/admin_categoria.dart';
import 'package:open_books_mobile/features/admin/categorias/data/repositories/admin_categorias_repository.dart';
import 'package:open_books_mobile/features/admin/categorias/logic/cubit/admin_categorias_cubit.dart';

class MockAdminCategoriasRepository extends Mock implements AdminCategoriasRepository {}

void main() {
  late MockAdminCategoriasRepository repository;

  setUpAll(() {
    registerFallbackValue(CreateCategoriaRequest(nombre: ''));
  });

  setUp(() {
    repository = MockAdminCategoriasRepository();
  });

    const testCategoria = AdminCategoria(
    id: 1,
    nombre: 'Ficción',
    descripcion: 'Libros de ficción',
    cantidadLibros: 10,
  );

  final pagedCategorias = PagedCategorias(
    items: [testCategoria],
    pageNumber: 1,
    pageSize: 10,
    totalCount: 1,
    totalPages: 1,
  );

  group('AdminCategoriasCubit', () {
    blocTest<AdminCategoriasCubit, AdminCategoriasState>(
      'initial state is AdminCategoriasInitial',
      build: () => AdminCategoriasCubit(repository),
      verify: (cubit) => expect(cubit.state, isA<AdminCategoriasInitial>()),
    );

    blocTest<AdminCategoriasCubit, AdminCategoriasState>(
      'loadCategorias success emits [AdminCategoriasLoading, AdminCategoriasLoaded]',
      setUp: () {
        when(() => repository.getCategorias()).thenAnswer((_) async => pagedCategorias);
      },
      build: () => AdminCategoriasCubit(repository),
      act: (cubit) => cubit.loadCategorias(),
      expect: () => [
        isA<AdminCategoriasLoading>(),
        isA<AdminCategoriasLoaded>().having(
          (s) => s.categorias.items.length,
          'items length',
          1,
        ),
      ],
    );

    blocTest<AdminCategoriasCubit, AdminCategoriasState>(
      'loadCategorias failure emits [AdminCategoriasLoading, AdminCategoriasError]',
      setUp: () {
        when(() => repository.getCategorias()).thenThrow(Exception('Error'));
      },
      build: () => AdminCategoriasCubit(repository),
      act: (cubit) => cubit.loadCategorias(),
      expect: () => [
        isA<AdminCategoriasLoading>(),
        isA<AdminCategoriasError>().having(
          (s) => s.message,
          'message',
          'Exception: Error',
        ),
      ],
    );

    blocTest<AdminCategoriasCubit, AdminCategoriasState>(
      'createCategoria adds new category and refreshes',
      setUp: () {
        when(() => repository.createCategoria(any()))
            .thenAnswer((_) async => testCategoria);
        when(() => repository.getCategorias()).thenAnswer((_) async => pagedCategorias);
      },
      build: () => AdminCategoriasCubit(repository),
      act: (cubit) => cubit.createCategoria(CreateCategoriaRequest(nombre: 'Ficción')),
      expect: () => [
        isA<AdminCategoriasCreating>(),
        isA<AdminCategoriasCreated>(),
        isA<AdminCategoriasLoading>(),
        isA<AdminCategoriasLoaded>(),
      ],
    );

    blocTest<AdminCategoriasCubit, AdminCategoriasState>(
      'deleteCategoria removes category and refreshes',
      setUp: () {
        when(() => repository.deleteCategoria(1)).thenAnswer((_) async => true);
        when(() => repository.getCategorias()).thenAnswer((_) async => pagedCategorias);
      },
      build: () => AdminCategoriasCubit(repository),
      seed: () => AdminCategoriasLoaded(categorias: pagedCategorias),
      act: (cubit) => cubit.deleteCategoria(1),
      expect: () => [
        isA<AdminCategoriasDeleting>(),
        isA<AdminCategoriasDeleted>(),
        isA<AdminCategoriasLoading>(),
        isA<AdminCategoriasLoaded>(),
      ],
    );
  });
}
