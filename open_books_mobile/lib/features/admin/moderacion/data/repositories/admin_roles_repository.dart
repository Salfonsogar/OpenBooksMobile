import '../datasources/admin_roles_datasource.dart';
import '../models/admin_rol.dart';

class AdminRolesRepository {
  final AdminRolesDataSource _dataSource;

  AdminRolesRepository(this._dataSource);

  void setToken(String token) {
    _dataSource.setToken(token);
  }

  Future<List<AdminRol>> getRoles() async {
    return await _dataSource.getRoles();
  }

  Future<AdminRol?> getRol(int id) async {
    return await _dataSource.getRol(id);
  }

  Future<AdminRol?> createRol(CreateRolRequest request) async {
    return await _dataSource.createRol(request);
  }

  Future<AdminRol?> updateRol(int id, UpdateRolRequest request) async {
    return await _dataSource.updateRol(id, request);
  }

  Future<bool> deleteRol(int id) async {
    return await _dataSource.deleteRol(id);
  }
}
