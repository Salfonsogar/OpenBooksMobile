# Offline Reading Mode - Plan por Fases

## Overview

| Fase | Descripción | Duración Estimada |
|------|-------------|------------------|
| 1 | DB + Modelos | 0.5 días |
| 2 | Local DataSource | 0.5 días |
| 3 | SyncService | 1.5 días |
| 4 | Repository | 0.5 días |
| 5 | UI + Cleanup | 0.5 días |

**Total: 3.5 días**

---

## Fase 1: Base de Datos + Modelos

### 1.1 Upgrade Database (v4 → v5)

Modificar `lib/shared/services/local_database.dart`:

```sql
-- Nueva tabla: book_content
CREATE TABLE book_content (
  libro_id INTEGER PRIMARY KEY,
  manifest_json TEXT NOT NULL,
  last_synced_at INTEGER NOT NULL,
  version INTEGER DEFAULT 1
);

-- Nueva tabla: book_resources
CREATE TABLE book_resources (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  libro_id INTEGER NOT NULL,
  path TEXT NOT NULL,
  content TEXT NOT NULL,
  FOREIGN KEY (libro_id) REFERENCES book_content(libro_id),
  UNIQUE(libro_id, path)
);
```

Modificar tabla `biblioteca_local` existente:

```sql
ALTER TABLE biblioteca_local ADD COLUMN download_status TEXT DEFAULT 'not_downloaded';
```

### 1.2 Modelos

**File: `lib/shared/services/models/book_content_model.dart`**

```dart
class BookContentModel {
  final int libroId;
  final String manifestJson;
  final DateTime lastSyncedAt;
  final int version;

  BookContentModel({
    required this.libroId,
    required this.manifestJson,
    required this.lastSyncedAt,
    required this.version,
  });

  factory BookContentModel.fromMap(Map<String, dynamic> map) => ...;
  Map<String, dynamic> toMap() => ...;
}
```

**File: `lib/shared/services/models/book_resource_model.dart`**

```dart
class BookResourceModel {
  final int? id;
  final int libroId;
  final String path;
  final String content;

  BookResourceModel({
    this.id,
    required this.libroId,
    required this.path,
    required this.content,
  });

  factory BookResourceModel.fromMap(Map<String, dynamic> map) => ...;
  Map<String, dynamic> toMap() => ...;
}
```

**File: `lib/shared/core/enums/download_status.dart`**

```dart
enum DownloadStatus {
  notDownloaded,
  downloading,
  completed,
  failed,
}

extension DownloadStatusX on DownloadStatus {
  String get value {
    switch (this) {
      case DownloadStatus.notDownloaded: return 'not_downloaded';
      case DownloadStatus.downloading: return 'downloading';
      case DownloadStatus.completed: return 'completed';
      case DownloadStatus.failed: return 'failed';
    }
  }

  static DownloadStatus fromString(String value) {
    switch (value) {
      case 'not_downloaded': return DownloadStatus.notDownloaded;
      case 'downloading': return DownloadStatus.downloading;
      case 'completed': return DownloadStatus.completed;
      case 'failed': return DownloadStatus.failed;
      default: return DownloadStatus.notDownloaded;
    }
  }
}
```

### 1.3 Tareas

- [ ] Modificar `local_database.dart`: upgrade v4→v5
- [ ] Agregar columna `download_status` a `biblioteca_local`
- [ ] Crear `book_content_model.dart`
- [ ] Crear `book_resource_model.dart`
- [ ] Crear `download_status.dart` enum

---

## Fase 2: Local DataSource

### 2.1 BookContentLocalDataSource

**File: `lib/shared/services/datasources/book_content_local_datasource.dart`**

```dart
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
```

**Implementation: `book_content_local_datasource_impl.dart`**

