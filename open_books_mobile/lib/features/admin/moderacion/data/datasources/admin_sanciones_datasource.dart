import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/admin_sancion.dart';

class AdminSancionesDataSource {
  late final Dio _dio;

  AdminSancionesDataSource() {
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

  Future<PagedSanciones> getSanciones({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/Sancion',
        queryParameters: {
          'page': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return PagedSanciones.fromJson(response.data);
      }

      return PagedSanciones.empty();
    } catch (e) {
      return PagedSanciones.empty();
    }
  }

  Future<AdminSancion?> getSancion(int id) async {
    try {
      final response = await _dio.get('/api/Sancion/$id');

      if (response.statusCode == 200 && response.data != null) {
        return AdminSancion.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminSancion?> createSancion(CreateSancionRequest request) async {
    try {
      final response = await _dio.post(
        '/api/Sancion',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AdminSancion.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminSancion?> updateSancion(int id, UpdateSancionRequest request) async {
    try {
      final response = await _dio.put(
        '/api/Sancion/$id',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        return AdminSancion.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteSancion(int id) async {
    try {
      final response = await _dio.delete('/api/Sancion/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
