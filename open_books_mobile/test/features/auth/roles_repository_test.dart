import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/auth/data/datasources/roles_datasource.dart';
import 'package:open_books_mobile/features/auth/data/models/rol.dart';
import 'package:open_books_mobile/features/auth/data/repositories/roles_repository.dart';

class MockRolesDataSource extends Mock implements RolesDataSource {}

void main() {
  late MockRolesDataSource mockDataSource;
  late RolesRepository repository;

  setUp(() {
    mockDataSource = MockRolesDataSource();
    repository = RolesRepository(mockDataSource);
  });

  group('RolesRepository.getRol', () {
    test('delegates to datasource', () async {
      const rol = Rol(id: 1, nombre: 'Administrador');

      when(() => mockDataSource.getRol(any()))
          .thenAnswer((_) async => rol);

      final result = await repository.getRol(1);

      expect(result, equals(rol));
      verify(() => mockDataSource.getRol(1)).called(1);
    });

    test('returns null when datasource returns null', () async {
      when(() => mockDataSource.getRol(any()))
          .thenAnswer((_) async => null);

      final result = await repository.getRol(999);

      expect(result, isNull);
      verify(() => mockDataSource.getRol(999)).called(1);
    });
  });

  group('RolesRepository.getRoles', () {
    test('delegates to datasource', () async {
      final roles = [
        const Rol(id: 1, nombre: 'Administrador'),
        const Rol(id: 2, nombre: 'Usuario'),
      ];

      when(() => mockDataSource.getRoles())
          .thenAnswer((_) async => roles);

      final result = await repository.getRoles();

      expect(result, equals(roles));
      verify(() => mockDataSource.getRoles()).called(1);
    });

    test('returns empty list when datasource returns empty', () async {
      when(() => mockDataSource.getRoles())
          .thenAnswer((_) async => []);

      final result = await repository.getRoles();

      expect(result, isEmpty);
      verify(() => mockDataSource.getRoles()).called(1);
    });
  });
}
