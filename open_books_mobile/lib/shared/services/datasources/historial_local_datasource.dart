import 'package:sqflite/sqflite.dart';

import 'package:open_books_mobile/shared/services/models/historial_local_model.dart';

class HistorialLocalDataSource {
  final Database _db;

  HistorialLocalDataSource(this._db);

  static const String _tableName = 'historial_local';

  Future<List<HistorialLocalModel>> getAll() async {
    final maps = await _db.query(
      _tableName,
      orderBy: 'ultima_lectura DESC',
    );
    return maps.map((map) => HistorialLocalModel.fromMap(map)).toList();
  }

  Future<List<HistorialLocalModel>> getByUsuarioId(int usuarioId) async {
    final maps = await _db.query(
      _tableName,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'ultima_lectura DESC',
    );
    return maps.map((map) => HistorialLocalModel.fromMap(map)).toList();
  }

  Future<HistorialLocalModel?> getById(int id) async {
    final maps = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HistorialLocalModel.fromMap(maps.first);
  }

  Future<HistorialLocalModel?> getByLibroId(int libroId, int usuarioId) async {
    final maps = await _db.query(
      _tableName,
      where: 'libro_id = ? AND usuario_id = ?',
      whereArgs: [libroId, usuarioId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HistorialLocalModel.fromMap(maps.first);
  }

  Future<int> insert(HistorialLocalModel historial) async {
    return await _db.insert(
      _tableName,
      historial.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(HistorialLocalModel historial) async {
    await _db.update(
      _tableName,
      historial.toMap(),
      where: 'id = ?',
      whereArgs: [historial.id],
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

  Future<void> updateTimestamp(int id, int timestamp) async {
    await _db.update(
      _tableName,
      {
        'ultima_lectura': timestamp,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateStatus(int id, String status) async {
    await _db.update(
      _tableName,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertOrUpdate(HistorialLocalModel historial) async {
    final existing = await getByLibroId(historial.libroId, historial.usuarioId);
    if (existing != null) {
      await updateTimestamp(existing.id!, historial.ultimaLectura);
      if (historial.status != 'synced') {
        await updateStatus(existing.id!, historial.status);
      }
    } else {
      await insert(historial);
    }
  }

  Future<List<HistorialLocalModel>> getPending() async {
    final maps = await _db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: ['pending_add'],
    );
    return maps.map((map) => HistorialLocalModel.fromMap(map)).toList();
  }
}
