import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/admin_denuncia.dart';

class AdminDenunciasDataSource {
  late final Dio _dio;

  AdminDenunciasDataSource() {
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

  Future<PagedDenuncias> getDenuncias({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/Denuncia',
        queryParameters: {
          'pagina': pageNumber,
          'tamanoPagina': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return _parsePagedResponse(response.data);
      }

      return PagedDenuncias.empty();
    } catch (e) {
      return PagedDenuncias.empty();
    }
  }

  PagedDenuncias _parsePagedResponse(dynamic data) {
    if (data == null) return PagedDenuncias.empty();
    
    if (data is List) {
      return PagedDenuncias(
        items: data.map((e) => AdminDenuncia.fromJson(e)).toList(),
        pageNumber: 1,
        pageSize: data.length,
        totalCount: data.length,
        totalPages: 1,
      );
    }
    
    if (data is! Map<String, dynamic>) return PagedDenuncias.empty();
    
    if (data.containsKey('results')) {
      final results = data['results'] as List? ?? [];
      return PagedDenuncias(
        items: results.map((e) => AdminDenuncia.fromJson(e)).toList(),
        pageNumber: data['currentPage'] ?? data['pageNumber'] ?? 1,
        pageSize: data['pageSize'] ?? results.length,
        totalCount: data['totalRecords'] ?? data['totalCount'] ?? results.length,
        totalPages: data['totalPages'] ?? 1,
      );
    }
    
    if (data.containsKey('items')) {
      final items = data['items'] as List? ?? [];
      return PagedDenuncias(
        items: items.map((e) => AdminDenuncia.fromJson(e)).toList(),
        pageNumber: data['currentPage'] ?? data['pageNumber'] ?? 1,
        pageSize: data['pageSize'] ?? items.length,
        totalCount: data['totalRecords'] ?? data['totalCount'] ?? items.length,
        totalPages: data['totalPages'] ?? 1,
      );
    }

    return PagedDenuncias.empty();
  }

  Future<AdminDenuncia?> getDenuncia(int id) async {
    try {
      final response = await _dio.get('/api/Denuncia/$id');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return AdminDenuncia.fromJson(response.data);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteDenuncia(int id) async {
    try {
      final response = await _dio.delete('/api/Denuncia/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
