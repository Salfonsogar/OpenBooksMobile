import 'package:dio/dio.dart';

import '../../../../shared/core/network/api_client.dart';
import '../../../../shared/core/utils/error_utils.dart';
import '../models/index.dart';

class AuthDataSource {
  final ApiClient _apiClient;

  AuthDataSource(this._apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/Auth/login',
        data: request.toJson(),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 400) {
        throw _handleErrorFromResponse(response.statusCode, response.data);
      }

      return LoginResponse.fromJson(parseResponseData(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleErrorFromResponse(int? statusCode, dynamic data) {
    final message = getErrorMessage(data);

    if (statusCode == 401) {
      return Exception(message);
    }
    if (statusCode == 400) {
      return Exception(message);
    }
    if (statusCode == 404) {
      return Exception('Usuario no encontrado');
    }
    return Exception(message.isNotEmpty ? message : 'Error de conexión');
  }

  Future<void> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/Auth/register',
        data: request.toJson(),
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 400) {
        throw _handleErrorFromResponse(statusCode, response.data);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> solicitarRecuperacion(RecoveryRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/Usuario/solicitar-recuperacion',
        data: request.toJson(),
      );
      return parseResponseData(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetearContrasena(ResetPasswordRequest request) async {
    try {
      await _apiClient.post(
        '/api/Usuario/reset-password',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Usuario> getUsuario(String id) async {
    try {
      final response = await _apiClient.get('/api/Usuario/$id');
      return Usuario.fromJson(parseResponseData(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Usuario> updateUsuario(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/api/Usuario/$id', data: data);
      return Usuario.fromJson(parseResponseData(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final rawData = e.response?.data;

    final message = getErrorMessage(rawData);

    if (statusCode == 401) {
      return Exception(message);
    }
    if (statusCode == 400) {
      return Exception(message);
    }
    if (statusCode == 404) {
      return Exception('Usuario no encontrado');
    }
    return handleDioError(e);
  }
}
