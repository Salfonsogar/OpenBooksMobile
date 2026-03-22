import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/admin_usuario.dart';

class AdminUsuariosDataSource {
  late final Dio _dio;

  AdminUsuariosDataSource() {
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

  Future<PagedUsuarios> getUsuarios({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['searchQuery'] = searchQuery;
      }

      final response = await _dio.get(
        '/api/Usuarios',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return _parsePagedResponse(response.data);
      }

      return PagedUsuarios.empty();
    } catch (e) {
      return PagedUsuarios.empty();
    }
  }

  PagedUsuarios _parsePagedResponse(dynamic data) {
    if (data == null) return PagedUsuarios.empty();
    
    if (data is List) {
      return PagedUsuarios(
        items: data.map((e) => AdminUsuario.fromJson(e as Map<String, dynamic>)).toList(),
        pageNumber: 1,
        pageSize: data.length,
        totalCount: data.length,
        totalPages: 1,
      );
    }
    
    if (data is! Map<String, dynamic>) return PagedUsuarios.empty();
    
    final json = data as Map<String, dynamic>;
    
    if (json.containsKey('results')) {
      final results = json['results'] as List? ?? [];
      return PagedUsuarios(
        items: results.map((e) => AdminUsuario.fromJson(e as Map<String, dynamic>)).toList(),
        pageNumber: json['currentPage'] ?? json['pageNumber'] ?? 1,
        pageSize: json['pageSize'] ?? results.length,
        totalCount: json['totalRecords'] ?? json['totalCount'] ?? results.length,
        totalPages: json['totalPages'] ?? 1,
      );
    }
    
    if (json.containsKey('items')) {
      final items = json['items'] as List? ?? [];
      return PagedUsuarios(
        items: items.map((e) => AdminUsuario.fromJson(e as Map<String, dynamic>)).toList(),
        pageNumber: json['currentPage'] ?? json['pageNumber'] ?? 1,
        pageSize: json['pageSize'] ?? items.length,
        totalCount: json['totalRecords'] ?? json['totalCount'] ?? items.length,
        totalPages: json['totalPages'] ?? 1,
      );
    }

    return PagedUsuarios.empty();
  }

  Future<AdminUsuario?> getUsuario(int id) async {
    try {
      final response = await _dio.get('/api/Usuarios/$id');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return AdminUsuario.fromJson(response.data);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminUsuario?> createUsuario(CreateUsuarioRequest request) async {
    try {
      final response = await _dio.post(
        '/api/Usuarios',
        data: request.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        return AdminUsuario.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminUsuario?> updateUsuario(int id, UpdateUsuarioRequest request) async {
    try {
      final response = await _dio.patch(
        '/api/Usuarios/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AdminUsuario.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteUsuario(int id) async {
    try {
      final response = await _dio.delete('/api/Usuarios/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
