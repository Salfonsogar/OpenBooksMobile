import 'dart:convert';

import '../../domain/entities/libro_biblioteca_entity.dart';
import '../../domain/repositories/i_biblioteca_repository.dart';
import '../datasources/biblioteca_datasource.dart';
import '../../../../shared/services/local_database.dart';
import '../../../../shared/services/models/biblioteca_local_model.dart';
import '../../../../shared/services/models/sync_queue_model.dart';
import '../../../../shared/services/network_info.dart';
import '../../../../features/libros/data/models/libro.dart';
import '../../../../features/libros/data/repositories/libros_repository.dart';
import '../mappers/biblioteca_mapper.dart';

class BibliotecaRepositoryImpl implements IBibliotecaRepository {
  final LocalDatabase localDatabase;
  final BibliotecaDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final LibrosRepository librosRepository;

  BibliotecaRepositoryImpl({
    required this.localDatabase,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.librosRepository,
  });

  @override
  Future<bool> get isConnected async {
    return networkInfo.isConnected;
  }

  @override
  Future<List<LibroBibliotecaEntity>> getRemoto(int usuarioId) async {
    final remoteLibros = await remoteDataSource.getLibrosBiblioteca(usuarioId);
    return remoteLibros
        .map((libro) => LibroBibliotecaEntity(
              id: libro.id,
              libroId: libro.id,
              usuarioId: usuarioId,
              titulo: libro.titulo,
              autor: libro.autor,
              descripcion: libro.descripcion,
              portadaBase64: libro.portadaBase64,
              categorias: libro.categorias,
              progreso: libro.progreso,
              isDownloaded: false,
              syncStatus: 'synced',
            ))
        .toList();
  }

  @override
  Future<List<LibroBibliotecaEntity>> getBiblioteca(int usuarioId) async {
    final localData = await localDatabase.bibliotecaLocalDataSource.getByUsuarioId(usuarioId);
    return BibliotecaMapper.fromLocalModelList(localData);
  }

  @override
  Future<LibroBibliotecaEntity> addLibro(int usuarioId, int libroId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('Se requiere conexión para agregar un libro');
    }

    await syncAddBiblioteca(usuarioId, libroId);

    final libroDetalle = await librosRepository.getLibroDetalle(libroId);
    final localModel = BibliotecaLocalModel(
      libroId: libroDetalle.id,
      usuarioId: usuarioId,
      titulo: libroDetalle.titulo,
      autor: libroDetalle.autor,
      descripcion: libroDetalle.descripcion,
      portadaBase64: libroDetalle.portadaBase64,
      categorias: jsonEncode(libroDetalle.categorias),
      progreso: 0.0,
      isDownloaded: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await localDatabase.bibliotecaLocalDataSource.insert(localModel);

    return LibroBibliotecaEntity(
      id: libroDetalle.id,
      libroId: libroDetalle.id,
      usuarioId: usuarioId,
      titulo: libroDetalle.titulo,
      autor: libroDetalle.autor,
      descripcion: libroDetalle.descripcion,
      portadaBase64: libroDetalle.portadaBase64,
      categorias: libroDetalle.categorias,
      progreso: 0.0,
      isDownloaded: false,
      syncStatus: 'synced',
    );
  }

  @override
  Future<void> removeLibro(int usuarioId, int libroId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('Se requiere conexión para quitar un libro');
    }

    await localDatabase.bibliotecaLocalDataSource
        .deleteByLibroId(libroId, usuarioId);

    await syncRemoveBiblioteca(usuarioId, libroId);
  }

  @override
  Future<void> syncNow() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    final pendingOps = await localDatabase.syncQueueDataSource
        .getPendingByEntityType(SyncQueueModel.entityTypeBiblioteca);

    for (final op in pendingOps) {
      try {
        await localDatabase.syncQueueDataSource.markAsProcessing(op.id!);

        final payload = jsonDecode(op.payload ?? '{}');
        final usuarioId = payload['usuarioId'] as int;
        final libroId = payload['libroId'] as int;

        if (op.operation == SyncQueueModel.operationAddBiblioteca) {
          await syncAddBiblioteca(usuarioId, libroId);
        } else if (op.operation == SyncQueueModel.operationRemoveBiblioteca) {
          await syncRemoveBiblioteca(usuarioId, libroId);
        }

        await localDatabase.syncQueueDataSource.markAsSynced(op.id!);
      } catch (e) {
        await localDatabase.syncQueueDataSource.markAsFailed(
          op.id!,
          e.toString(),
        );
      }
    }
  }

  Future<void> syncAddBiblioteca(int usuarioId, int libroId) async {
    try {
      await remoteDataSource.agregarLibro(usuarioId, libroId);
    } catch (e) {
      if (e.toString().contains('409')) {
        return;
      }
      rethrow;
    }
  }

  Future<void> syncRemoveBiblioteca(int usuarioId, int libroId) async {
    await remoteDataSource.quitarLibro(usuarioId, libroId);
  }

  @override
  Future<void> syncFromRemote(int usuarioId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    try {
      final remoteLibros =
          await remoteDataSource.getLibrosBiblioteca(usuarioId);

      final pendingOps = await localDatabase.syncQueueDataSource
          .getPendingByEntityType(SyncQueueModel.entityTypeBiblioteca);
      final pendingLibroIds = <int>{};
      for (final op in pendingOps) {
        if (op.operation == SyncQueueModel.operationAddBiblioteca) {
          final payload = jsonDecode(op.payload ?? '{}');
          pendingLibroIds.add(payload['libroId'] as int);
        }
      }

      final existingLocal = await localDatabase.bibliotecaLocalDataSource
          .getByUsuarioId(usuarioId);
      final existingIds = existingLocal.map((e) => e.libroId).toSet();
      final remoteIds = remoteLibros.map((e) => e.id).toSet();

      for (final item in existingLocal) {
        if (!remoteIds.contains(item.libroId) && !pendingLibroIds.contains(item.libroId)) {
          await localDatabase.bibliotecaLocalDataSource.delete(item.id!);
        }
      }

      for (final libro in remoteLibros) {
        final localModel = BibliotecaLocalModel(
          libroId: libro.id,
          usuarioId: usuarioId,
          titulo: libro.titulo,
          autor: libro.autor,
          descripcion: libro.descripcion,
          portadaBase64: libro.portadaBase64,
          categorias: jsonEncode(libro.categorias),
          progreso: libro.progreso,
          isDownloaded: existingIds.contains(libro.id),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        await localDatabase.bibliotecaLocalDataSource.insert(localModel);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addLibroFromRemote(int usuarioId, Libro libro) async {
    final existing = await localDatabase.bibliotecaLocalDataSource
        .getByLibroId(libro.id, usuarioId);
    
    if (existing != null) return;

    final localModel = BibliotecaLocalModel(
      libroId: libro.id,
      usuarioId: usuarioId,
      titulo: libro.titulo,
      autor: libro.autor,
      descripcion: libro.descripcion,
      portadaBase64: libro.portadaBase64,
      categorias: jsonEncode(libro.categorias),
      progreso: 0.0,
      isDownloaded: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await localDatabase.bibliotecaLocalDataSource.insert(localModel);
  }
}
