import '../datasources/auth_datasource.dart';
import '../models/models.dart';

class AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepository(this._dataSource);

  Future<LoginResponse> login(String correo, String contrasena) async {
    final request = LoginRequest(correo: correo, contrasena: contrasena);
    return _dataSource.login(request);
  }

  Future<LoginResponse> register({
    required String nombreUsuario,
    required String correo,
    required String contrasena,
    required int rolId,
    required String nombreCompleto,
  }) async {
    final request = RegisterRequest(
      nombreUsuario: nombreUsuario,
      correo: correo,
      contrasena: contrasena,
      rolId: rolId,
      nombreCompleto: nombreCompleto,
    );
    return _dataSource.register(request);
  }

  Future<void> solicitarRecuperacion(String correo) async {
    final request = RecoveryRequest(correo: correo);
    await _dataSource.solicitarRecuperacion(request);
  }

  Future<void> resetearContrasena(String token, String nuevaContrasena) async {
    final request = ResetPasswordRequest(
      token: token,
      nuevaContrasena: nuevaContrasena,
    );
    await _dataSource.resetearContrasena(request);
  }

  Future<Usuario> getUsuario(int id) async {
    return _dataSource.getUsuario(id);
  }

  Future<Usuario> updateUsuario(int id, {
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
