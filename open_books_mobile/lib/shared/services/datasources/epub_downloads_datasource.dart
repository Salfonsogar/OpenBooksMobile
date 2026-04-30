import 'package:sqflite/sqflite.dart';

import 'package:open_books_mobile/shared/services/models/epub_download_model.dart';

class EpubDownloadsDataSource {
  final Database _db;

  EpubDownloadsDataSource(this._db);

  static const String _tableName = 'epub_downloads';

  Future<List<EpubDownloadModel>> getAll() async {
    final maps = await _db.query(
      _tableName,
      orderBy: 'downloaded_at DESC',
    );
    return maps.map((map) => EpubDownloadModel.fromMap(map)).toList();
  }

  Future<EpubDownloadModel?> getById(int id) async {
    final maps = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return EpubDownloadModel.fromMap(maps.first);
  }

  Future<EpubDownloadModel?> getByLibroId(int libroId) async {
    final maps = await _db.query(
      _tableName,
      where: 'libro_id = ?',
      whereArgs: [libroId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return EpubDownloadModel.fromMap(maps.first);
  }

  Future<int> insert(EpubDownloadModel download) async {
    return await _db.insert(
      _tableName,
      download.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(EpubDownloadModel download) async {
    await _db.update(
      _tableName,
      download.toMap(),
      where: 'id = ?',
      whereArgs: [download.id],
    );
  }

  Future<void> delete(int id) async {
    await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByLibroId(int libroId) async {
    await _db.delete(
      _tableName,
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
  }

  Future<void> updateStatus(int libroId, String status, {String? errorMessage}) async {
    await _db.update(
      _tableName,
      {
        'status': status,
        'error_message': errorMessage,
      },
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
  }

  Future<void> markAsCompleted(int libroId, int totalSize) async {
    await _db.update(
      _tableName,
      {
        'status': EpubDownloadModel.statusCompleted,
        'total_size': totalSize,
        'downloaded_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
  }

  Future<List<EpubDownloadModel>> getCompleted() async {
    final maps = await _db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [EpubDownloadModel.statusCompleted],
    );
    return maps.map((map) => EpubDownloadModel.fromMap(map)).toList();
  }

  Future<List<EpubDownloadModel>> getPendingOrDownloading() async {
    final maps = await _db.query(
      _tableName,
      where: 'status IN (?, ?)',
      whereArgs: [
        EpubDownloadModel.statusPending,
        EpubDownloadModel.statusDownloading,
      ],
    );
    return maps.map((map) => EpubDownloadModel.fromMap(map)).toList();
  }

  Future<bool> isDownloaded(int libroId) async {
    final download = await getByLibroId(libroId);
    return download != null && download.status == EpubDownloadModel.statusCompleted;
  }

  Future<int> getTotalSize() async {
    final result = await _db.rawQuery(
      'SELECT SUM(total_size) as total FROM $_tableName WHERE status = ?',
      [EpubDownloadModel.statusCompleted],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Set<int>> getAllDownloadedIds() async {
    final maps = await _db.query(
      _tableName,
      columns: ['libro_id'],
      where: 'status = ?',
      whereArgs: [EpubDownloadModel.statusCompleted],
    );
    return maps.map((map) => map['libro_id'] as int).toSet();
  }
}
