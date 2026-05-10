import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/auth/data/models/usuario.dart';
import 'package:open_books_mobile/features/perfil/data/datasources/perfil_datasource.dart';
import 'package:open_books_mobile/shared/core/network/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockResponse<T> extends Mock implements Response<T> {}

void main() {
  const testUserId = 1;

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
  );

  late MockApiClient mockApiClient;
  late PerfilDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = PerfilDataSource(mockApiClient);
  });

  group('getPerfil', () {
    test('returns Usuario on success', () async {
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn(testUser.toJson());
      when(() => mockApiClient.get('/api/Usuarios/$testUserId'))
          .thenAnswer((_) async => response);

      final result = await dataSource.getPerfil(testUserId);

      expect(result.id, testUser.id);
      expect(result.userName, testUser.userName);
      expect(result.email, testUser.email);
      verify(() => mockApiClient.get('/api/Usuarios/$testUserId')).called(1);
    });

    test('throws on DioException', () async {
      when(() => mockApiClient.get('/api/Usuarios/$testUserId'))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/Usuarios/$testUserId'),
        message: 'Not found',
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      expect(
        () => dataSource.getPerfil(testUserId),
        throwsException,
      );
    });
  });

  group('updatePerfil', () {
    test('returns updated Usuario', () async {
      final data = {'userName': 'updateduser'};
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn(testUser.toJson());
      when(() => mockApiClient.patch(
        '/api/Usuarios/$testUserId',
        data: data,
      )).thenAnswer((_) async => response);

      final result = await dataSource.updatePerfil(testUserId, data);

      expect(result.id, testUser.id);
      verify(() => mockApiClient.patch(
        '/api/Usuarios/$testUserId',
        data: data,
      )).called(1);
    });
  });

  group('cambiarCorreo', () {
    test('delegates to API', () async {
      when(() => mockApiClient.post(
        '/api/Usuarios/$testUserId/cambiar-correo',
        data: {
          'nuevoCorreo': 'new@example.com',
          'contrasena': 'pass123',
        },
      )).thenAnswer((_) async => MockResponse<Map<String, dynamic>>());

      await dataSource.cambiarCorreo(testUserId, 'new@example.com', 'pass123');

      verify(() => mockApiClient.post(
        '/api/Usuarios/$testUserId/cambiar-correo',
        data: {
          'nuevoCorreo': 'new@example.com',
          'contrasena': 'pass123',
        },
      )).called(1);
    });
  });

  group('crearSugerencia', () {
    test('returns Sugerencia on success', () async {
      final responseData = {
        'id': 1,
        'idUsuario': 1,
        'nombreUsuario': 'testuser',
        'comentario': 'Great app!',
      };
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn(responseData);
      when(() => mockApiClient.post(
        '/api/Sugerencia',
        data: {'comentario': 'Great app!'},
      )).thenAnswer((_) async => response);

      final result = await dataSource.crearSugerencia('Great app!');

      expect(result.id, 1);
      expect(result.nombreUsuario, 'testuser');
      expect(result.comentario, 'Great app!');
    });
  });
}
