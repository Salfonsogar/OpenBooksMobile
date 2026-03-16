import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_shouldAddToken(options.path)) {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.delete(key: _tokenKey);
    }
    handler.next(err);
  }

  bool _shouldAddToken(String path) {
    const noAuthPaths = [
      '/api/Usuarios/Login',
      '/api/Usuarios/Register',
      '/api/Usuarios/SolicitarRecuperacion',
    ];
    return !noAuthPaths.any((noAuthPath) => path.contains(noAuthPath));
  }
}
