import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/admin/libros/data/models/admin_libro.dart';
import 'package:open_books_mobile/features/admin/libros/data/repositories/admin_libros_repository.dart';
import 'package:open_books_mobile/features/admin/libros/logic/cubit/admin_libros_cubit.dart';

class MockAdminLibrosRepository extends Mock implements AdminLibrosRepository {}

void main() {
  late MockAdminLibrosRepository repository;

  setUpAll(() {
    registerFallbackValue(CreateLibroRequest(titulo: '', autor: '', categoriasIds: []));
    registerFallbackValue(UpdateLibroRequest());
  });

  setUp(() {
    repository = MockAdminLibrosRepository();
  });

  final testLibro = AdminLibro(
    id: 1,
    titulo: 'Test Book',
    autor: 'Author',
    descripcion: 'Desc',
    fechaPublicacion: DateTime(2024, 1, 1),
    activo: true,
    categorias: const ['Ficción'],
  );

  final pagedLibros = PagedLibros(
    items: [testLibro],
    pageNumber: 1,
    pageSize: 10,
    totalCount: 1,
    totalPages: 1,
  );

  group('AdminLibrosCubit', () {
    blocTest<AdminLibrosCubit, AdminLibrosState>(
      'initial state is AdminLibrosInitial',
      build: () => AdminLibrosCubit(repository),
      verify: (cubit) => expect(cubit.state, isA<AdminLibrosInitial>()),
    );

    blocTest<AdminLibrosCubit, AdminLibrosState>(
      'loadLibros success emits [AdminLibrosLoading, AdminLibrosLoaded]',
      setUp: () {
        when(
          () => repository.getLibros(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenAnswer((_) async => pagedLibros);
      },
      build: () => AdminLibrosCubit(repository),
      act: (cubit) => cubit.loadLibros(),
      expect: () => [
        isA<AdminLibrosLoading>(),
        isA<AdminLibrosLoaded>().having(
          (s) => s.libros.items.length,
          'items length',
          1,
        ),
      ],
    );

    blocTest<AdminLibrosCubit, AdminLibrosState>(
      'loadLibros failure emits [AdminLibrosLoading, AdminLibrosError]',
      setUp: () {
        when(
          () => repository.getLibros(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenThrow(Exception('Error'));
      },
      build: () => AdminLibrosCubit(repository),
      act: (cubit) => cubit.loadLibros(),
      expect: () => [
        isA<AdminLibrosLoading>(),
        isA<AdminLibrosError>().having(
          (s) => s.message,
          'message',
          'Exception: Error',
        ),
      ],
    );

    blocTest<AdminLibrosCubit, AdminLibrosState>(
      'createLibro creates libro and refreshes',
      setUp: () {
        when(() => repository.createLibro(any()))
            .thenAnswer((_) async => testLibro);
        when(
          () => repository.getLibros(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenAnswer((_) async => pagedLibros);
      },
      build: () => AdminLibrosCubit(repository),
      act: (cubit) => cubit.createLibro(
        CreateLibroRequest(titulo: 'Test', autor: 'Author', categoriasIds: [1]),
      ),
      expect: () => [
        isA<AdminLibrosCreating>(),
        isA<AdminLibrosCreated>(),
        isA<AdminLibrosLoading>(),
        isA<AdminLibrosLoaded>(),
      ],
    );

    blocTest<AdminLibrosCubit, AdminLibrosState>(
      'updateLibro updates libro and refreshes',
      setUp: () {
        when(() => repository.updateLibro(any(), any()))
            .thenAnswer((_) async => testLibro);
        when(
          () => repository.getLibros(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenAnswer((_) async => pagedLibros);
      },
      build: () => AdminLibrosCubit(repository),
      act: (cubit) => cubit.updateLibro(
        1,
        UpdateLibroRequest(titulo: 'Updated'),
      ),
      expect: () => [
        isA<AdminLibrosUpdating>(),
        isA<AdminLibrosUpdated>(),
        isA<AdminLibrosLoading>(),
        isA<AdminLibrosLoaded>(),
      ],
    );

    blocTest<AdminLibrosCubit, AdminLibrosState>(
      'deleteLibro deletes libro and refreshes',
      setUp: () {
        when(() => repository.deleteLibro(1)).thenAnswer((_) async => true);
        when(
          () => repository.getLibros(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenAnswer((_) async => pagedLibros);
      },
      build: () => AdminLibrosCubit(repository),
      seed: () => AdminLibrosLoaded(libros: pagedLibros),
      act: (cubit) => cubit.deleteLibro(1),
      expect: () => [
        isA<AdminLibrosDeleting>(),
        isA<AdminLibrosDeleted>(),
        isA<AdminLibrosLoading>(),
        isA<AdminLibrosLoaded>(),
      ],
    );
  });
}
