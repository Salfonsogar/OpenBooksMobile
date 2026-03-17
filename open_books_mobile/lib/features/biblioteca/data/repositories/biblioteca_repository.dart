import '../datasources/biblioteca_datasource.dart';
import '../../../libros/data/models/libro.dart';

class BibliotecaRepository {
  final BibliotecaDataSource _dataSource;

  BibliotecaRepository(this._dataSource);

  Future<List<Libro>> getLibrosBiblioteca(int usuarioId) {
    return _dataSource.getLibrosBiblioteca(usuarioId);
  }

  Future<void> agregarLibro(int usuarioId, int libroId) {
    return _dataSource.agregarLibro(usuarioId, libroId);
  }

  Future<void> quitarLibro(int usuarioId, int libroId) {
    return _dataSource.quitarLibro(usuarioId, libroId);
  }
}
