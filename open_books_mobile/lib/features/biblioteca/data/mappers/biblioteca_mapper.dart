import 'dart:convert';

import '../../domain/entities/libro_biblioteca_entity.dart';
import '../../../../shared/services/models/biblioteca_local_model.dart';
import '../models/libro_biblioteca.dart';

class BibliotecaMapper {
  static List<LibroBibliotecaEntity> fromLocalModelList(
      List<BibliotecaLocalModel> models) {
    return models.map(fromLocalModel).toList();
  }

  static LibroBibliotecaEntity fromLocalModel(BibliotecaLocalModel model) {
    List<String> categorias = [];
    if (model.categorias != null && model.categorias!.isNotEmpty) {
      try {
        categorias = List<String>.from(jsonDecode(model.categorias!));
      } catch (_) {
        categorias = [];
      }
    }

    return LibroBibliotecaEntity(
      id: model.id ?? 0,
      libroId: model.libroId,
      usuarioId: model.usuarioId,
      titulo: model.titulo,
      autor: model.autor ?? '',
      descripcion: model.descripcion ?? '',
      portadaBase64: model.portadaBase64,
      categorias: categorias,
      progreso: model.progreso,
      isDownloaded: model.isDownloaded,
      page: model.page,
      updatedAt: model.updatedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt!)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(model.createdAt),
    );
  }

  static BibliotecaLocalModel toLocalModel(
    LibroBibliotecaEntity entity,
  ) {
    return BibliotecaLocalModel(
      id: entity.id != 0 ? entity.id : null,
      libroId: entity.libroId,
      usuarioId: entity.usuarioId,
      titulo: entity.titulo,
      autor: entity.autor,
      descripcion: entity.descripcion,
      portadaBase64: entity.portadaBase64,
      categorias: jsonEncode(entity.categorias),
      progreso: entity.progreso,
      isDownloaded: entity.isDownloaded,
      page: entity.page,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch,
      createdAt: entity.createdAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  static List<LibroBibliotecaEntity> fromApiModelList(
      List<LibroBiblioteca> models) {
    return models.map(fromApiModel).toList();
  }

  static LibroBibliotecaEntity fromApiModel(LibroBiblioteca model) {
    return LibroBibliotecaEntity(
      id: model.id,
      libroId: model.id,
      usuarioId: 0,
      titulo: model.titulo,
      autor: model.autor,
      descripcion: model.descripcion,
      portadaBase64: model.portadaBase64,
      categorias: model.categorias,
      progreso: model.progreso,
      isDownloaded: false,
      page: null,
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  static BibliotecaLocalModel fromApiToLocalModel(
    LibroBiblioteca apiModel,
    int usuarioId,
  ) {
    return BibliotecaLocalModel(
      libroId: apiModel.id,
      usuarioId: usuarioId,
      titulo: apiModel.titulo,
      autor: apiModel.autor,
      descripcion: apiModel.descripcion,
      portadaBase64: apiModel.portadaBase64,
      categorias: jsonEncode(apiModel.categorias),
      progreso: apiModel.progreso,
      isDownloaded: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
