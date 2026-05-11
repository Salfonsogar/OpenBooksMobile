import '../datasources/auth_datasource.dart';
import '../models/index.dart';

class AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepository(this._dataSource);

  Future<LoginResponse> login(String correo, String contrasena) async {
    final request = LoginRequest(correo: correo, contrasena: contrasena);
    return _dataSource.login(request);
  }

  Future<void> register({
    required String userName,
    required String correo,
    required String contrasena,
  }) async {
    final request = RegisterRequest(
      userName: userName,
      correo: correo,
      contrasena: contrasena,
    );
    await _dataSource.register(request);
  }

  Future<Map<String, dynamic>> solicitarRecuperacion(String correo) async {
    final request = RecoveryRequest(correo: correo);
    return _dataSource.solicitarRecuperacion(request);
  }

  Future<void> resetearContrasena(
    String email,
    String token,
    String nuevaContrasena,
  ) async {
    final request = ResetPasswordRequest(
      email: email,
      token: token,
      nuevaContrasena: nuevaContrasena,
    );
    await _dataSource.resetearContrasena(request);
  }

  Future<Usuario> getUsuario(String id) async {
    return _dataSource.getUsuario(id);
  }

  Future<Usuario> updateUsuario(String id, {
    String? userName,
    String? email,
    String? nombreCompleto,
  }) async {
    final data = <String, dynamic>{};
    if (userName != null) data['userName'] = userName;
    if (email != null) data['email'] = email;
    if (nombreCompleto != null) data['nombreCompleto'] = nombreCompleto;
    return _dataSource.updateUsuario(id, data);
  }
}
