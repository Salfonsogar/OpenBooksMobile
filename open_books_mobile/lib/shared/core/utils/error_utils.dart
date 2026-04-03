import 'dart:convert';

import 'package:dio/dio.dart';

String getErrorMessage(dynamic data) {
  if (data is String) {
    if (data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded['message'] ?? decoded['error'] ?? data;
        }
      } catch (_) {}
      return data;
    }
    return 'Error desconocido';
  }

  if (data is Map<String, dynamic>) {
    return data['message'] ?? data['error'] ?? 'Error desconocido';
  }

  return 'Error desconocido';
}

Exception handleDioError(DioException e) {
  final statusCode = e.response?.statusCode;
  final rawData = e.response?.data;
  
  final message = getErrorMessage(rawData);
  
  if (statusCode == 401) {
    return Exception(message);
  }
  if (statusCode == 403) {
    return Exception('No tienes permiso para realizar esta acción');
  }
  if (statusCode == 404) {
    return Exception('Recurso no encontrado');
  }
  if (statusCode == 400) {
    return Exception(message);
  }
  if (statusCode == 500) {
    return Exception('Error del servidor. Intenta más tarde.');
  }
  return Exception('Error de conexión. Intenta más tarde.');
}

Map<String, dynamic> parseResponseData(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is String && data.isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
  }
  throw Exception('Respuesta inválida del servidor');
}