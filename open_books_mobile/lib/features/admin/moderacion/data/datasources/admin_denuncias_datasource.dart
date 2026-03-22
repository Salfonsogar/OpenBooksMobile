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
        items: data.map((e) => AdminDenuncia.fromJson(e as Map<String, dynamic>)).toList(),
        pageNumber: 1,
        pageSize: data.length,
        totalCount: data.length,
        totalPages: 1,
      );
    }
    
    if (data is! Map<String, dynamic>) return PagedDenuncias.empty();
    
    final json = data as Map<String, dynamic>;
    
    if (json.containsKey('results')) {
      final results = json['results'] as List? ?? [];
      return PagedDenuncias(
        items: results.map((e) => AdminDenuncia.fromJson(e as Map<String, dynamic>)).toList(),
        pageNumber: json['currentPage'] ?? json['pageNumber'] ?? 1,
        pageSize: json['pageSize'] ?? results.length,
        totalCount: json['totalRecords'] ?? json['totalCount'] ?? results.length,
        totalPages: json['totalPages'] ?? 1,
      );
    }
    
    if (json.containsKey('items')) {
      final items = json['items'] as List? ?? [];
      return PagedDenuncias(
        items: items.map((e) => AdminDenuncia.fromJson(e as Map<String, dynamic>)).toList(),
        pageNumber: json['currentPage'] ?? json['pageNumber'] ?? 1,
        pageSize: json['pageSize'] ?? items.length,
        totalCount: json['totalRecords'] ?? json['totalCount'] ?? items.length,
        totalPages: json['totalPages'] ?? 1,
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
