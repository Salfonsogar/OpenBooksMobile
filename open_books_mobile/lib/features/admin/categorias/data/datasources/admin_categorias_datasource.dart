import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/admin_categoria.dart';

class AdminCategoriasDataSource {
  late final Dio _dio;

  AdminCategoriasDataSource() {
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

  Future<PagedCategorias> getCategorias({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/api/Categorias',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return PagedCategorias.fromJson(response.data);
      }

      return PagedCategorias.empty();
    } catch (e) {
      return PagedCategorias.empty();
    }
  }

  Future<AdminCategoria?> getCategoria(int id) async {
    try {
      final response = await _dio.get('/api/Categorias/$id');

      if (response.statusCode == 200 && response.data != null) {
        return AdminCategoria.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminCategoria?> createCategoria(CreateCategoriaRequest request) async {
    try {
      final response = await _dio.post(
        '/api/Categorias',
        data: request.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        return AdminCategoria.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminCategoria?> updateCategoria(int id, UpdateCategoriaRequest request) async {
    try {
      final response = await _dio.patch(
        '/api/Categorias/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AdminCategoria.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteCategoria(int id) async {
    try {
      final response = await _dio.delete('/api/Categorias/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
