import 'package:sqflite/sqflite.dart';

import 'package:open_books_mobile/shared/services/models/sync_queue_model.dart';

class SyncQueueDataSource {
  final Database _db;

  SyncQueueDataSource(this._db);

  static const String _tableName = 'sync_queue';

  Future<List<SyncQueueModel>> getAll() async {
    final maps = await _db.query(
      _tableName,
      orderBy: 'priority DESC, created_at ASC',
    );
    return maps.map((map) => SyncQueueModel.fromMap(map)).toList();
  }

  Future<List<SyncQueueModel>> getPending() async {
    final maps = await _db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [SyncQueueModel.statusPending],
      orderBy: 'priority DESC, created_at ASC',
    );
    return maps.map((map) => SyncQueueModel.fromMap(map)).toList();
  }

  Future<List<SyncQueueModel>> getPendingByEntityType(String entityType) async {
    final maps = await _db.query(
      _tableName,
      where: 'status = ? AND entity_type = ?',
      whereArgs: [SyncQueueModel.statusPending, entityType],
      orderBy: 'priority DESC, created_at ASC',
    );
    return maps.map((map) => SyncQueueModel.fromMap(map)).toList();
  }

  Future<SyncQueueModel?> getById(int id) async {
    final maps = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SyncQueueModel.fromMap(maps.first);
  }

  Future<int> insert(SyncQueueModel operation) async {
    return await _db.insert(
      _tableName,
      operation.toMap(),
    );
  }

  Future<void> update(SyncQueueModel operation) async {
    await _db.update(
      _tableName,
      operation.toMap(),
      where: 'id = ?',
      whereArgs: [operation.id],
    );
  }

  Future<void> delete(int id) async {
    await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAsProcessing(int id) async {
    await _db.update(
      _tableName,
      {'status': SyncQueueModel.statusProcessing},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAsSynced(int id) async {
    await _db.update(
      _tableName,
      {
        'status': SyncQueueModel.statusSynced,
        'processed_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAsFailed(int id, String errorMessage) async {
    await _db.update(
      _tableName,
      {
        'status': SyncQueueModel.statusFailed,
        'error_message': errorMessage,
        'retry_count': await _getRetryCount(id) + 1,
        'processed_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> _getRetryCount(int id) async {
    final maps = await _db.query(
      _tableName,
      columns: ['retry_count'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return 0;
    return maps.first['retry_count'] as int? ?? 0;
  }

  Future<void> deleteSyncedOlderThan(int cutoffTimestamp) async {
    await _db.delete(
      _tableName,
      where: 'status = ? AND processed_at < ?',
      whereArgs: [SyncQueueModel.statusSynced, cutoffTimestamp],
    );
  }

  Future<void> deleteFailedMaxRetries(int maxRetries) async {
    await _db.delete(
      _tableName,
      where: 'status = ? AND retry_count >= ?',
      whereArgs: [SyncQueueModel.statusFailed, maxRetries],
    );
  }

  Future<void> resetFailedToPending(int id) async {
    await _db.update(
      _tableName,
      {
        'status': SyncQueueModel.statusPending,
        'error_message': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countPending() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE status = ?',
      [SyncQueueModel.statusPending],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countPendingByEntityType(String entityType) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE status = ? AND entity_type = ?',
      [SyncQueueModel.statusPending, entityType],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
