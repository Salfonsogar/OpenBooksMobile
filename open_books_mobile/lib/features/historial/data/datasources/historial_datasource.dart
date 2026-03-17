import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../../../libros/data/models/libro.dart';

class HistorialDataSource {
  final ApiClient _apiClient;

  HistorialDataSource(this._apiClient);

  Future<List<Libro>> getHistorial({int cantidad = 10}) async {
    try {
      final response = await _apiClient.get(
        '/api/Historial/mis-libros',
        queryParameters: {'cantidad': cantidad},
      );
      final data = response.data as List<dynamic>? ?? [];
      return data
          .map((e) => Libro.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception('Historial no encontrado');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}
