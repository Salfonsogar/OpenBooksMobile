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

      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception('Formato de respuesta inválido');
      }

      List<dynamic> resultsList = [];
      if (responseData.containsKey('results')) {
        resultsList = responseData['results'] as List<dynamic>? ?? [];
      } else if (responseData.containsKey('items')) {
        resultsList = responseData['items'] as List<dynamic>? ?? [];
      } else if (responseData.containsKey('data')) {
        resultsList = responseData['data'] as List<dynamic>? ?? [];
      }

      return PagedResult(
        page: responseData['currentPage'] ?? responseData['pageNumber'] ?? pageNumber,
        pageSize: responseData['pageSize'] ?? pageSize,
        total: responseData['totalRecords'] ?? responseData['totalCount'] ?? resultsList.length,
        totalPages: responseData['totalPages'] ?? 1,
        data: resultsList
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
