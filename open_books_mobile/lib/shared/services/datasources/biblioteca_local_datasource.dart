import 'package:sqflite/sqflite.dart';

import 'package:open_books_mobile/shared/services/models/biblioteca_local_model.dart';

class BibliotecaLocalDataSource {
  final Database _db;

  BibliotecaLocalDataSource(this._db);

  static const String _tableName = 'biblioteca_local';

  Future<List<BibliotecaLocalModel>> getAll() async {
    final maps = await _db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => BibliotecaLocalModel.fromMap(map)).toList();
  }

  Future<List<BibliotecaLocalModel>> getByUsuarioId(int usuarioId) async {
    final maps = await _db.query(
      _tableName,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => BibliotecaLocalModel.fromMap(map)).toList();
  }

  Future<BibliotecaLocalModel?> getById(int id) async {
    final maps = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BibliotecaLocalModel.fromMap(maps.first);
  }

  Future<BibliotecaLocalModel?> getByLibroId(int libroId, int usuarioId) async {
    final maps = await _db.query(
      _tableName,
      where: 'libro_id = ? AND usuario_id = ?',
      whereArgs: [libroId, usuarioId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BibliotecaLocalModel.fromMap(maps.first);
  }

  Future<int> insert(BibliotecaLocalModel libro) async {
    return await _db.insert(
      _tableName,
      libro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(BibliotecaLocalModel libro) async {
    await _db.update(
      _tableName,
      libro.toMap(),
      where: 'id = ?',
      whereArgs: [libro.id],
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

  Future<void> updateProgreso(int id, double progreso) async {
    await _db.update(
      _tableName,
      {
        'progreso': progreso,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePage(int id, int page) async {
    await _db.update(
      _tableName,
      {
        'page': page,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDownloadStatus(int id, bool isDownloaded) async {
    await _db.update(
      _tableName,
      {
        'is_downloaded': isDownloaded ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BibliotecaLocalModel>> getDownloaded() async {
    final maps = await _db.query(
      _tableName,
      where: 'is_downloaded = ?',
      whereArgs: [1],
    );
    return maps.map((map) => BibliotecaLocalModel.fromMap(map)).toList();
  }
}
