import '../datasources/perfil_datasource.dart';
import '../../../auth/data/models/usuario.dart';
import '../models/update_perfil_request.dart';

class PerfilRepository {
  final PerfilDataSource _dataSource;

  PerfilRepository(this._dataSource);

  Future<Usuario> getPerfil(int usuarioId) {
    return _dataSource.getPerfil(usuarioId);
  }

  Future<Usuario> updatePerfil(int usuarioId, UpdatePerfilRequest request) {
    return _dataSource.updatePerfil(usuarioId, request.toJson());
  }

  Future<void> cambiarCorreo(int usuarioId, String nuevoCorreo, String contrasena) {
    return _dataSource.cambiarCorreo(usuarioId, nuevoCorreo, contrasena);
  }

  Future<void> cambiarContrasena(int usuarioId, String contrasenaActual, String nuevaContrasena) {
    return _dataSource.cambiarContrasena(usuarioId, contrasenaActual, nuevaContrasena);
  }
}
