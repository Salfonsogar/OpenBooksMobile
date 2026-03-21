import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/admin_libro.dart';

class AdminLibrosDataSource {
  late final Dio _dio;

  AdminLibrosDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5201',
        connectTimeout: const Duration(seconds: 60),
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

  Future<PagedLibros> getLibros({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchQuery,
    String? categorias,
    String? autor,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': pageNumber,
        'pageSize': pageSize,
      };
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['query'] = searchQuery;
      }
      if (categorias != null && categorias.isNotEmpty) {
        queryParams['categorias'] = categorias;
      }
      if (autor != null && autor.isNotEmpty) {
        queryParams['autor'] = autor;
      }

      final response = await _dio.get(
        '/api/Libros',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return _parsePagedResponse(response.data);
      }

      return PagedLibros.empty();
    } catch (e) {
      return PagedLibros.empty();
    }
  }

  PagedLibros _parsePagedResponse(dynamic data) {
    if (data == null) return PagedLibros.empty();
    
    if (data is List) {
      return PagedLibros(
        items: data.map((e) => AdminLibro.fromJson(e as Map<String, dynamic>)).toList(),
        pageNumber: 1,
        pageSize: data.length,
        totalCount: data.length,
        totalPages: 1,
      );
    }
    
    if (data is! Map<String, dynamic>) return PagedLibros.empty();
    
    final json = data as Map<String, dynamic>;
    
    final List<dynamic> dataList = json['data'] as List? ?? json['results'] as List? ?? json['items'] as List? ?? [];
    
    return PagedLibros(
      items: dataList.map((e) => AdminLibro.fromJson(e as Map<String, dynamic>)).toList(),
      pageNumber: json['page'] ?? json['currentPage'] ?? json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['total'] ?? json['totalRecords'] ?? json['totalCount'] ?? dataList.length,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Future<AdminLibro?> getLibro(int id) async {
    try {
      final response = await _dio.get('/api/Libros/$id/detalle');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return AdminLibro.fromJson(response.data);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminLibro?> createLibro(CreateLibroRequest request) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      
      final response = await _dio.post(
        '/api/Libros/upload',
        data: formData,
      );

      if (response.statusCode == 201 && response.data != null) {
        return AdminLibro.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminLibro?> updateLibro(int id, UpdateLibroRequest request) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      
      final response = await _dio.patch(
        '/api/Libros/$id',
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        return AdminLibro.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteLibro(int id) async {
    try {
      final response = await _dio.delete('/api/Libros/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
