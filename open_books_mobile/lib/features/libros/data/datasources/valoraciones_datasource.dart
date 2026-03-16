import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../models/models.dart';

class ValoracionesDataSource {
  final ApiClient _apiClient;

  ValoracionesDataSource(this._apiClient);

  Future<void> crearValoracion(int libroId, int puntuacion) async {
    try {
      await _apiClient.post(
        '/api/Valoraciones',
        data: {'libroId': libroId, 'puntuacion': puntuacion},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> actualizarValoracion(int libroId, int puntuacion) async {
    try {
      await _apiClient.put(
        '/api/Valoraciones',
        data: {'libroId': libroId, 'puntuacion': puntuacion},
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
      final response = await _apiClient.get('/api/Valoraciones/top5');
      return (response.data as List<dynamic>)
          .map((e) => Libro.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['message'] ?? e.response?.data?['error'];
      return Exception(message ?? 'Error en la solicitud');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}
