import 'dart:convert';

import '../../domain/entities/historial_entry_entity.dart';
import '../../domain/repositories/i_historial_repository.dart';
import '../datasources/historial_datasource.dart';
import '../../../../shared/services/local_database.dart';
import '../../../../shared/services/models/historial_local_model.dart';
import '../../../../shared/services/models/sync_queue_model.dart';
import '../../../../shared/services/network_info.dart';
import '../../../../features/libros/data/models/libro.dart';
import '../mappers/historial_mapper.dart';

class HistorialRepositoryImpl implements IHistorialRepository {
  final LocalDatabase localDatabase;
  final HistorialDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HistorialRepositoryImpl({
    required this.localDatabase,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<bool> get isConnected async {
    return networkInfo.isConnected;
  }

  @override
  Future<List<HistorialEntryEntity>> getHistorial(int usuarioId) async {
    final localData = await localDatabase.historialLocalDataSource
        .getByUsuarioId(usuarioId);
    return HistorialMapper.fromLocalModelList(localData);
  }

  @override
  Future<void> addToHistorial(int usuarioId, Libro libro) async {
    final localModel = HistorialMapper.fromLibroToLocalModel(libro, usuarioId);
    await localDatabase.historialLocalDataSource.insertOrUpdate(localModel);

    final syncOperation = SyncQueueModel(
      operation: SyncQueueModel.operationAddHistorial,
      entityType: SyncQueueModel.entityTypeHistorial,
      entityId: libro.id,
      payload: jsonEncode({
        'usuarioId': usuarioId,
        'libroId': libro.id,
      }),
      priority: SyncQueueModel.priorityLow,
      status: SyncQueueModel.statusPending,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await localDatabase.syncQueueDataSource.insert(syncOperation);
  }

  @override
  Future<void> syncNow() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    final pendingOps = await localDatabase.syncQueueDataSource
        .getPendingByEntityType(SyncQueueModel.entityTypeHistorial);

    for (final op in pendingOps) {
      try {
        await localDatabase.syncQueueDataSource.markAsProcessing(op.id!);

        final payload = jsonDecode(op.payload ?? '{}');
        final libroId = payload['libroId'] as int;

        await syncAddHistorial(libroId);

        await localDatabase.syncQueueDataSource.markAsSynced(op.id!);
      } catch (e) {
        await localDatabase.syncQueueDataSource.markAsFailed(
          op.id!,
          e.toString(),
        );
      }
    }
  }

  Future<void> syncAddHistorial(int libroId) async {
    // El historial en el backend no es persistente - solo se lee
    // Marcamos como synced sin hacer llamada a API
  }

  Future<void> syncFromRemote(int usuarioId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    try {
      final remoteLibros = await remoteDataSource.getHistorial();

      for (final libro in remoteLibros) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final localModel = HistorialLocalModel(
          libroId: libro.id,
          usuarioId: usuarioId,
          titulo: libro.titulo,
          autor: libro.autor,
          portadaBase64: libro.portadaBase64,
          ultimaLectura: now,
          status: 'synced',
          createdAt: now,
        );
        await localDatabase.historialLocalDataSource.insertOrUpdate(localModel);
      }
    } catch (e) {
      rethrow;
    }
  }
}
