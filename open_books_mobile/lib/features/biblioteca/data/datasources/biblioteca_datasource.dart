import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../shared/core/network/api_client.dart';
import '../models/libro_biblioteca.dart';

class BibliotecaDataSource {
  final ApiClient _apiClient;

  BibliotecaDataSource(this._apiClient);

  Future<List<LibroBiblioteca>> getLibrosBiblioteca(int usuarioId) async {
    try {
      final response = await _apiClient.get(
        '/api/Biblioteca/$usuarioId/libros',
      );
      final data = response.data as Map<String, dynamic>;
      final libros = data['data'] as List<dynamic>? ?? [];
      return libros
          .map((e) => LibroBiblioteca.fromJson(e as Map<String, dynamic>))
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

  Future<String> descargarLibro(int libroId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/libro_$libroId.epub';
      
      await _apiClient.download(
        '/api/Libros/$libroId/descargar',
        savePath,
      );
      
      return savePath;
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
