import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../../../libros/data/models/libro.dart';

class BibliotecaDataSource {
  final ApiClient _apiClient;

  BibliotecaDataSource(this._apiClient);

  Future<List<Libro>> getLibrosBiblioteca(int usuarioId) async {
    try {
      final response = await _apiClient.get(
        '/api/Biblioteca/$usuarioId/libros',
      );
      final data = response.data as Map<String, dynamic>;
      final libros = data['data'] as List<dynamic>? ?? [];
      return libros
          .map((e) => Libro.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> agregarLibro(int usuarioId, int libroId) async {
    try {
      await _apiClient.post(
        '/api/Biblioteca/$usuarioId/libros/$libroId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> quitarLibro(int usuarioId, int libroId) async {
    try {
      await _apiClient.delete(
        '/api/Biblioteca/$usuarioId/libros/$libroId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception('Recurso no encontrado');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['message'] ?? e.response?.data?['error'];
      return Exception(message ?? 'Error en la solicitud');
    }
    if (e.response?.statusCode == 409) {
      return Exception('El libro ya está en tu biblioteca');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}