```dart
class BookContentLocalDataSourceImpl implements BookContentLocalDataSource {
  final LocalDatabaseService _db;

  @override
  Future<void> saveManifest(int libroId, EpubManifest manifest) async {
    final db = await _db.database;
    await db.insert('book_content', {
      'libro_id': libroId,
      'manifest_json': jsonEncode(manifest.toJson()),
      'last_synced_at': DateTime.now().millisecondsSinceEpoch,
      'version': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> saveResource(int libroId, String path, String content) async {
    final db = await _db.database;
    await db.insert('book_resources', {
      'libro_id': libroId,
      'path': path,
      'content': content,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<EpubManifest?> getManifest(int libroId) async {
    final db = await _db.database;
    final result = await db.query(
      'book_content',
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
    if (result.isEmpty) return null;
    return EpubManifest.fromJson(jsonDecode(result.first['manifest_json']));
  }

  @override
  Future<String?> getResource(int libroId, String path) async {
    final db = await _db.database;
    final result = await db.query(
      'book_resources',
      where: 'libro_id = ? AND path = ?',
      whereArgs: [libroId, path],
    );
    if (result.isEmpty) return null;
    return result.first['content'] as String;
  }

  @override
  Future<bool> hasContent(int libroId) async {
    final db = await _db.database;
    final result = await db.query(
      'book_content',
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
    return result.isNotEmpty;
  }

  @override
  Future<int?> getVersion(int libroId) async {
    final db = await _db.database;
    final result = await db.query(
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
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT b.libro_id
      FROM biblioteca_local b
      LEFT JOIN book_content c ON b.libro_id = c.libro_id
      WHERE b.is_downloaded = 1
        AND (c.version IS NULL OR b.local_version > c.version)
    ''');
    return result.map((r) => r['libro_id'] as int).toList();
  }

  @override
  Future<void> deleteContent(int libroId) async {
    final db = await _db.database;
    await db.delete('book_resources', where: 'libro_id = ?', whereArgs: [libroId]);
    await db.delete('book_content', where: 'libro_id = ?', whereArgs: [libroId]);
  }

  @override
  Future<void> updateVersion(int libroId, int version) async {
    final db = await _db.database;
    await db.update(
      'book_content',
      {'version': version},
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
  }

  @override
  Future<void> updateDownloadStatus(int libroId, DownloadStatus status) async {
    final db = await _db.database;
    await db.update(
      'biblioteca_local',
      {'download_status': status.value},
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
  }

  @override
  Future<DownloadStatus> getDownloadStatus(int libroId) async {
    final db = await _db.database;
    final result = await db.query(
      'biblioteca_local',
      columns: ['download_status'],
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
    if (result.isEmpty) return DownloadStatus.notDownloaded;
    return DownloadStatusX.fromString(result.first['download_status']);
  }
}
```

### 2.2 Pool de Concurrencia

**File: `lib/shared/core/utils/concurrency_pool.dart`**

```dart
class ConcurrencyPool {
  final int maxConcurrent;

  ConcurrencyPool({this.maxConcurrent = 4});

  Future<List<T>> run<T>(List<Future<T>> Function() tasks) async {
    final results = <T>[];
    final queue = List<Future<T>>.from(tasks);

    while (queue.isNotEmpty) {
      final batch = queue.take(maxConcurrent).toList();
      final completed = await Future.wait(batch);
      results.addAll(completed);
      queue.removeRange(0, batch.length > queue.length ? queue.length : batch.length);
    }

    return results;
  }
}
```

### 2.3 Retry con Backoff

**File: `lib/shared/core/utils/retry_handler.dart`**

```dart
class RetryHandler {
  static const int maxAttempts = 3;
  static const int baseDelayMs = 1000;

  static Future<T> withBackoff<T>(
    Future<T> Function() fn, {
    int Function(Exception)? onRetry,
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await fn();
      } on Exception catch (e) {
        if (attempt == maxAttempts - 1) rethrow;

        final shouldRetry = onRetry?.call(e);
        if (shouldRetry == false) rethrow;

        final delay = (1 << attempt) * baseDelayMs;
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
    throw Exception('Max retries exceeded');
  }
}
```

### 2.4 Tareas

- [ ] Crear `book_content_local_datasource.dart` (abstract)
- [ ] Crear `book_content_local_datasource_impl.dart`
- [ ] Crear `concurrency_pool.dart`
- [ ] Crear `retry_handler.dart`

---

## Fase 3: SyncService Integración

### 3.1 Modificaciones a SyncService

**File: `lib/shared/services/sync_service.dart`**

Agregar método para sync de contenido de libros:

