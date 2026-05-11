import '../entities/historial_entry_entity.dart';
import '../../../libros/data/models/libro.dart';

abstract class IHistorialRepository {
  Future<List<HistorialEntryEntity>> getHistorial(String usuarioId);
  Future<void> addToHistorial(String usuarioId, Libro libro);
  Future<void> syncNow();
  Future<bool> get isConnected;
}
