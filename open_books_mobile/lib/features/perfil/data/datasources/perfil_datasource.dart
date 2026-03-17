import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../../../auth/data/models/usuario.dart';

class PerfilDataSource {
  final ApiClient _apiClient;

  PerfilDataSource(this._apiClient);

  Future<Usuario> getPerfil(int usuarioId) async {
    try {
      final response = await _apiClient.get('/api/Usuarios/$usuarioId');
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Usuario> updatePerfil(int usuarioId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        '/api/Usuarios/$usuarioId',
        data: data,
      );
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> cambiarCorreo(int usuarioId, String nuevoCorreo, String contrasena) async {
    try {
      await _apiClient.post(
        '/api/Usuarios/$usuarioId/cambiar-correo',
        data: {
          'nuevoCorreo': nuevoCorreo,
          'contrasena': contrasena,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> cambiarContrasena(int usuarioId, String contrasenaActual, String nuevaContrasena) async {
    try {
      await _apiClient.post(
        '/api/Usuarios/$usuarioId/cambiar-contrasena',
        data: {
          'contrasenaActual': contrasenaActual,
          'nuevaContrasena': nuevaContrasena,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception('Usuario no encontrado');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['message'] ?? e.response?.data?['error'];
      return Exception(message ?? 'Error en la solicitud');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}
