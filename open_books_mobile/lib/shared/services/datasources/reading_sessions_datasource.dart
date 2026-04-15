import 'package:sqflite/sqflite.dart';

import 'package:open_books_mobile/shared/services/models/reading_session_model.dart';

class ReadingSessionsDataSource {
  final Database _db;

  ReadingSessionsDataSource(this._db);

  static const String _tableName = 'reading_sessions';

  Future<List<ReadingSessionModel>> getAll() async {
    final maps = await _db.query(
      _tableName,
      orderBy: 'session_timestamp DESC',
    );
    return maps.map((map) => ReadingSessionModel.fromMap(map)).toList();
  }

  Future<List<ReadingSessionModel>> getByLibroId(int libroId, int usuarioId) async {
    final maps = await _db.query(
      _tableName,
      where: 'libro_id = ? AND usuario_id = ?',
      whereArgs: [libroId, usuarioId],
      orderBy: 'session_timestamp DESC',
    );
    return maps.map((map) => ReadingSessionModel.fromMap(map)).toList();
  }

  Future<List<ReadingSessionModel>> getByProgressId(int progressId) async {
    final maps = await _db.query(
      _tableName,
      where: 'progress_id = ?',
      whereArgs: [progressId],
      orderBy: 'session_timestamp DESC',
    );
    return maps.map((map) => ReadingSessionModel.fromMap(map)).toList();
  }

  Future<ReadingSessionModel?> getById(int id) async {
    final maps = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ReadingSessionModel.fromMap(maps.first);
  }

  Future<int> insert(ReadingSessionModel session) async {
    return await _db.insert(
      _tableName,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(ReadingSessionModel session) async {
    await _db.update(
      _tableName,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> delete(int id) async {
    await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByLibroId(int libroId, int usuarioId) async {
    await _db.delete(
      _tableName,
      where: 'libro_id = ? AND usuario_id = ?',
      whereArgs: [libroId, usuarioId],
    );
  }

  Future<int> getTotalPagesRead(int libroId, int usuarioId) async {
    final result = await _db.rawQuery(
      'SELECT SUM(pages_read_in_session) as total FROM $_tableName WHERE libro_id = ? AND usuario_id = ?',
      [libroId, usuarioId],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<List<ReadingSessionModel>> getRecentSessions(int usuarioId, {int limit = 10}) async {
    final maps = await _db.query(
      _tableName,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'session_timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => ReadingSessionModel.fromMap(map)).toList();
  }
}