```dart
class SyncService {
  static const int batchSize = 2;
  static const int maxRetries = 3;

  Future<void> _syncBookContents() async {
    final dataSource = getIt<BookContentLocalDataSource>();
    final epubDataSource = getIt<EpubDataSource>();

    final booksToSync = await dataSource.getBooksToSync();
    final limitedBooks = booksToSync.take(batchSize).toList();

    for (final libroId in limitedBooks) {
      final status = await dataSource.getDownloadStatus(libroId);
      if (status == DownloadStatus.downloading) continue;

      try {
        await dataSource.updateDownloadStatus(libroId, DownloadStatus.downloading);
        await _syncBookContent(libroId);
        await dataSource.updateDownloadStatus(libroId, DownloadStatus.completed);
      } catch (e) {
        await dataSource.updateDownloadStatus(libroId, DownloadStatus.failed);
      }
    }
  }

  Future<void> _syncBookContent(int libroId) async {
    final dataSource = getIt<BookContentLocalDataSource>();
    final epubDataSource = getIt<EpubDataSource>();

    // 1. Obtener y guardar manifest
    final manifest = await RetryHandler.withBackoff(
      () => epubDataSource.getManifest(libroId),
      onRetry: (e) => true,
    );

    if (manifest == null) {
      throw Exception('Manifest not found for libro $libroId');
    }

    await dataSource.saveManifest(libroId, manifest);
    final remoteVersion = manifest.version ?? 1;

    // 2. Descargar recursos en paralelo (pool: 3-5)
    final pool = ConcurrencyPool(maxConcurrent: 4);
    final downloadTasks = manifest.readingOrder.map((item) async {
      try {
        final content = await RetryHandler.withBackoff(
          () => epubDataSource.getResource(libroId, item.href),
          onRetry: (e) => true,
        );
        if (content != null) {
          await dataSource.saveResource(libroId, item.href, content);
        }
      } catch (e) {
        // Error en un capítulo: continuar con los demás
        log.warning('Failed to download chapter ${item.href}: $e');
      }
    });

    await Future.wait(downloadTasks);

    // 3. Verificar recursos críticos
    final hasResources = await dataSource.hasContent(libroId);
    if (!hasResources) {
      throw Exception('No resources downloaded for libro $libroId');
    }

    // 4. Actualizar versión
    await dataSource.updateVersion(libroId, remoteVersion);
  }
}
```

### 3.2 Triggers

Modificar `onAppInit()` y `onAppResumed()`:

```dart
Future<void> onAppInit() async {
  // ... existing code ...
  _syncBookContents();
}

Future<void> onAppResumed() async {
  // ... existing code ...
  _syncBookContents();
}
```

### 3.3 Manejo por Nivel de Errores

```dart
enum FailureLevel {
  manifest,    // Falla manifest - marcar failed inmediato
  chapter,     // Falla capítulo - guardar restantes
  network,     // Falla red - retry automático
}

// En _syncBookContent
Future<void> _syncBookContent(int libroId) async {
  try {
    // 1. Manifest
    final manifest = await epubDataSource.getManifest(libroId);
    if (manifest == null) {
      await dataSource.updateDownloadStatus(libroId, DownloadStatus.failed);
      return; // Fail inmediato por manifest
    }
    await dataSource.saveManifest(libroId, manifest);

    // 2. Recursos (continuar si falla capítulo individual)
    final resources = await _downloadResources(libroId, manifest.readingOrder);

    // 3. Verificar que hay contenido
    if (resources.isEmpty) {
      await dataSource.updateDownloadStatus(libroId, DownloadStatus.failed);
    } else {
      await dataSource.updateDownloadStatus(libroId, DownloadStatus.completed);
    }
  } on NetworkException {
    // Retry con backoff en siguiente sync
    await dataSource.updateDownloadStatus(libroId, DownloadStatus.failed);
  }
}
```

### 3.4 Cleanup

Eliminar contenido cuando usuario elimina libro de biblioteca:

```dart
// En biblioteca_repository cuando se elimina libro
Future<void> removeFromBiblioteca(int libroId) async {
  await bibliotecaLocalDataSource.delete(libroId);
  // Cleanup offline content
  await bookContentLocalDataSource.deleteContent(libroId);
  await syncQueueDataSource.addOperation(
    SyncOperation(
      type: 'remove_biblioteca',
      libroId: libroId,
    ),
  );
}
```

### 3.5 Tareas

- [ ] Modificar `sync_service.dart`: agregar método `_syncBookContents()`
- [ ] Modificar `onAppInit()`: llamar `_syncBookContents()`
- [ ] Modificar `onAppResumed()`: llamar `_syncBookContents()`
- [ ] Implementar manejo de errores por nivel
- [ ] Implementar cleanup al eliminar libro

---

## Fase 4: Repository Offline-First

