import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../models/models.dart';

class LibrosDataSource {
  final ApiClient _apiClient;

  LibrosDataSource(this._apiClient);

  Future<PagedResult<Libro>> getLibros({
    String? query,
    int page = 1,
    int pageSize = 10,
    List<int>? categorias,
    String? autor,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (query != null && query.isNotEmpty) queryParams['query'] = query;
      if (categorias != null && categorias.isNotEmpty) {
        queryParams['categorias'] = categorias.join(',');
      }
      if (autor != null && autor.isNotEmpty) queryParams['autor'] = autor;

      final response = await _apiClient.get(
        '/api/Libros',
        queryParameters: queryParams,
      );
      return PagedResult.fromJson(
        response.data as Map<String, dynamic>,
        Libro.fromJson,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LibroDetalle> getLibroDetalle(int id, {int page = 1, int pageSize = 5}) async {
    try {
      final response = await _apiClient.get(
        '/api/Libros/$id/detalle',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return LibroDetalle.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> getPortada(int id) async {
    try {
      final response = await _apiClient.get(
        '/api/Libros/$id/portada',
        options: Options(responseType: ResponseType.bytes),
      );
      
      final bytes = response.data as List<int>;
      
      if (bytes.isEmpty) {
        return '';
      }
      
      return base64Encode(bytes);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 204) {
        return '';
      }
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception('Libro no encontrado');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['message'] ?? e.response?.data?['error'];
      return Exception(message ?? 'Error en la solicitud');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}
