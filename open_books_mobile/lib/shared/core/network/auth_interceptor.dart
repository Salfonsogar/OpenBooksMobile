import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

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
      final path = err.requestOptions.path;
      if (!_isAuthPath(path)) {
        await _storage.delete(key: _tokenKey);
        await _storage.delete(key: _userKey);
      }
    }
    handler.next(err);
  }

  bool _shouldAddToken(String path) {
    return !_isAuthPath(path);
  }

  bool _isAuthPath(String path) {
    const authPaths = [
      '/api/Usuarios/Login',
      '/api/Usuarios/Register',
      '/api/Usuarios/SolicitarRecuperacion',
    ];
    return authPaths.any((authPath) => path.contains(authPath));
  }
}