### 4.1 Modificar EpubRepository

**File: `lib/features/reader/data/repositories/epub_repository.dart`**

```dart
class EpubRepositoryImpl implements EpubRepository {
  final EpubDataSource _remoteDataSource;
  final BookContentLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<EpubManifest> getManifest(int libroId) async {
    // Offline-first: intentar local primero
    final localManifest = await _localDataSource.getManifest(libroId);
    if (localManifest != null) {
      return localManifest;
    }

    // Si no hay red y no hay local: error
    if (!await _networkInfo.isConnected) {
      throw OfflineReadingException('No hay contenido offline disponible');
    }

    // Descargar y guardar local
    final manifest = await _remoteDataSource.getManifest(libroId);
    await _localDataSource.saveManifest(libroId, manifest);
    return manifest;
  }

  @override
  Future<String> getResource(int libroId, String path) async {
    // Offline-first: intentar local primero
    final localResource = await _localDataSource.getResource(libroId, path);
    if (localResource != null) {
      return localResource;
    }

    // Si no hay red y no hay local: error
    if (!await _networkInfo.isConnected) {
      throw OfflineReadingException('Capítulo no disponible offline');
    }

    // Descargar y guardar local
    final content = await _remoteDataSource.getResource(libroId, path);
    await _localDataSource.saveResource(libroId, path, content);
    return content;
  }
}
```

### 4.2 Nueva Excepción

**File: `lib/shared/core/exceptions/offline_reading_exception.dart`**

```dart
class OfflineReadingException implements Exception {
  final String message;
  OfflineReadingException(this.message);

  @override
  String toString() => message;
}
```

### 4.3 Tareas

- [ ] Modificar `epub_repository.dart`: offline-first
- [ ] Crear `offline_reading_exception.dart`

---

## Fase 5: UI + Cleanup

### 5.1 Estados de UI

En el cubit de biblioteca, exponer estado de descarga:

```dart
class BibliotecaState {
  final List<BibliotecaLibro> libros;
  final Map<int, DownloadStatus> downloadStatuses;
}
```

### 5.2 Indicador Visual

```dart
// En libro_card.dart
Widget _buildDownloadIndicator(DownloadStatus status) {
  switch (status) {
    case DownloadStatus.notDownloaded:
      return Icon(Icons.cloud_download_off);
    case DownloadStatus.downloading:
      return CircularProgressIndicator();
    case DownloadStatus.completed:
      return Icon(Icons.offline_pin, color: Colors.green);
    case DownloadStatus.failed:
      return Icon(Icons.error, color: Colors.red);
  }
}
```

### 5.3 Retry Manual

```dart
// En biblioteca_cubit.dart
Future<void> retryDownload(int libroId) async {
  await syncService._syncBookContent(libroId);
}
```

### 5.4 Tareas

- [ ] Agregar estados de descarga en `biblioteca_cubit.dart`
- [ ] Agregar indicador visual en UI
- [ ] Implementar retry manual para failed
- [ ] Cleanup al eliminar libro

---

## APIs Resumen

### BookContentLocalDataSource

```dart
// Guardar manifest
Future<void> saveManifest(int libroId, EpubManifest manifest);

// Guardar recurso individual
Future<void> saveResource(int libroId, String path, String content);

// Obtener manifest
Future<EpubManifest?> getManifest(int libroId);

// Obtener recurso
Future<String?> getResource(int libroId, String path);

// Verificar si tiene contenido
Future<bool> hasContent(int libroId);

// Obtener versión local
Future<int?> getVersion(int libroId);

// Obtener libros que necesitan sync
Future<List<int>> getBooksToSync();

// Eliminar contenido
Future<void> deleteContent(int libroId);

// Actualizar versión
Future<void> updateVersion(int libroId, int version);

// Actualizar estado de descarga
Future<void> updateDownloadStatus(int libroId, DownloadStatus status);

// Obtener estado de descarga
Future<DownloadStatus> getDownloadStatus(int libroId);
```

---

## Dependencias

- `sqflite` - SQLite
- `get_it` - DI
- `epub_manifest` (existe) - Modelo de manifest

---

## Notas

- El sync se ejecuta en background durante init/resumed
- Máximo 2-3 libros por ciclo
- Descargas paralelas: 3-5 máximo
- Fallo de capítulo no marca libro como failed
- Fallo de manifest marca failed inmediatamente
- Retry automático con backoff (max 3 intentos)