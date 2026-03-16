import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../models/models.dart';

class AuthDataSource {
  final ApiClient _apiClient;

  AuthDataSource(this._apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/Usuarios/Login',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/Usuarios/Register',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> solicitarRecuperacion(RecoveryRequest request) async {
    try {
      await _apiClient.post(
        '/api/Usuarios/SolicitarRecuperacion',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetearContrasena(ResetPasswordRequest request) async {
    try {
      await _apiClient.post(
        '/api/Usuarios/ResetearContrasena',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Usuario> getUsuario(int id) async {
    try {
      final response = await _apiClient.get('/api/Usuarios/$id');
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Usuario> updateUsuario(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        '/api/Usuarios/$id',
        data: data,
      );
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Credenciales incorrectas');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['message'] ?? e.response?.data?['error'];
      return Exception(message ?? 'Error en la solicitud');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Usuario no encontrado');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}
