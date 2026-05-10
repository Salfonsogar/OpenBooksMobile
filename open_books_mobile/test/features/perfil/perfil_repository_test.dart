import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/perfil/data/datasources/perfil_datasource.dart';
import 'package:open_books_mobile/features/perfil/data/models/update_perfil_request.dart';
import 'package:open_books_mobile/features/perfil/data/repositories/perfil_repository.dart';
import 'package:open_books_mobile/shared/services/datasources/perfil_local_datasource.dart';
import 'package:open_books_mobile/shared/services/local_database.dart';
import 'package:open_books_mobile/shared/services/network_info.dart';

class MockPerfilDataSource extends Mock implements PerfilDataSource {}

class MockLocalDatabase extends Mock implements LocalDatabase {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockPerfilLocalDataSource extends Mock implements PerfilLocalDataSource {}

void main() {
  final testUser = Usuario(
    id: 1,
    userName: 'testuser',
    nombreCompleto: 'Test User',
    email: 'test@example.com',
    estado: true,
    sancionado: false,
    fechaRegistro: DateTime(2026, 1, 1),
    nombreRol: 'Usuario',
    rolId: 2,
    fotoPerfilBase64: null,
  );

  const testUserId = 1;

  late MockPerfilDataSource mockDataSource;
  late MockLocalDatabase mockLocalDatabase;
  late MockNetworkInfo mockNetworkInfo;
  late MockPerfilLocalDataSource mockPerfilLocal;
  late PerfilRepository repository;

  setUpAll(() {
    registerFallbackValue(0);
    registerFallbackValue(testUser.toJson());
    registerFallbackValue(UpdatePerfilRequest());
  });

  setUp(() {
    mockDataSource = MockPerfilDataSource();
    mockLocalDatabase = MockLocalDatabase();
    mockNetworkInfo = MockNetworkInfo();
    mockPerfilLocal = MockPerfilLocalDataSource();

    when(() => mockLocalDatabase.perfilLocalDataSource).thenReturn(mockPerfilLocal);

    repository = PerfilRepository(
      mockDataSource,
      mockLocalDatabase,
      mockNetworkInfo,
    );
  });

  group('getPerfil', () {
    test('when online fetches from datasource and caches locally', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.getPerfil(testUserId))
          .thenAnswer((_) async => testUser);
      when(() => mockPerfilLocal.upsert(any(), any())).thenAnswer((_) async => {});

      final result = await repository.getPerfil(testUserId);

      expect(result, equals(testUser));
      verify(() => mockDataSource.getPerfil(testUserId)).called(1);
      verify(() => mockPerfilLocal.upsert(any(), any())).called(1);
    });

    test('when offline returns cached data', () async {
      final cachedJson = <String, dynamic>{
        'usuario_id': 1,
        'user_name': 'testuser',
        'nombre_completo': 'Test User',
        'email': 'test@example.com',
        'estado': 1,
        'sancionado': 0,
        'fecha_registro': '2026-01-01T00:00:00.000',
        'nombre_rol': 'Usuario',
        'rol_id': 2,
      };

      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockPerfilLocal.getPerfil(testUserId))
          .thenAnswer((_) async => cachedJson);

      final result = await repository.getPerfil(testUserId);

      expect(result.id, 1);
      expect(result.userName, 'testuser');
      expect(result.nombreCompleto, 'Test User');
      expect(result.email, 'test@example.com');
      verifyNever(() => mockDataSource.getPerfil(any()));
      verify(() => mockPerfilLocal.getPerfil(testUserId)).called(1);
    });

    test('when offline with no cache throws', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockPerfilLocal.getPerfil(testUserId))
          .thenAnswer((_) async => null);

      expect(
        () => repository.getPerfil(testUserId),
        throwsException,
      );
    });
  });

  group('updatePerfil', () {
    test('updates datasource and cache', () async {
      final request = UpdatePerfilRequest(userName: 'updateduser');

      when(() => mockDataSource.updatePerfil(testUserId, any()))
          .thenAnswer((_) async => testUser);
      when(() => mockPerfilLocal.upsert(any(), any())).thenAnswer((_) async => {});

      final result = await repository.updatePerfil(testUserId, request);

      expect(result, equals(testUser));
      verify(() => mockDataSource.updatePerfil(testUserId, request.toJson())).called(1);
      verify(() => mockPerfilLocal.upsert(any(), any())).called(1);
    });
  });
}
