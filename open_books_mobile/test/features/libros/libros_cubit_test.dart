import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/libros/data/models/libro.dart';
import 'package:open_books_mobile/features/libros/data/models/paged_result.dart';
import 'package:open_books_mobile/features/libros/data/repositories/libros_repository.dart';
import 'package:open_books_mobile/features/libros/logic/cubit/libros_cubit.dart';

class MockLibrosRepository extends Mock implements LibrosRepository {}

void main() {
  group('LibrosCubit', () {
    late MockLibrosRepository repository;

    setUp(() {
      repository = MockLibrosRepository();
    });

    blocTest<LibrosCubit, LibrosState>(
      'initial state is LibrosInitial',
      build: () => LibrosCubit(repository),
      verify: (cubit) => expect(cubit.state, isA<LibrosInitial>()),
    );

    blocTest<LibrosCubit, LibrosState>(
      'cargarLibros success emits [LibrosLoading, LibrosLoaded]',
      setUp: () {
        when(
          () => repository.getLibros(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            categorias: any(named: 'categorias'),
            autor: any(named: 'autor'),
          ),
        ).thenAnswer(
          (_) async => PagedResult(
            page: 1,
            pageSize: 10,
            total: 1,
            totalPages: 1,
            data: [
              Libro(
                id: 1,
                titulo: 'Test',
                autor: 'Author',
                descripcion: 'Desc',
                categorias: [],
              ),
            ],
          ),
        );
      },
      build: () => LibrosCubit(repository),
      act: (cubit) => cubit.cargarLibros(),
      expect: () => [
        isA<LibrosLoading>(),
        isA<LibrosLoaded>().having(
          (s) => s.libros.length,
          'libros length',
          1,
        ),
      ],
    );

    blocTest<LibrosCubit, LibrosState>(
      'cargarLibros failure emits [LibrosLoading, LibrosError]',
      setUp: () {
        when(
          () => repository.getLibros(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            categorias: any(named: 'categorias'),
            autor: any(named: 'autor'),
          ),
        ).thenAnswer((_) => Future.error(Exception('Error de conexión')));
      },
      build: () => LibrosCubit(repository),
      act: (cubit) => cubit.cargarLibros(),
      expect: () => [
        isA<LibrosLoading>(),
        isA<LibrosError>(),
      ],
    );

    group('cargarMasLibros', () {
      blocTest<LibrosCubit, LibrosState>(
        'when hasMore loads next page and accumulates libros',
        setUp: () {
          when(
            () => repository.getLibros(
              query: any(named: 'query'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              categorias: any(named: 'categorias'),
              autor: any(named: 'autor'),
            ),
          ).thenAnswer(
            (invocation) async {
              final page = invocation.namedArguments[#page] as int? ?? 1;
              return PagedResult(
                page: page,
                pageSize: 10,
                total: 25,
                totalPages: 3,
                data: [
                  Libro(
                    id: page,
                    titulo: 'Test $page',
                    autor: 'Author',
                    descripcion: 'Desc',
                    categorias: [],
                  ),
                ],
              );
            },
          );
        },
        build: () => LibrosCubit(repository),
        act: (cubit) async {
          await cubit.cargarLibros();
          await cubit.cargarMasLibros();
        },
        expect: () => [
          isA<LibrosLoading>(),
          isA<LibrosLoaded>().having(
            (s) => s.libros.length,
            'page 1 has 1 libro',
            1,
          ),
          isA<LibrosLoading>(),
          isA<LibrosLoaded>().having(
            (s) => s.libros.length,
            'after cargarMasLibros has 2 libros',
            2,
          ),
        ],
      );

      blocTest<LibrosCubit, LibrosState>(
        'when !hasMore does nothing',
        setUp: () {
          when(
            () => repository.getLibros(
              query: any(named: 'query'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              categorias: any(named: 'categorias'),
              autor: any(named: 'autor'),
            ),
          ).thenAnswer(
            (_) async => PagedResult(
              page: 1,
              pageSize: 10,
              total: 1,
              totalPages: 1,
              data: [
                Libro(
                  id: 1,
                  titulo: 'Test',
                  autor: 'Author',
                  descripcion: 'Desc',
                  categorias: [],
                ),
              ],
            ),
          );
        },
        build: () => LibrosCubit(repository),
        act: (cubit) async {
          await cubit.cargarLibros();
          await cubit.cargarMasLibros();
        },
        expect: () => [
          isA<LibrosLoading>(),
          isA<LibrosLoaded>(),
        ],
      );
    });

    blocTest<LibrosCubit, LibrosState>(
      'buscarLibros refreshes with query',
      setUp: () {
        when(
          () => repository.getLibros(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            categorias: any(named: 'categorias'),
            autor: any(named: 'autor'),
          ),
        ).thenAnswer(
          (_) async => PagedResult(
            page: 1,
            pageSize: 10,
            total: 0,
            totalPages: 0,
            data: [],
          ),
        );
      },
      build: () => LibrosCubit(repository),
      act: (cubit) => cubit.buscarLibros('quijote'),
      expect: () => [
        isA<LibrosLoading>(),
        isA<LibrosLoaded>().having(
          (s) => s.query,
          'query is quijote',
          'quijote',
        ),
      ],
    );

    blocTest<LibrosCubit, LibrosState>(
      'filtrarPorCategoria refreshes with categories',
      setUp: () {
        when(
          () => repository.getLibros(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            categorias: any(named: 'categorias'),
            autor: any(named: 'autor'),
          ),
        ).thenAnswer(
          (_) async => PagedResult(
            page: 1,
            pageSize: 10,
            total: 0,
            totalPages: 0,
            data: [],
          ),
        );
      },
      build: () => LibrosCubit(repository),
      act: (cubit) => cubit.filtrarPorCategoria([1, 2]),
      expect: () => [
        isA<LibrosLoading>(),
        isA<LibrosLoaded>().having(
          (s) => s.categoriasSeleccionadas,
          'categories selected',
          [1, 2],
        ),
      ],
    );

    blocTest<LibrosCubit, LibrosState>(
      'refresh reloads current query from LibrosLoaded',
      setUp: () {
        when(
          () => repository.getLibros(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            categorias: any(named: 'categorias'),
            autor: any(named: 'autor'),
          ),
        ).thenAnswer(
          (_) async => PagedResult(
            page: 1,
            pageSize: 10,
            total: 0,
            totalPages: 0,
            data: [],
          ),
        );
      },
      build: () => LibrosCubit(repository),
      act: (cubit) async {
        await cubit.cargarLibros(query: 'quijote');
        when(
          () => repository.getLibros(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            categorias: any(named: 'categorias'),
            autor: any(named: 'autor'),
          ),
        ).thenAnswer(
          (_) async => PagedResult(
            page: 1,
            pageSize: 10,
            total: 1,
            totalPages: 1,
            data: [
              Libro(
                id: 1,
                titulo: 'Don Quijote',
                autor: 'Cervantes',
                descripcion: 'D',
                categorias: [],
              ),
            ],
          ),
        );
        await cubit.refresh();
      },
      expect: () => [
        isA<LibrosLoading>(),
        isA<LibrosLoaded>().having((s) => s.query, 'query', 'quijote'),
        isA<LibrosLoading>(),
        isA<LibrosLoaded>().having(
          (s) => s.libros.length,
          'refreshed data',
          1,
        ),
      ],
    );
  });
}
