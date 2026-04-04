import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/create_user_libro.dart';

class UserLibrosDataSource {
  late final Dio _dio;

  UserLibrosDataSource() {
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

  Future<bool> createLibro(CreateUserLibroRequest request) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      
      final response = await _dio.post(
        '/api/Libros/upload',
        data: formData,
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
