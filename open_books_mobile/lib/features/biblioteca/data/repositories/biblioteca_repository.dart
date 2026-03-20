import '../datasources/biblioteca_datasource.dart';
import '../models/libro_biblioteca.dart';

class BibliotecaRepository {
  final BibliotecaDataSource _dataSource;

  BibliotecaRepository(this._dataSource);

  Future<List<LibroBiblioteca>> getLibrosBiblioteca(int usuarioId) {
    return _dataSource.getLibrosBiblioteca(usuarioId);
  }

  Future<void> agregarLibro(int usuarioId, int libroId) {
    return _dataSource.agregarLibro(usuarioId, libroId);
  }

  Future<void> quitarLibro(int usuarioId, int libroId) {
    return _dataSource.quitarLibro(usuarioId, libroId);
  }

  Future<String> descargarLibro(int libroId) {
    return _dataSource.descargarLibro(libroId);
  }
}
