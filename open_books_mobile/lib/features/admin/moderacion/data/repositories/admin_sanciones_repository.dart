import '../datasources/admin_sanciones_datasource.dart';
import '../models/admin_sancion.dart';

class AdminSancionesRepository {
  final AdminSancionesDataSource _dataSource;

  AdminSancionesRepository(this._dataSource);

  void setToken(String token) {
    _dataSource.setToken(token);
  }

  Future<PagedSanciones> getSanciones({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return await _dataSource.getSanciones(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<AdminSancion?> getSancion(int id) async {
    return await _dataSource.getSancion(id);
  }

  Future<AdminSancion?> createSancion(CreateSancionRequest request) async {
    return await _dataSource.createSancion(request);
  }

  Future<AdminSancion?> updateSancion(int id, UpdateSancionRequest request) async {
    return await _dataSource.updateSancion(id, request);
  }

  Future<bool> deleteSancion(int id) async {
    return await _dataSource.deleteSancion(id);
  }
}
