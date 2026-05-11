import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../models/index.dart';

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

      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception('Formato de respuesta inválido');
      }

      final items = (responseData['Items'] ?? responseData['items'] ?? responseData['data'] ?? []) as List<dynamic>;

      return PagedResult(
        page: responseData['PageNumber'] as int? ?? pageNumber,
        pageSize: responseData['PageSize'] as int? ?? pageSize,
        total: responseData['TotalCount'] as int? ?? items.length,
        totalPages: responseData['TotalPages'] as int? ?? 1,
        data: items
            .map((e) => Categoria.fromJson(e as Map<String, dynamic>))
            .toList(),
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
