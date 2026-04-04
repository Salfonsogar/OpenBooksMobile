import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'datasources/biblioteca_local_datasource.dart';
import 'datasources/historial_local_datasource.dart';
import 'datasources/sync_queue_datasource.dart';
import 'datasources/epub_downloads_datasource.dart';

class LocalDatabase {
  static const String _databaseName = 'open_books.db';
  static const int _databaseVersion = 1;

  static const int _syncedRetentionDays = 7;
  static const int _maxRetryCount = 3;

  Database? _database;

  late BibliotecaLocalDataSource bibliotecaLocalDataSource;
  late HistorialLocalDataSource historialLocalDataSource;
  late SyncQueueDataSource syncQueueDataSource;
  late EpubDownloadsDataSource epubDownloadsDataSource;

  Future<void> init() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );

    _initDataSources();
    await _cleanupSyncQueue();
  }

  void _initDataSources() {
    bibliotecaLocalDataSource = BibliotecaLocalDataSource(_database!);
    historialLocalDataSource = HistorialLocalDataSource(_database!);
    syncQueueDataSource = SyncQueueDataSource(_database!);
    epubDownloadsDataSource = EpubDownloadsDataSource(_database!);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE biblioteca_local (
        id INTEGER PRIMARY KEY,
        libro_id INTEGER NOT NULL,
        usuario_id INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        autor TEXT,
        descripcion TEXT,
        portada_base64 TEXT,
        categorias TEXT,
        progreso REAL DEFAULT 0.0,
        is_downloaded INTEGER DEFAULT 0,
        page INTEGER,
        updated_at INTEGER,
        created_at INTEGER,
        
        UNIQUE(libro_id, usuario_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE historial_local (
        id INTEGER PRIMARY KEY,
        libro_id INTEGER NOT NULL,
        usuario_id INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        autor TEXT,
        portada_base64 TEXT,
        ultima_lectura INTEGER,
        status TEXT DEFAULT 'synced',
        created_at INTEGER,
        
        UNIQUE(libro_id, usuario_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id INTEGER NOT NULL,
        payload TEXT,
        priority INTEGER DEFAULT 0,
        status TEXT DEFAULT 'pending',
        retry_count INTEGER DEFAULT 0,
        error_message TEXT,
        created_at INTEGER,
        processed_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE epub_downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        libro_id INTEGER NOT NULL UNIQUE,
        download_path TEXT NOT NULL,
        manifest_json TEXT,
        total_size INTEGER,
        downloaded_at INTEGER,
        status TEXT DEFAULT 'pending',
        error_message TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_biblioteca_usuario ON biblioteca_local(usuario_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_historial_usuario ON historial_local(usuario_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_queue_status ON sync_queue(status)
    ''');

    await db.execute('''
      CREATE INDEX idx_epub_downloads_libro ON epub_downloads(libro_id)
    ''');
  }

  Future<void> _cleanupSyncQueue() async {
    if (_database == null) return;

    final cutoffSynced = DateTime.now()
        .subtract(const Duration(days: _syncedRetentionDays))
        .millisecondsSinceEpoch;

    await syncQueueDataSource.deleteSyncedOlderThan(cutoffSynced);
    await syncQueueDataSource.deleteFailedMaxRetries(_maxRetryCount);
  }

  Future<void> runCleanup() async {
    await _cleanupSyncQueue();
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  bool get isInitialized => _database != null;
}
