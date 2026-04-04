import '../../domain/entities/historial_entry_entity.dart';
import '../../../../shared/services/models/historial_local_model.dart';
import '../../../libros/data/models/libro.dart';

class HistorialMapper {
  static List<HistorialEntryEntity> fromLocalModelList(
      List<HistorialLocalModel> models) {
    return models.map(fromLocalModel).toList();
  }

  static HistorialEntryEntity fromLocalModel(HistorialLocalModel model) {
    return HistorialEntryEntity(
      id: model.id ?? 0,
      libroId: model.libroId,
      usuarioId: model.usuarioId,
      titulo: model.titulo,
      autor: model.autor,
      portadaBase64: model.portadaBase64,
      ultimaLectura: DateTime.fromMillisecondsSinceEpoch(model.ultimaLectura),
      status: model.status,
      createdAt: DateTime.fromMillisecondsSinceEpoch(model.createdAt),
    );
  }

  static HistorialLocalModel toLocalModel(
    HistorialEntryEntity entity,
  ) {
    return HistorialLocalModel(
      id: entity.id != 0 ? entity.id : null,
      libroId: entity.libroId,
      usuarioId: entity.usuarioId,
      titulo: entity.titulo,
      autor: entity.autor,
      portadaBase64: entity.portadaBase64,
      ultimaLectura: entity.ultimaLectura.millisecondsSinceEpoch,
      status: entity.status,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
    );
  }

  static HistorialLocalModel fromLibroToLocalModel(
    Libro libro,
    int usuarioId,
  ) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return HistorialLocalModel(
      libroId: libro.id,
      usuarioId: usuarioId,
      titulo: libro.titulo,
      autor: libro.autor,
      portadaBase64: libro.portadaBase64,
      ultimaLectura: now,
      status: 'pending_add',
      createdAt: now,
    );
  }

  static List<HistorialEntryEntity> fromApiModelList(List<Libro> libros) {
    return libros.map(fromApiModel).toList();
  }

  static HistorialEntryEntity fromApiModel(Libro libro) {
    final now = DateTime.now();
    return HistorialEntryEntity(
      id: 0,
      libroId: libro.id,
      usuarioId: 0,
      titulo: libro.titulo,
      autor: libro.autor,
      portadaBase64: libro.portadaBase64,
      ultimaLectura: now,
      status: 'synced',
      createdAt: now,
    );
  }
}
