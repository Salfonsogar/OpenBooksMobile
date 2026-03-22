import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/rol.dart';

class RolesDataSource {
  late final Dio _dio;

  RolesDataSource() {
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

  Future<Rol?> getRol(int rolId) async {
    try {
      final response = await _dio.get('/api/Rols/$rolId');
      
      if (response.statusCode == 200 && response.data != null) {
        return Rol.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Rol>> getRoles() async {
    try {
      final response = await _dio.get('/api/Rols');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Rol.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}
