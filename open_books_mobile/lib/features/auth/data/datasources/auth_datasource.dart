import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../shared/core/network/api_client.dart';
import '../../../../shared/core/utils/error_utils.dart';
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

  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/Usuarios/Register',
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final usuario = Usuario.fromJson(data);
        return LoginResponse(
          usuario: usuario,
          token: '',
        );
      }
      throw Exception('Respuesta inválida del servidor');
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
      return Usuario.fromJson(parseResponseData(response.data));
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