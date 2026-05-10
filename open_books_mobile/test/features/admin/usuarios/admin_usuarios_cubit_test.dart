import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/admin/usuarios/data/models/admin_usuario.dart';
import 'package:open_books_mobile/features/admin/usuarios/data/repositories/admin_usuarios_repository.dart';
import 'package:open_books_mobile/features/admin/usuarios/logic/cubit/admin_usuarios_cubit.dart';
import 'package:open_books_mobile/features/admin/usuarios/logic/cubit/admin_usuarios_state.dart';

class MockAdminUsuariosRepository extends Mock implements AdminUsuariosRepository {}

void main() {
  late MockAdminUsuariosRepository repository;

  setUpAll(() {
    registerFallbackValue(UpdateUsuarioRequest());
  });

  setUp(() {
    repository = MockAdminUsuariosRepository();
  });

  final testUsuario = AdminUsuario(
    id: 1,
    userName: 'testuser',
    nombreCompleto: 'Test User',
    email: 'test@example.com',
    estado: true,
    sancionado: false,
    fechaRegistro: DateTime(2024, 1, 1),
    nombreRol: 'Usuario',
    rolId: 2,
  );

  final pagedUsuarios = PagedUsuarios(
    items: [testUsuario],
    pageNumber: 1,
    pageSize: 10,
    totalCount: 1,
    totalPages: 1,
  );

  group('AdminUsuariosCubit', () {
    blocTest<AdminUsuariosCubit, AdminUsuariosState>(
      'initial state is AdminUsuariosInitial',
      build: () => AdminUsuariosCubit(repository),
      verify: (cubit) => expect(cubit.state, isA<AdminUsuariosInitial>()),
    );

    blocTest<AdminUsuariosCubit, AdminUsuariosState>(
      'loadUsuarios success emits [AdminUsuariosLoading, AdminUsuariosLoaded]',
      setUp: () {
        when(
          () => repository.getUsuarios(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenAnswer((_) async => pagedUsuarios);
      },
      build: () => AdminUsuariosCubit(repository),
      act: (cubit) => cubit.loadUsuarios(),
      expect: () => [
        isA<AdminUsuariosLoading>(),
        isA<AdminUsuariosLoaded>().having(
          (s) => s.usuarios.items.length,
          'items length',
          1,
        ),
      ],
    );

    blocTest<AdminUsuariosCubit, AdminUsuariosState>(
      'loadUsuarios failure emits [AdminUsuariosLoading, AdminUsuariosError]',
      setUp: () {
        when(
          () => repository.getUsuarios(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenThrow(Exception('Error'));
      },
      build: () => AdminUsuariosCubit(repository),
      act: (cubit) => cubit.loadUsuarios(),
      expect: () => [
        isA<AdminUsuariosLoading>(),
        isA<AdminUsuariosError>().having(
          (s) => s.message,
          'message',
          'Exception: Error',
        ),
      ],
    );

    blocTest<AdminUsuariosCubit, AdminUsuariosState>(
      'searchUsuarios returns filtered results',
      setUp: () {
        when(
          () => repository.getUsuarios(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenAnswer((_) async => pagedUsuarios);
      },
      build: () => AdminUsuariosCubit(repository),
      act: (cubit) => cubit.searchUsuarios('test'),
      expect: () => [
        isA<AdminUsuariosLoading>(),
        isA<AdminUsuariosLoaded>().having(
          (s) => s.searchQuery,
          'searchQuery',
          'test',
        ),
      ],
    );

    blocTest<AdminUsuariosCubit, AdminUsuariosState>(
      'updateUsuario updates user and refreshes',
      setUp: () {
        when(() => repository.updateUsuario(any(), any()))
            .thenAnswer((_) async => testUsuario);
        when(
          () => repository.getUsuarios(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenAnswer((_) async => pagedUsuarios);
      },
      build: () => AdminUsuariosCubit(repository),
      act: (cubit) => cubit.updateUsuario(
        1,
        UpdateUsuarioRequest(nombreCompleto: 'Updated'),
      ),
      expect: () => [
        isA<AdminUsuarioUpdating>(),
        isA<AdminUsuarioUpdated>(),
        isA<AdminUsuariosLoading>(),
        isA<AdminUsuariosLoaded>(),
      ],
    );

    blocTest<AdminUsuariosCubit, AdminUsuariosState>(
      'deleteUsuario deletes user and refreshes',
      setUp: () {
        when(() => repository.deleteUsuario(1)).thenAnswer((_) async => true);
        when(
          () => repository.getUsuarios(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
            searchQuery: any(named: 'searchQuery'),
          ),
        ).thenAnswer((_) async => pagedUsuarios);
      },
      build: () => AdminUsuariosCubit(repository),
      seed: () => AdminUsuariosLoaded(usuarios: pagedUsuarios),
      act: (cubit) => cubit.deleteUsuario(1),
      expect: () => [
        isA<AdminUsuarioDeleting>(),
        isA<AdminUsuarioDeleted>(),
        isA<AdminUsuariosLoading>(),
        isA<AdminUsuariosLoaded>(),
      ],
    );
  });
}
