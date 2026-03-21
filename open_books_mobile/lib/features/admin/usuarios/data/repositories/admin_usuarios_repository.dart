import '../datasources/admin_usuarios_datasource.dart';
import '../models/admin_usuario.dart';

class AdminUsuariosRepository {
  final AdminUsuariosDataSource _dataSource;

  AdminUsuariosRepository(this._dataSource);

  void setToken(String token) {
    _dataSource.setToken(token);
  }

  Future<PagedUsuarios> getUsuarios({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchQuery,
  }) async {
    return await _dataSource.getUsuarios(
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchQuery: searchQuery,
    );
  }

  Future<AdminUsuario?> getUsuario(int id) async {
    return await _dataSource.getUsuario(id);
  }

  Future<AdminUsuario?> createUsuario(CreateUsuarioRequest request) async {
    return await _dataSource.createUsuario(request);
  }

  Future<AdminUsuario?> updateUsuario(int id, UpdateUsuarioRequest request) async {
    return await _dataSource.updateUsuario(id, request);
  }

  Future<bool> deleteUsuario(int id) async {
    return await _dataSource.deleteUsuario(id);
  }
}
