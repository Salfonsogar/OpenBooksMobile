import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../domain/entities/libro_biblioteca_entity.dart';
import '../../domain/repositories/i_biblioteca_repository.dart';
import '../datasources/biblioteca_datasource.dart';
import '../../../../shared/services/local_database.dart';
import '../../../../shared/services/models/biblioteca_local_model.dart';
import '../../../../shared/services/models/sync_queue_model.dart';
import '../../../../shared/services/network_info.dart';
import '../../../../features/libros/data/models/libro.dart';
import '../../../../features/libros/data/repositories/libros_repository.dart';
import '../../../../shared/core/errors/failures.dart';
import '../../../../shared/core/utils/either.dart';
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
  Future<Result<List<LibroBibliotecaEntity>>> getBiblioteca(int usuarioId) async {
    try {
      final localData = await localDatabase.bibliotecaLocalDataSource
          .getByUsuarioId(usuarioId);
      final entities = BibliotecaMapper.fromLocalModelList(localData);
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al obtener biblioteca local: $e'));
    }
  }

  @override
  Future<Result<void>> addLibro(int usuarioId, int libroId) async {
    try {
      final isConnected = await networkInfo.isConnected;

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

      final syncOperation = SyncQueueModel(
        operation: SyncQueueModel.operationAddBiblioteca,
        entityType: SyncQueueModel.entityTypeBiblioteca,
        entityId: libroId,
        payload: jsonEncode({
          'usuarioId': usuarioId,
          'libroId': libroId,
        }),
        priority: SyncQueueModel.priorityNormal,
        status: SyncQueueModel.statusPending,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await localDatabase.syncQueueDataSource.insert(syncOperation);

      if (isConnected) {
        final syncResult = await syncAddBiblioteca(usuarioId, libroId);
        if (syncResult.isLeft()) {
          return syncResult;
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al agregar libro: $e'));
    }
  }

  @override
  Future<Result<void>> removeLibro(int usuarioId, int libroId) async {
    try {
      await localDatabase.bibliotecaLocalDataSource
          .deleteByLibroId(libroId, usuarioId);

      final syncOperation = SyncQueueModel(
        operation: SyncQueueModel.operationRemoveBiblioteca,
        entityType: SyncQueueModel.entityTypeBiblioteca,
        entityId: libroId,
        payload: jsonEncode({
          'usuarioId': usuarioId,
          'libroId': libroId,
        }),
        priority: SyncQueueModel.priorityHigh,
        status: SyncQueueModel.statusPending,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await localDatabase.syncQueueDataSource.insert(syncOperation);

      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        final syncResult = await syncRemoveBiblioteca(usuarioId, libroId);
        if (syncResult.isLeft()) {
          return syncResult;
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al remover libro: $e'));
    }
  }

  @override
  Future<Result<void>> syncNow() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(NetworkFailure(message: 'No hay conexión a internet'));
      }

      final pendingOps = await localDatabase.syncQueueDataSource
          .getPendingByEntityType(SyncQueueModel.entityTypeBiblioteca);

      for (final op in pendingOps) {
        await localDatabase.syncQueueDataSource.markAsProcessing(op.id!);

        final payload = jsonDecode(op.payload ?? '{}');
        final usuarioId = payload['usuarioId'] as int;
        final libroId = payload['libroId'] as int;

        Result<void> result;
        if (op.operation == SyncQueueModel.operationAddBiblioteca) {
          result = await syncAddBiblioteca(usuarioId, libroId);
        } else if (op.operation == SyncQueueModel.operationRemoveBiblioteca) {
          result = await syncRemoveBiblioteca(usuarioId, libroId);
        } else {
          result = const Right(null);
        }

        if (result.isRight()) {
          await localDatabase.syncQueueDataSource.markAsSynced(op.id!);
        } else {
          final failure = (result as Left).value;
          await localDatabase.syncQueueDataSource.markAsFailed(
            op.id!,
            failure.message,
          );
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error en sincronización: $e'));
    }
  }

  Future<Result<void>> syncAddBiblioteca(int usuarioId, int libroId) async {
    try {
      await remoteDataSource.agregarLibro(usuarioId, libroId);
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('409')) {
        return const Right(null);
      }
      return Left(ServerFailure(message: 'Error al sincronizar: $e'));
    }
  }

  Future<Result<void>> syncRemoveBiblioteca(int usuarioId, int libroId) async {
    try {
      await remoteDataSource.quitarLibro(usuarioId, libroId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al sincronizar: $e'));
    }
  }

  @override
  Future<Result<void>> syncFromRemote(int usuarioId) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(NetworkFailure(message: 'No hay conexión a internet'));
      }

      final remoteLibros =
          await remoteDataSource.getLibrosBiblioteca(usuarioId);

      final existingLocal = await localDatabase.bibliotecaLocalDataSource
          .getByUsuarioId(usuarioId);
      for (final item in existingLocal) {
        await localDatabase.bibliotecaLocalDataSource.delete(item.id!);
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
          isDownloaded: false,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        await localDatabase.bibliotecaLocalDataSource.insert(localModel);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al sincronizar desde servidor: $e'));
    }
  }

  @override
  Future<Result<void>> addLibroFromRemote(int usuarioId, Libro libro) async {
    try {
      final existing = await localDatabase.bibliotecaLocalDataSource
          .getByLibroId(libro.id, usuarioId);
      
      if (existing != null) return const Right(null);

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
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al agregar libro remoto: $e'));
    }
  }
}
