import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/libros/data/models/categoria.dart';
import 'package:open_books_mobile/features/libros/data/models/paged_result.dart';
import 'package:open_books_mobile/features/libros/data/repositories/libros_repository.dart';
import 'package:open_books_mobile/features/libros/logic/cubit/categorias_cubit.dart';

class MockLibrosRepository extends Mock implements LibrosRepository {}

void main() {
  group('CategoriasCubit', () {
    late MockLibrosRepository repository;

    setUp(() {
      repository = MockLibrosRepository();
    });

    blocTest<CategoriasCubit, CategoriasState>(
      'initial state is CategoriasInitial',
      build: () => CategoriasCubit(repository),
      verify: (cubit) => expect(cubit.state, isA<CategoriasInitial>()),
    );

    blocTest<CategoriasCubit, CategoriasState>(
      'cargarCategorias success emits [CategoriasLoading, CategoriasLoaded]',
      setUp: () {
        when(
          () => repository.getCategorias(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async => PagedResult(
            page: 1,
            pageSize: 50,
            total: 2,
            totalPages: 1,
            data: [
              Categoria(id: 1, nombre: 'Ficción'),
              Categoria(id: 2, nombre: 'No Ficción'),
            ],
          ),
        );
      },
      build: () => CategoriasCubit(repository),
      act: (cubit) => cubit.cargarCategorias(),
      expect: () => [
        isA<CategoriasLoading>(),
        isA<CategoriasLoaded>().having(
          (s) => s.categorias.length,
          'categorias length',
          2,
        ),
      ],
    );

    blocTest<CategoriasCubit, CategoriasState>(
      'cargarCategorias failure emits [CategoriasLoading, CategoriasError]',
      setUp: () {
        when(
          () => repository.getCategorias(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) => Future.error(Exception('Error de conexión')));
      },
      build: () => CategoriasCubit(repository),
      act: (cubit) => cubit.cargarCategorias(),
      expect: () => [
        isA<CategoriasLoading>(),
        isA<CategoriasError>(),
      ],
    );
  });
}
