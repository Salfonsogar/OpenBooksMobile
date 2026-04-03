import '../entities/libro_biblioteca_entity.dart';
import '../../../libros/data/models/libro.dart';

enum SyncStatus { synced, pending, failed }

abstract class IBibliotecaRepository {
  Future<List<LibroBibliotecaEntity>> getBiblioteca(int usuarioId);
  Future<void> addLibro(int usuarioId, int libroId);
  Future<void> addLibroFromRemote(int usuarioId, Libro libro);
  Future<void> removeLibro(int usuarioId, int libroId);
  Future<void> syncNow();
  Future<bool> get isConnected;
}
