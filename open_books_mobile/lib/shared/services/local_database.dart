import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'datasources/biblioteca_local_datasource.dart';
import 'datasources/historial_local_datasource.dart';
import 'datasources/sync_queue_datasource.dart';
import 'datasources/epub_downloads_datasource.dart';
import 'datasources/reading_sessions_datasource.dart';

class LocalDatabase {
  static const String _databaseName = 'open_books.db';
  static const int _databaseVersion = 2;

  static const int _syncedRetentionDays = 7;
  static const int _maxRetryCount = 3;

  Database? _database;

  late BibliotecaLocalDataSource bibliotecaLocalDataSource;
  late HistorialLocalDataSource historialLocalDataSource;
  late SyncQueueDataSource syncQueueDataSource;
  late EpubDownloadsDataSource epubDownloadsDataSource;
  late ReadingSessionsDataSource readingSessionsDataSource;

  Future<void> init() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _initDataSources();
    await _cleanupSyncQueue();
  }

  void _initDataSources() {
    bibliotecaLocalDataSource = BibliotecaLocalDataSource(_database!);
    historialLocalDataSource = HistorialLocalDataSource(_database!);
    syncQueueDataSource = SyncQueueDataSource(_database!);
    epubDownloadsDataSource = EpubDownloadsDataSource(_database!);
    readingSessionsDataSource = ReadingSessionsDataSource(_database!);
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

    await db.execute('''
      CREATE TABLE reading_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        progress_id INTEGER NOT NULL,
        libro_id INTEGER NOT NULL,
        usuario_id INTEGER NOT NULL,
        pages_read_in_session INTEGER DEFAULT 0,
        session_timestamp INTEGER NOT NULL,
        notes TEXT,
        created_at INTEGER,
        
        UNIQUE(id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_reading_sessions_libro ON reading_sessions(libro_id, usuario_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_reading_sessions_timestamp ON reading_sessions(session_timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_biblioteca_sync_status ON biblioteca_local(sync_status)
    ''');

    await db.execute('''
      CREATE INDEX idx_biblioteca_last_read ON biblioteca_local(last_read_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, status)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE biblioteca_local ADD COLUMN last_read_at INTEGER');
      await db.execute('ALTER TABLE biblioteca_local ADD COLUMN reading_streak INTEGER');
      await db.execute('ALTER TABLE biblioteca_local ADD COLUMN sync_status TEXT');
      await db.execute('ALTER TABLE biblioteca_local ADD COLUMN local_version INTEGER');
      
      await db.execute('''
        CREATE TABLE reading_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          progress_id INTEGER NOT NULL,
          libro_id INTEGER NOT NULL,
          usuario_id INTEGER NOT NULL,
          pages_read_in_session INTEGER DEFAULT 0,
          session_timestamp INTEGER NOT NULL,
          notes TEXT,
          created_at INTEGER,
          
          UNIQUE(id)
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_reading_sessions_libro ON reading_sessions(libro_id, usuario_id)
      ''');

      await db.execute('''
        CREATE INDEX idx_reading_sessions_timestamp ON reading_sessions(session_timestamp)
      ''');
    }
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
