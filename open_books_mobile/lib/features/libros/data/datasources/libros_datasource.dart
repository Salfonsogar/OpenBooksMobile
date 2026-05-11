import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../../../../shared/core/utils/error_utils.dart';
import '../models/index.dart';

class LibrosDataSource {
  final ApiClient _apiClient;

  LibrosDataSource(this._apiClient);

  Future<List<Libro>> getCatalogo() async {
    try {
      final response = await _apiClient.get('/api/Libro');
      final list = response.data as List<dynamic>;
      return list.map((e) => Libro.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PagedResult<Libro>> getLibrosPaged({
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
        queryParams['categoriaId'] = categorias.join(',');
      }
      if (autor != null && autor.isNotEmpty) queryParams['autor'] = autor;

      final response = await _apiClient.get(
        '/api/Libro/paged',
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

  Future<Libro?> getLibroById(int id) async {
    try {
      final catalogo = await getCatalogo();
      return catalogo.cast<Libro?>().firstWhere((l) => l!.id == id, orElse: () => null);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    return handleDioError(e);
  }
}
