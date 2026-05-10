import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/admin/moderacion/data/models/admin_rol.dart';
import 'package:open_books_mobile/features/admin/moderacion/data/repositories/admin_roles_repository.dart';
import 'package:open_books_mobile/features/admin/moderacion/logic/cubit/admin_roles_cubit.dart';

class MockAdminRolesRepository extends Mock implements AdminRolesRepository {}

void main() {
  late MockAdminRolesRepository repository;

  setUpAll(() {
    registerFallbackValue(CreateRolRequest(nombre: ''));
    registerFallbackValue(UpdateRolRequest());
  });

  setUp(() {
    repository = MockAdminRolesRepository();
  });

  final testRoles = [
    const AdminRol(id: 1, nombre: 'Administrador'),
    const AdminRol(id: 2, nombre: 'Usuario'),
  ];

  group('AdminRolesCubit', () {
    blocTest<AdminRolesCubit, AdminRolesState>(
      'initial state is AdminRolesInitial',
      build: () => AdminRolesCubit(repository),
      verify: (cubit) => expect(cubit.state, isA<AdminRolesInitial>()),
    );

    blocTest<AdminRolesCubit, AdminRolesState>(
      'loadRoles success emits [AdminRolesLoading, AdminRolesLoaded]',
      setUp: () {
        when(() => repository.getRoles()).thenAnswer((_) async => testRoles);
      },
      build: () => AdminRolesCubit(repository),
      act: (cubit) => cubit.loadRoles(),
      expect: () => [
        isA<AdminRolesLoading>(),
        isA<AdminRolesLoaded>().having(
          (s) => s.roles.length,
          'roles length',
          2,
        ),
      ],
    );

    blocTest<AdminRolesCubit, AdminRolesState>(
      'loadRoles failure emits [AdminRolesLoading, AdminRolesError]',
      setUp: () {
        when(() => repository.getRoles()).thenThrow(Exception('Error'));
      },
      build: () => AdminRolesCubit(repository),
      act: (cubit) => cubit.loadRoles(),
      expect: () => [
        isA<AdminRolesLoading>(),
        isA<AdminRolesError>().having(
          (s) => s.message,
          'message',
          'Exception: Error',
        ),
      ],
    );

    blocTest<AdminRolesCubit, AdminRolesState>(
      'createRol creates rol and reloads',
      setUp: () {
        when(() => repository.createRol(any()))
            .thenAnswer((_) async => const AdminRol(id: 3, nombre: 'Editor'));
        when(() => repository.getRoles()).thenAnswer((_) async => testRoles);
      },
      build: () => AdminRolesCubit(repository),
      act: (cubit) => cubit.createRol(CreateRolRequest(nombre: 'Editor')),
      expect: () => [
        isA<AdminRolesLoading>(),
        isA<AdminRolesLoaded>(),
      ],
    );

    blocTest<AdminRolesCubit, AdminRolesState>(
      'updateRol updates rol and reloads',
      setUp: () {
        when(() => repository.updateRol(any(), any()))
            .thenAnswer((_) async => const AdminRol(id: 2, nombre: 'Lector'));
        when(() => repository.getRoles()).thenAnswer((_) async => testRoles);
      },
      build: () => AdminRolesCubit(repository),
      seed: () => AdminRolesLoaded(testRoles),
      act: (cubit) => cubit.updateRol(2, UpdateRolRequest(nombre: 'Lector')),
      expect: () => [
        isA<AdminRolesLoading>(),
        isA<AdminRolesLoaded>(),
      ],
    );

    blocTest<AdminRolesCubit, AdminRolesState>(
      'deleteRol deletes rol and reloads',
      setUp: () {
        when(() => repository.deleteRol(2)).thenAnswer((_) async => true);
        when(() => repository.getRoles()).thenAnswer((_) async => testRoles);
      },
      build: () => AdminRolesCubit(repository),
      seed: () => AdminRolesLoaded(testRoles),
      act: (cubit) => cubit.deleteRol(2),
      expect: () => [
        isA<AdminRolesLoading>(),
        isA<AdminRolesLoaded>(),
      ],
    );
  });
}
