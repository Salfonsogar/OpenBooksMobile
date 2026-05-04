import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../models/index.dart';

class ValoracionesDataSource {
  final ApiClient _apiClient;

  ValoracionesDataSource(this._apiClient);

  Future<void> crearValoracion(int libroId, int puntuacion) async {
    try {
      final response = await _apiClient.post(
        '/api/Valoraciones',
        data: {'IdLibro': libroId, 'puntuacion': puntuacion},
      );
      if (response.statusCode == 400) {
        final message = response.data?['mensaje'] ?? response.data?['message'] ?? response.data?['error'] ?? 'Error en la solicitud';
        throw Exception(message);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> actualizarValoracion(int libroId, int puntuacion) async {
    try {
      await _apiClient.put(
        '/api/Valoraciones',
        queryParameters: {'IdLibro': libroId},
        data: {'puntuacion': puntuacion},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> eliminarValoracion(int libroId) async {
    try {
      await _apiClient.delete(
        '/api/Valoraciones',
        queryParameters: {'idLibro': libroId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Valoracion>> getValoracionesLibro(int libroId) async {
    try {
      final response = await _apiClient.get('/api/Valoraciones/libro/$libroId');
      return (response.data as List<dynamic>)
          .map((e) => Valoracion.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Libro>> getTop5Libros() async {
    try {
      final response = await _apiClient.get(
        '/api/Libros',
        queryParameters: {'ordenarPor': 'valoraciones', 'page': 1, 'pageSize': 10},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List<dynamic>)
          .map((e) => Libro.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['message'] ?? e.response?.data?['error'] ?? e.response?.data?['mensaje'];
      return Exception(message ?? 'Error en la solicitud');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}