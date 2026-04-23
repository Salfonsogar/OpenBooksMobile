import '../entities/libro_biblioteca_entity.dart';
import '../../../libros/data/models/libro.dart';

abstract class IBibliotecaRepository {
  Future<List<LibroBibliotecaEntity>> getRemoto(int usuarioId);
  Future<List<LibroBibliotecaEntity>> getBiblioteca(int usuarioId);
  Future<LibroBibliotecaEntity> addLibro(int usuarioId, int libroId);
  Future<void> addLibroFromRemote(int usuarioId, Libro libro);
  Future<void> removeLibro(int usuarioId, int libroId);
  Future<void> syncNow();
  Future<void> syncFromRemote(int usuarioId);
  Future<bool> get isConnected;
}
