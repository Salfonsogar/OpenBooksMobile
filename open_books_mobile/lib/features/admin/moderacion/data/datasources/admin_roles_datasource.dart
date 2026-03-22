import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/admin_rol.dart';

class AdminRolesDataSource {
  late final Dio _dio;

  AdminRolesDataSource() {
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

  Future<List<AdminRol>> getRoles() async {
    try {
      final response = await _dio.get('/api/Rols');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => AdminRol.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<AdminRol?> getRol(int id) async {
    try {
      final response = await _dio.get('/api/Rols/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        return AdminRol.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminRol?> createRol(CreateRolRequest request) async {
    try {
      final response = await _dio.post(
        '/api/Rols',
        data: request.toJson(),
      );
      
      if (response.statusCode == 201 && response.data != null) {
        return AdminRol.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AdminRol?> updateRol(int id, UpdateRolRequest request) async {
    try {
      final response = await _dio.patch(
        '/api/Rols/$id',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return AdminRol.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteRol(int id) async {
    try {
      final response = await _dio.delete('/api/Rols/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
