import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../../../../shared/core/utils/error_utils.dart';
import '../models/epub_manifest.dart';

class EpubDataSource {
  final ApiClient _apiClient;

  EpubDataSource(this._apiClient);

  Future<EpubManifest> getManifest(int libroId) async {
    try {
      final response = await _apiClient.get('/api/Libros/$libroId/epub/manifest');
      return EpubManifest.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> getResource(int libroId, String path) async {
    try {
      print('[DEBUG EpubDataSource] getResource inicio: libroId=$libroId, path=$path');
      final response = await _apiClient.get(
        '/api/Libros/$libroId/epub/resource',
        queryParameters: {'path': path},
      );
      print('[DEBUG EpubDataSource] getResource SUCCESS: ${response.data?.toString().length ?? 0} chars');
      return response.data as String;
    } on DioException catch (e) {
      print('[DEBUG EpubDataSource] getResource ERROR: ${e.message}, type=${e.type}, response=${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    return handleDioError(e);
  }
}
