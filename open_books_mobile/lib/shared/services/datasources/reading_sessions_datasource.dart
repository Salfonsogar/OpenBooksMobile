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

  Future<int> getTotalPagesInRange(int fromTimestamp) async {
    final result = await _db.rawQuery(
      'SELECT SUM(pages_read_in_session) as total FROM $_tableName WHERE session_timestamp >= ?',
      [fromTimestamp],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> getActiveUsersCount(int fromTimestamp) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(DISTINCT usuario_id) as total FROM $_tableName WHERE session_timestamp >= ?',
      [fromTimestamp],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<List<TopLibroResult>> getTopLibros() async {
    final result = await _db.rawQuery('''
      SELECT 
        rs.libro_id,
        bl.titulo,
        COUNT(*) as total_lecturas,
        SUM(rs.pages_read_in_session) as paginas_leidas
      FROM $_tableName rs
      LEFT JOIN biblioteca_local bl ON rs.libro_id = bl.libro_id
      GROUP BY rs.libro_id
      ORDER BY paginas_leidas DESC
      LIMIT 10
    ''');

    return result.map((row) => TopLibroResult(
      libroId: row['libro_id'] as int? ?? 0,
      titulo: (row['titulo'] as String?)?.isNotEmpty == true
          ? row['titulo'] as String
          : 'Libro ${row['libro_id']}',
      totalLecturas: (row['total_lecturas'] as int?) ?? 0,
      paginasLeidas: (row['paginas_leidas'] as int?) ?? 0,
    )).toList();
  }

  Future<List<EvolucionLecturaResult>> getEvolucionLectura(
    int fromTimestamp,
    int toTimestamp,
  ) async {
    final result = await _db.rawQuery('''
      SELECT 
        date(session_timestamp / 1000, 'unixepoch') as fecha,
        SUM(pages_read_in_session) as paginas_leidas,
        COUNT(*) as sesiones
      FROM $_tableName
      WHERE session_timestamp >= ? AND session_timestamp <= ?
      GROUP BY fecha
      ORDER BY fecha ASC
    ''', [fromTimestamp, toTimestamp]);

    return result.map((row) => EvolucionLecturaResult(
      fecha: DateTime.tryParse(row['fecha'] as String? ?? '') ?? DateTime.now(),
      paginasLeidas: (row['paginas_leidas'] as int?) ?? 0,
      sesiones: (row['sesiones'] as int?) ?? 0,
    )).toList();
  }
}

class TopLibroResult {
  final int libroId;
  final String titulo;
  final int totalLecturas;
  final int paginasLeidas;

  TopLibroResult({
    required this.libroId,
    required this.titulo,
    required this.totalLecturas,
    required this.paginasLeidas,
  });
}

class EvolucionLecturaResult {
  final DateTime fecha;
  final int paginasLeidas;
  final int sesiones;

  EvolucionLecturaResult({
    required this.fecha,
    required this.paginasLeidas,
    required this.sesiones,
  });
}