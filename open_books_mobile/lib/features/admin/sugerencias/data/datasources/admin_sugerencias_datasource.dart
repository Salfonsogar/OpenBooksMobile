import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/admin_sugerencia.dart';

class AdminSugerenciasDataSource {
  late final Dio _dio;

  AdminSugerenciasDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5201',
        connectTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<PagedSugerencias> getSugerencias({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/Sugerencia',
        queryParameters: {
          'pagina': pageNumber,
          'tamanoPagina': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return _parsePagedResponse(response.data);
      }

      return PagedSugerencias.empty();
    } catch (e) {
      return PagedSugerencias.empty();
    }
  }

  PagedSugerencias _parsePagedResponse(dynamic data) {
    if (data == null) return PagedSugerencias.empty();
    
    Map<String, dynamic> json;
    
    if (data is List) {
      return PagedSugerencias(
        items: (data).map((e) => AdminSugerencia.fromJson(e)).toList(),
        pageNumber: 1,
        pageSize: data.length,
        totalCount: data.length,
        totalPages: 1,
      );
    } else if (data is Map<String, dynamic>) {
      json = data;
    } else {
      return PagedSugerencias.empty();
    }

    if (json.containsKey('items')) {
      return PagedSugerencias.fromJson(json);
    } else if (json.containsKey('data') && json['data'] is Map) {
      return PagedSugerencias.fromJson(json['data'] as Map<String, dynamic>);
    } else if (json.containsKey('data') && json['data'] is List) {
      final listData = json['data'] as List;
      return PagedSugerencias(
        items: listData.map((e) => AdminSugerencia.fromJson(e)).toList(),
        pageNumber: json['pagina'] ?? 1,
        pageSize: json['tamanoPagina'] ?? listData.length,
        totalCount: json['totalCount'] ?? listData.length,
        totalPages: json['totalPages'] ?? 1,
      );
    }

    return PagedSugerencias.empty();
  }

  Future<AdminSugerencia?> getSugerencia(int id) async {
    try {
      final response = await _dio.get('/api/Sugerencia/$id');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return AdminSugerencia.fromJson(response.data);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteSugerencia(int id) async {
    try {
      final response = await _dio.delete('/api/Sugerencia/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
