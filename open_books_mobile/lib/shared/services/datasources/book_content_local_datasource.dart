import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:open_books_mobile/shared/core/enums/download_status.dart';
import 'package:open_books_mobile/features/reader/data/models/epub_manifest.dart';

abstract class BookContentLocalDataSource {
  Future<void> saveManifest(int libroId, EpubManifest manifest);
  Future<void> saveResource(int libroId, String path, String content);
  Future<EpubManifest?> getManifest(int libroId);
  Future<String?> getResource(int libroId, String path);
  Future<bool> hasContent(int libroId);
  Future<int?> getVersion(int libroId);
  Future<List<int>> getBooksToSync();
  Future<void> deleteContent(int libroId);
  Future<void> updateVersion(int libroId, int version);
  Future<void> updateDownloadStatus(int libroId, DownloadStatus status);
  Future<DownloadStatus> getDownloadStatus(int libroId);
}

class BookContentLocalDataSourceImpl implements BookContentLocalDataSource {
  final Database _db;

  BookContentLocalDataSourceImpl(this._db);

  @override
  Future<void> saveManifest(int libroId, EpubManifest manifest) async {
    await _db.insert(
      'book_content',
      {
        'libro_id': libroId,
        'manifest_json': jsonEncode(manifest.toJson()),
        'last_synced_at': DateTime.now().millisecondsSinceEpoch,
        'version': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveResource(int libroId, String path, String content) async {
    await _db.insert(
      'book_resources',
      {
        'libro_id': libroId,
        'path': path,
        'content': content,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<EpubManifest?> getManifest(int libroId) async {
    final result = await _db.query(
      'book_content',
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
    if (result.isEmpty) return null;
    return EpubManifest.fromJson(
      jsonDecode(result.first['manifest_json'] as String) as Map<String, dynamic>,
    );
  }

  @override
  Future<String?> getResource(int libroId, String path) async {
    final result = await _db.query(
      'book_resources',
      where: 'libro_id = ? AND path = ?',
      whereArgs: [libroId, path],
    );
    if (result.isEmpty) return null;
    return result.first['content'] as String;
  }

  @override
  Future<bool> hasContent(int libroId) async {
    final result = await _db.query(
      'book_resources',
      where: 'libro_id = ?',
      whereArgs: [libroId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  @override
  Future<int?> getVersion(int libroId) async {
    final result = await _db.query(
      'book_content',
      columns: ['version'],
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
    if (result.isEmpty) return null;
    return result.first['version'] as int;
  }

  @override
  Future<List<int>> getBooksToSync() async {
    final result = await _db.rawQuery('''
      SELECT b.libro_id
      FROM biblioteca_local b
      LEFT JOIN book_content c ON b.libro_id = c.libro_id
      WHERE b.is_downloaded = 1
        AND (
          c.version IS NULL
          OR b.local_version > c.version
          OR b.download_status = 'failed'
        )
    ''');
    return result.map((r) => r['libro_id'] as int).toList();
  }

  @override
  Future<void> deleteContent(int libroId) async {
    await _db.delete('book_resources', where: 'libro_id = ?', whereArgs: [libroId]);
    await _db.delete('book_content', where: 'libro_id = ?', whereArgs: [libroId]);
  }

  @override
  Future<void> updateVersion(int libroId, int version) async {
    await _db.update(
      'book_content',
      {'version': version},
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
  }

  @override
  Future<void> updateDownloadStatus(int libroId, DownloadStatus status) async {
    await _db.update(
      'biblioteca_local',
      {'download_status': status.value},
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
  }

  @override
  Future<DownloadStatus> getDownloadStatus(int libroId) async {
    final result = await _db.query(
      'biblioteca_local',
      columns: ['download_status'],
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
    if (result.isEmpty) return DownloadStatus.notDownloaded;
    final status = result.first['download_status'] as String?;
    return DownloadStatusX.fromString(status ?? 'not_downloaded');
  }
}