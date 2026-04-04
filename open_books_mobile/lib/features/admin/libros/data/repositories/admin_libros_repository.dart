import 'package:flutter/foundation.dart';

import '../datasources/admin_libros_datasource.dart';
import '../models/admin_libro.dart';

class AdminLibrosRepository {
  final AdminLibrosDataSource _dataSource;

  AdminLibrosRepository(this._dataSource);

  void setToken(String token) {
    _dataSource.setToken(token);
  }

  Future<PagedLibros> getLibros({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchQuery,
  }) async {
    return await _dataSource.getLibros(
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchQuery: searchQuery,
    );
  }

  Future<AdminLibro?> getLibro(int id) async {
    return await _dataSource.getLibro(id);
  }

  Future<AdminLibro?> createLibro(CreateLibroRequest request) async {
    return await _dataSource.createLibro(request);
  }

  Future<AdminLibro?> updateLibro(int id, UpdateLibroRequest request) async {
    return await _dataSource.updateLibro(id, request);
  }

  Future<bool> deleteLibro(int id) async {
    return await _dataSource.deleteLibro(id);
  }
}