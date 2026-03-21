import '../datasources/admin_categorias_datasource.dart';
import '../models/admin_categoria.dart';

class AdminCategoriasRepository {
  final AdminCategoriasDataSource _dataSource;

  AdminCategoriasRepository(this._dataSource);

  void setToken(String token) {
    _dataSource.setToken(token);
  }

  Future<PagedCategorias> getCategorias({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    return await _dataSource.getCategorias(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<AdminCategoria?> getCategoria(int id) async {
    return await _dataSource.getCategoria(id);
  }

  Future<AdminCategoria?> createCategoria(CreateCategoriaRequest request) async {
    return await _dataSource.createCategoria(request);
  }

  Future<AdminCategoria?> updateCategoria(int id, UpdateCategoriaRequest request) async {
    return await _dataSource.updateCategoria(id, request);
  }

  Future<bool> deleteCategoria(int id) async {
    return await _dataSource.deleteCategoria(id);
  }
}
