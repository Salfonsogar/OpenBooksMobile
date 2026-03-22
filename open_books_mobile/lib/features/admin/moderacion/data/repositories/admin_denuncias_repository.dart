import '../datasources/admin_denuncias_datasource.dart';
import '../models/admin_denuncia.dart';

class AdminDenunciasRepository {
  final AdminDenunciasDataSource _dataSource;

  AdminDenunciasRepository(this._dataSource);

  void setToken(String token) {
    _dataSource.setToken(token);
  }

  Future<PagedDenuncias> getDenuncias({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return await _dataSource.getDenuncias(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<AdminDenuncia?> getDenuncia(int id) async {
    return await _dataSource.getDenuncia(id);
  }

  Future<bool> deleteDenuncia(int id) async {
    return await _dataSource.deleteDenuncia(id);
  }
}
