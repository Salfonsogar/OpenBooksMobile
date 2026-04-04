import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../models/models.dart';

class ResenasDataSource {
  final ApiClient _apiClient;

  ResenasDataSource(this._apiClient);

  Future<Resena> crearResena(int libroId, String texto) async {
    try {
      final response = await _apiClient.post(
        '/api/Resenas',
        data: {'libroId': libroId, 'texto': texto},
      );
      return Resena.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Resena> actualizarResena(int idResena, String texto) async {
    try {
      final response = await _apiClient.put(
        '/api/Resenas/$idResena',
        data: {'texto': texto},
      );
      return Resena.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> eliminarResena(int idResena) async {
    try {
      await _apiClient.delete('/api/Resenas/$idResena');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PagedResult<Resena>> getResenasLibro(int idLibro, {int page = 1, int pageSize = 5}) async {
    try {
      final response = await _apiClient.get(
        '/api/Resenas/libro/$idLibro',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return PagedResult.fromJson(
        response.data as Map<String, dynamic>,
        Resena.fromJson,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<DenunciaResena> crearDenunciaResena({
    required int idDenunciante,
    required int idDenunciado,
    required int idResena,
    required String motivo,
    String? comentario,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/Denuncia',
        data: {
          'idDenunciante': idDenunciante,
          'idDenunciado': idDenunciado,
          'idResena': idResena,
          'motivo': motivo,
          'comentario': comentario ?? '',
        },
      );
      return DenunciaResena.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['message'] ?? e.response?.data?['error'];
      return Exception(message ?? 'Error en la solicitud');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Reseña no encontrada');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}
