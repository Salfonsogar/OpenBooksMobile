import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../../../../shared/core/utils/error_utils.dart';
import '../../../auth/data/models/usuario.dart';
import '../models/sugerencia.dart';

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
    return handleDioError(e);
  }

  Future<Sugerencia> crearSugerencia(String comentario) async {
    try {
      final response = await _apiClient.post(
        '/api/Sugerencia',
        data: {'comentario': comentario},
      );
      return Sugerencia.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
