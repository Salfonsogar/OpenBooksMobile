import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../models/models.dart';

class CategoriasDataSource {
  final ApiClient _apiClient;

  CategoriasDataSource(this._apiClient);

  Future<PagedResult<Categoria>> getCategorias({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/Categorias',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      return PagedResult.fromJson(
        response.data as Map<String, dynamic>,
        Categoria.fromJson,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Categoria> getCategoria(int id) async {
    try {
      final response = await _apiClient.get('/api/Categorias/$id');
      return Categoria.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception('Categoría no encontrada');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}
