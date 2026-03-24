import '../datasources/user_libros_datasource.dart';
import '../models/create_user_libro.dart';

class UserLibrosRepository {
  final UserLibrosDataSource _dataSource;

  UserLibrosRepository({UserLibrosDataSource? dataSource})
      : _dataSource = dataSource ?? UserLibrosDataSource();

  void setToken(String token) {
    _dataSource.setToken(token);
  }

  Future<bool> crearLibro(CreateUserLibroRequest request) async {
    return _dataSource.createLibro(request);
  }
}
