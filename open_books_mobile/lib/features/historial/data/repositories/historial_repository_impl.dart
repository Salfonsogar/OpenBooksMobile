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
  Future<List<HistorialEntryEntity>> getRemoto(int usuarioId) async {
    final remoteLibros = await remoteDataSource.getHistorial();
    return remoteLibros
        .map((libro) => HistorialEntryEntity(
              id: libro.id,
              libroId: libro.id,
              usuarioId: usuarioId,
              titulo: libro.titulo,
              autor: libro.autor,
              portadaBase64: libro.portadaBase64,
              ultimaLectura: DateTime.now(),
              status: 'synced',
              createdAt: DateTime.now(),
            ))
        .toList();
  }

  @override
  Future<List<HistorialEntryEntity>> getHistorial(int usuarioId) async {
    final localData = await localDatabase.historialLocalDataSource
        .getByUsuarioId(usuarioId);
    if (localData.isNotEmpty) {
      return HistorialMapper.fromLocalModelList(localData);
    }

    // Fallback offline: si historial_local aun no se ha poblado, derivar desde
    // biblioteca_local usando las marcas de ultima lectura.
    final bibliotecaLocal = await localDatabase.bibliotecaLocalDataSource
        .getByUsuarioId(usuarioId);

    final fallbackHistorial = bibliotecaLocal
        .where((libro) => (libro.lastReadAt ?? 0) > 0)
        .map(
          (libro) => HistorialEntryEntity(
            id: libro.id ?? 0,
            libroId: libro.libroId,
            usuarioId: libro.usuarioId,
            titulo: libro.titulo,
            autor: libro.autor,
            portadaBase64: libro.portadaBase64,
            ultimaLectura: DateTime.fromMillisecondsSinceEpoch(
              libro.lastReadAt!,
            ),
            status: 'pending_add',
            createdAt: DateTime.fromMillisecondsSinceEpoch(libro.createdAt),
          ),
        )
        .toList()
      ..sort((a, b) => b.ultimaLectura.compareTo(a.ultimaLectura));

    return fallbackHistorial;
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
