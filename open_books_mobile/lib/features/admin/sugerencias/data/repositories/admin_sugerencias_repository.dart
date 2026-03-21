import '../datasources/admin_sugerencias_datasource.dart';
import '../models/admin_sugerencia.dart';

class AdminSugerenciasRepository {
  final AdminSugerenciasDataSource _dataSource;

  AdminSugerenciasRepository(this._dataSource);

  void setToken(String token) {
    _dataSource.setToken(token);
  }

  Future<PagedSugerencias> getSugerencias({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return await _dataSource.getSugerencias(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<AdminSugerencia?> getSugerencia(int id) async {
    return await _dataSource.getSugerencia(id);
  }

  Future<bool> deleteSugerencia(int id) async {
    return await _dataSource.deleteSugerencia(id);
  }
}
