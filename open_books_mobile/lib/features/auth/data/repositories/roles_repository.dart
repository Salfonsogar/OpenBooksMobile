import '../datasources/roles_datasource.dart';
import '../models/rol.dart';

class RolesRepository {
  final RolesDataSource _dataSource;

  RolesRepository(this._dataSource);

  Future<Rol?> getRol(int rolId) async {
    return await _dataSource.getRol(rolId);
  }

  Future<List<Rol>> getRoles() async {
    return await _dataSource.getRoles();
  }
}
