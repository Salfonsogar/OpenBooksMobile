# Plan de Implementación - Modo Offline y Sync

## Resumen Ejecutivo

Este documento detalla el roadmap de implementación para agregar funcionalidad offline, sincronización y refactorización del reader en la aplicación Open Books Mobile.

### Objetivos Principales
- Permitir acceso a biblioteca e historial sin conexión
- Sincronización automática de datos
- Almacenamiento offline de contenido EPUB
- Mejorar sistema de cache del reader

### Principios Base
- NO tocar catálogo de libros
- NO aplicar Clean Architecture global
- Offline solo donde aporta valor real
- Introducir complejidad solo cuando se necesita
- Usar UseCases SOLO en Biblioteca e Historial

---

## Modelo de Datos

### 1. Tabla: biblioteca_local

Almacena los libros de la biblioteca del usuario para acceso offline.

```sql
CREATE TABLE biblioteca_local (
  id INTEGER PRIMARY KEY,
  libro_id INTEGER NOT NULL,
  usuario_id INTEGER NOT NULL,
  titulo TEXT NOT NULL,
  autor TEXT,
  descripcion TEXT,
  portada_base64 TEXT,
  categorias TEXT,  -- JSON array como string
  progreso REAL DEFAULT 0.0,
  is_downloaded INTEGER DEFAULT 0,  -- BOOLEAN: 0=no, 1=si
  page INTEGER,  -- página en paginación
  updated_at INTEGER,
  created_at INTEGER,
  
  UNIQUE(libro_id, usuario_id)
);
```

**Campos explicados:**
- `id`: ID local único en SQLite
- `libro_id`: ID del libro en el sistema (coincide con API)
- `usuario_id`: ID del usuario owner
- `is_downloaded`: Indica si el contenido EPUB está disponible offline
- `page`: Página actual en paginación (para downloads parciales)

**⚠️ AJUSTE: Separación de responsabilidades**
- La tabla `biblioteca_local` contiene SOLO estado del usuario (datos del libro + progreso + descarga)
- El estado de sincronización se gestiona completamente en `sync_queue`
- No hay campos `status`, `retry_count`, `error_message` aquí

---

### 2. Tabla: historial_local

Almacena lista simple de libros leídos por el usuario.

```sql
CREATE TABLE historial_local (
  id INTEGER PRIMARY KEY,
  libro_id INTEGER NOT NULL,
  usuario_id INTEGER NOT NULL,
  titulo TEXT NOT NULL,
  autor TEXT,
  portada_base64 TEXT,
  ultima_lectura INTEGER,  -- timestamp Unix
  status TEXT DEFAULT 'synced',  -- synced | pending_add
  created_at INTEGER,
  
  UNIQUE(libro_id, usuario_id)
);
```

**Comportamiento clave:**
- Si el libro ya existe en historial → actualizar `ultima_lectura`
- Si no existe → insertar nuevo registro
- NO se guardan posiciones de lectura (se maneja en frontend)

---

### 3. Tabla: sync_queue

Cola de operaciones pendientes de sincronización con el servidor.

```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  operation TEXT NOT NULL,  -- add_biblioteca | remove_biblioteca
  entity_type TEXT NOT NULL,  -- biblioteca | historial
  entity_id INTEGER NOT NULL,
  payload TEXT,  -- JSON con datos adicionales
  priority INTEGER DEFAULT 0,  -- -1=baja, 0=normal, 1=alta
  status TEXT DEFAULT 'pending',  -- pending | processing | synced | failed
  retry_count INTEGER DEFAULT 0,
  error_message TEXT,
  created_at INTEGER,
  processed_at INTEGER
);
```

**Campos explicados:**
- `priority`: Controla orden de procesamiento
  - `1` (alta): Operaciones críticas como eliminar libro
  - `0` (normal): Operaciones estándar como agregar
  - `-1` (baja): Operaciones que pueden esperar
- `operation`: Tipo de operación a realizar
- `entity_id`: ID de la entidad afectada
- `payload`: JSON con datos completos de la operación

**⚠️ AJUSTE: Limpieza de sync_queue**
- Eliminar operaciones con estado `synced` después de 7 días
- Descartar operaciones con estado `failed` después de alcanzar `MAX_RETRY_COUNT` (3 intentos)
- Implementar job de limpieza periódica:

```dart
// Constantes de limpieza
const int SYNCED_RETENTION_DAYS = 7;
const int MAX_RETRY_COUNT = 3;

Future<void> cleanupSyncQueue() async {
  final cutoffSynced = DateTime.now()
    .subtract(Duration(days: SYNCED_RETENTION_DAYS))
    .millisecondsSinceEpoch;

  // Eliminar synced antiguos
  await db.delete('sync_queue',
    where: 'status = ? AND processed_at < ?',
    whereArgs: ['synced', cutoffSynced],
  );

  // Descartar failed que excedieron reintentos
  await db.delete('sync_queue',
    where: 'status = ? AND retry_count >= ?',
    whereArgs: ['failed', MAX_RETRY_COUNT],
  );
}
```

---

### 4. Tabla: epub_downloads

Rastra qué libros tienen contenido EPUB descargado localmente.

```sql
CREATE TABLE epub_downloads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  libro_id INTEGER NOT NULL UNIQUE,
  download_path TEXT NOT NULL,  -- ruta en sistema de archivos
  manifest_json TEXT,  -- contenido del manifest
  total_size INTEGER,  -- tamaño en bytes
  downloaded_at INTEGER,
  status TEXT DEFAULT 'pending',  -- pending | downloading | completed | failed
  error_message TEXT
);
```

---

## Sprint 1 - Infraestructura Base

### Objetivo
Preparar el terreno sin romper nada existente.

### Entregables
1. NetworkInfo service
2. Base de datos SQLite centralizada
3. Diseño de tablas
4. Servicios base reutilizables

---

### 1.1 NetworkInfo Service

**Ubicación:** `lib/shared/services/network_info.dart`

**Responsabilidad:**
- Detectar estado de conectividad
- Proveer stream reactivo de cambios de conexión

```dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  // Implementación con connectivity_plus
}
```

**Consideraciones:**
- Usar `connectivity_plus` (ya instalada)
- Proveer stream para que otros servicios reactiven sync
- Manejar casos edge: WiFi vs Datos móviles vs Sin conexión

---

### 1.2 Base de Datos SQLite

**Ubicación:** `lib/shared/services/local_database.dart`

**Arquitectura:**
```
local_database.dart (singleton)
├── _database (sqflite Database)
├── init() - crear tablas
├── bibliotecaLocalDataSource
├── historialLocalDataSource
├── syncQueueDataSource
└── epubDownloadsDataSource
```

**Tablas creadas en orden:**
1. `biblioteca_local`
2. `historial_local`
3. `sync_queue`
4. `epub_downloads`

**Consideraciones:**
- Usar singleton para mantener una sola conexión
- Implementar migraciones para cambios futuros de esquema
- Usar transacciones para operaciones múltiples
- Manejar apertura/cierre de BD apropiadamente

---

### 1.3 Diagrama de Arquitectura Sprint 1

```
┌─────────────────────────────────────────────────────────┐
│                    INFRAESTRUCTURA                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │  NetworkInfo    │      │ LocalDatabase   │        │
│  │  (connectivity)  │      │   (sqflite)     │        │
│  └────────┬─────────┘      └────────┬─────────┘        │
│           │                         │                   │
│           │    ┌────────────────────┴────┐             │
│           │    │     Shared Services    │             │
│           │    │  - network_info.dart  │             │
│           │    │  - local_database.dart│             │
│           │    └────────────────────────┘             │
│           │                                          │
└───────────┼──────────────────────────────────────────┘
            │
            ▼
    (Sin cambios en features aún)
```

---

## Sprint 2 - Biblioteca Offline

### Objetivo
Primera feature offline completa con UseCases.

### Arquitectura
```
Cubit → UseCase → Repository → (LocalDataSource + RemoteDataSource)
```

---

### 2.1 Estructura de Archivos

```
features/biblioteca/
├── data/
│   ├── datasources/
│   │   ├── biblioteca_local_datasource.dart   # SQLite
│   │   └── biblioteca_remote_datasource.dart # API
│   ├── models/
│   │   └── libro_biblioteca.dart             # DTO existente
│   ├── mappers/
│   │   └── biblioteca_mapper.dart            # DTO → Entity
│   └── repositories/
│       └── biblioteca_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── libro_biblioteca_entity.dart
│   ├── repositories/
│   │   └── biblioteca_repository.dart        # Interfaz
│   └── usecases/
│       ├── get_biblioteca_usecase.dart
│       ├── add_libro_biblioteca_usecase.dart
│       └── remove_libro_biblioteca_usecase.dart
├── logic/cubit/
│   └── biblioteca_cubit.dart                  # Refactorizado
└── ui/
    └── (pages/widgets existentes)
```

---

### 2.2 BibliotecaLocalDataSource

**Responsabilidades:**
- CRUD en tabla `biblioteca_local`
- Consultas SQL
- Manejo de estados de sync

```dart
abstract class BibliotecaLocalDataSource {
  Future<List<LibroBiblioteca>> getAll();
  Future<LibroBiblioteca?> getById(int id);
  Future<void> insert(LibroBiblioteca libro);
  Future<void> update(LibroBiblioteca libro);
  Future<void> delete(int id);
  Future<void> updateStatus(int id, String status);
  Future<List<LibroBiblioteca>> getPending();
  Future<void> markAsSynced(int id);
  Future<void> markAsFailed(int id, String error);
}
```

---

### 2.3 BibliotecaRemoteDataSource

**Responsabilidades:**
- Llama a API existente
- Manejo de errores de red
- Paginación

```dart
abstract class BibliotecaRemoteDataSource {
  Future<PagedResult<LibroBiblioteca>> getBiblioteca({
    int page = 1,
    int pageSize = 10,
  });
  Future<void> addLibro(int libroId);
  Future<void> removeLibro(int libroId);
}
```

**Consideraciones:**
- El endpoint actual: `GET /api/Biblioteca/{usuarioId}/libros`
- No hay sync incremental → descargar todo paginado
- Manejar error 401 (token expirado)

---

### 2.4 UseCases

#### GetBibliotecaUseCase

```dart
class GetBibliotecaUseCase {
  final BibliotecaRepository repository;

  Future<Either<Failure, List<LibroBibliotecaEntity>>> call() async {
    // 1. Verificar conectividad
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      // 2. Obtener de API
      final remoteResult = await repository.getFromRemote();
      
      if (remoteResult.isSuccess) {
        // 3. Guardar en local
        await repository.syncFromRemote(remoteResult.value);
        return Right(remoteResult.value);
      }
    }

    // 4. Si no hay conexión o falló: devolver cache local
    final localResult = await repository.getFromLocal();
    return Right(localResult);
  }
}
```

#### AddLibroBibliotecaUseCase

```dart
class AddLibroBibliotecaUseCase {
  final BibliotecaRepository repository;

  Future<Either<Failure, void>> call(int libroId) async {
    // 1. Guardar inmediatamente en local (offline-first)
    await repository.addLocal(libroId);

    // 2. Agregar a cola de sync
    await repository.addToSyncQueue(
      operation: SyncOperation.add,
      entityId: libroId,
      priority: 0, // normal
    );

    // 3. Intentar sync inmediatamente
    await repository.syncNow();

    return const Right(null);
  }
}
```

**Consideraciones:**
- Siempre guardar en local primero (offline-first)
- Encolar para sync
- Intentar sync inmediatamente
- Si falla → marcar como `pending` para reintentar después

---

### 2.5 Repository Implementation

```dart
class BibliotecaRepositoryImpl implements BibliotecaRepository {
  final BibliotecaLocalDataSource localDataSource;
  final BibliotecaRemoteDataSource remoteDataSource;
  final SyncQueueDataSource syncQueueDataSource;
  final NetworkInfo networkInfo;

  // Estrategia: Offline-first
  // 1. Siempre intentar local primero
  // 2. Sincronizar con remoto si hay conexión
  // 3. Si hay operación pendiente, encolar
}
```

---

### 2.6 Flujo de Datos

```
┌─────────────────────────────────────────────────────────────────┐
│                        BIBLIOTECA OFFLINE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────┐     ┌──────────┐      ┌──────────────────┐        │
│  │  UI     │────▶│  Cubit   │─────▶│  UseCase         │        │
│  └─────────┘     └──────────┘      └──────────────────┘        │
│                                            │                    │
│                              ┌─────────────┴──────────────┐    │
│                              ▼                             ▼    │
│                     ┌─────────────────┐      ┌────────────────┐│
│                     │  Local (SQLite) │      │ Remote (API)   ││
│                     └─────────────────┘      └────────────────┘│
│                              │                     │           │
│                              │     ┌───────────────┘           │
│                              ▼     ▼                            │
│                     ┌─────────────────────────────────┐         │
│                     │      SyncQueue                  │         │
│                     │  (pending operations)           │         │
│                     └─────────────────────────────────┘         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### 2.7 Estados de Sync - Biblioteca

```
┌──────────────────────────────────────────────────────────────┐
│                    FLUJO DE ADD LIBRO                        │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Usuario toca "Agregar a biblioteca"                         │
│                          │                                   │
│                          ▼                                   │
│              ┌─────────────────────────┐                     │
│              │ 1. Guardar en local    │                     │
│              │    status: pending_add  │◀── Siempre          │
│              └─────────────────────────┘                     │
│                          │                                   │
│                          ▼                                   │
│              ┌─────────────────────────┐                     │
│              │ 2. Encolar sync_queue  │                     │
│              │    priority: 0 (normal) │                     │
│              └─────────────────────────┘                     │
│                          │                                   │
│                          ▼                                   │
│              ┌─────────────────────────┐                     │
│              │ 3. Intentar sync NOW   │◀── Si hay conexión  │
│              │    POST /api/Biblioteca │                     │
│              └─────────────────────────┘                     │
│                          │                                   │
│            ┌─────────────┴─────────────┐                     │
│            ▼                           ▼                     │
│     ┌──────────────┐          ┌──────────────┐              │
│     │ ÉXITO        │          │ FALLO        │              │
│     │ status: synced│          │ status: failed│             │
│     └──────────────┘          │ retry++       │             │
│                               └──────────────┘              │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Sprint 3 - Historial Offline

### Objetivo
Aplicar patrón ya probado en Biblioteca.

### Diferencias con Biblioteca
- Historial es más simple (solo lista de libros leídos)
- NO hay operaciones remove (historial solo crece)
- NO hay `is_downloaded` (no aplica)

---

### 3.1 Estructura de Archivos

```
features/historial/
├── data/
│   ├── datasources/
│   │   ├── historial_local_datasource.dart
│   │   └── historial_remote_datasource.dart
│   └── repositories/
│       └── historial_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── historial_entry_entity.dart
│   ├── repositories/
│   │   └── historial_repository.dart
│   └── usecases/
│       ├── get_historial_usecase.dart
│       └── add_to_historial_usecase.dart
├── logic/cubit/
│   └── historial_cubit.dart
└── ui/
    └── (pages/widgets existentes)
```

---

### 3.2 Comportamiento Clave: Sin Duplicados

```dart
// En HistorialLocalDataSource
Future<void> insertOrUpdateHistorial(Libro libro) async {
  final existing = await getByLibroId(libro.id);
  
  if (existing != null) {
    // UPDATE: solo actualizar timestamp
    await updateTimestamp(libro.id, DateTime.now().millisecondsSinceEpoch);
  } else {
    // INSERT: nuevo registro
    await insert(LibroHistorial.fromLibro(libro));
  }
}
```

---

### 3.3 Integración con Reader

```dart
// En ReaderCubit o ReaderPage
void onBookOpened(Libro libro) {
  // Al abrir un libro, agregar a historial
  context.read<HistorialCubit>().addToHistorial(libro);
}
```

**Consideraciones:**
- NO esperar a que termine la operación (fire-and-forget para UI)
- El sync puede fallar silenciosamente (historial no es crítico)

---

## Sprint 4 - EPUB Offline

### Objetivo
Almacenar contenido EPUB en sistema de archivos para acceso offline.

---

### 4.1 Estructura

```
lib/shared/services/
├── epub_local_storage_service.dart     # NUEVO
└── local_database.dart                 # existente

/epub/                                  # directorio en app
├── {libro_id}/
│   ├── manifest.json
│   ├── content/
│   │   ├── chapter_1.xhtml
│   │   ├── chapter_2.xhtml
│   │   └── ...
│   ├── images/
│   │   ├── image_1.png
│   │   └── ...
│   └── styles/
│       └── style.css
```

---

### 4.2 EpubLocalStorageService

```dart
abstract class EpubLocalStorageService {
  // Verificar si está descargado
  Future<bool> isDownloaded(int libroId);

  // Descargar EPUB completo
  Future<void> downloadEpub(int libroId);

  // Eliminar descarga local
  Future<void> deleteEpub(int libroId);

  // Obtener path del recurso
  Future<String?> getResourcePath(int libroId, String resourcePath);

  // Obtener manifest
  Future<Map<String, dynamic>?> getManifest(int libroId);

  // Obtener tamaño descargado
  Future<int> getDownloadSize(int libroId);
}
```

**⚠️ AJUSTE: Control de concurrencia en descargas**
Para evitar saturar el backend y problemas de rendimiento, las descargas se procesan en lotes:

```dart
const int MAX_CONCURRENT_DOWNLOADS = 5;

class EpubLocalStorageService {
  final List<int> _downloadQueue = [];
  bool _isProcessing = false;

  Future<void> queueDownload(int libroId) async {
    _downloadQueue.add(libroId);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _downloadQueue.isEmpty) return;
    
    _isProcessing = true;
    
    while (_downloadQueue.isNotEmpty) {
      final batch = _downloadQueue.take(MAX_CONCURRENT_DOWNLOADS).toList();
      
      await Future.wait(
        batch.map((libroId) => _downloadSingleEpub(libroId)),
        eagerError: false,
      );
      
      _downloadQueue.removeWhere((id) => batch.contains(id));
    }
    
    _isProcessing = false;
  }

  Future<void> _downloadSingleEpub(int libroId) async {
    // Descarga individual de un EPUB
  }
}
```

**Ventajas:**
- Máximo 5 descargas simultáneas
- Si una falla, no bloquea las demás
- Control de errores por operación
```

---

### 4.3 Flujo de Descarga

```
┌─────────────────────────────────────────────────────────────────┐
│                    DESCARGA DE EPUB                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Usuario toca "Descargar para offline"                          │
│                          │                                      │
│                          ▼                                      │
│              ┌─────────────────────────┐                        │
│              │ 1. Verificar conexión   │                        │
│              └─────────────────────────┘                        │
│                          │                                      │
│                          ▼                                      │
│              ┌─────────────────────────┐                        │
│              │ 2. Obtener manifest      │                        │
│              │    GET /api/Libros/{id}  │                        │
│              │         /epub/manifest   │                        │
│              └─────────────────────────┘                        │
│                          │                                      │
│                          ▼                                      │
│              ┌─────────────────────────┐                        │
│              │ 3. Crear estructura     │                        │
│              │    /epub/{libro_id}/    │                        │
│              └─────────────────────────┘                        │
│                          │                                      │
│                          ▼                                      │
│              ┌─────────────────────────┐                        │
│              │ 4. Descargar recursos   │                        │
│              │    - manifest.json      │                        │
│              │    - chapters (XHTML)   │                        │
│              │    - images             │                        │
│              │    - styles (CSS)        │                        │
│              └─────────────────────────┘                        │
│                          │                                      │
│                          ▼                                      │
│              ┌─────────────────────────┐                        │
│              │ 5. Marcar en BD         │                        │
│              │    is_downloaded = 1    │                        │
│              │    epub_downloads table │                        │
│              └─────────────────────────┘                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### 4.4 Reader con Offline

```dart
class ReaderCubit extends Cubit<ReaderState> {
  final EpubLocalStorageService localStorage;
  final NetworkInfo networkInfo;

  Future<void> loadChapter(int libroId, String chapterPath) async {
    // 1. Verificar si está descargado
    final isDownloaded = await localStorage.isDownloaded(libroId);

    if (isDownloaded) {
      // 2. Cargar desde sistema de archivos
      final content = await localStorage.getChapterContent(libroId, chapterPath);
      emit(Loaded(content));
    } else {
      // 3. Verificar conexión
      final isConnected = await networkInfo.isConnected;
      
      if (isConnected) {
        // 4. Cargar desde API
        final content = await remoteDataSource.getChapter(libroId, chapterPath);
        emit(Loaded(content));
      } else {
        // 5. Error: no descargado y sin conexión
        emit(const Error('Libro no disponible offline. Descárgalo primero.'));
      }
    }
  }
}
```

---

### 4.5 Bandera is_downloaded en Biblioteca

```dart
// En modelo LibroBiblioteca
class LibroBiblioteca {
  final int id;
  final String titulo;
  // ... otros campos
  final bool isDownloaded;  // NUEVO CAMPO

  // Actualizar al descargar/eliminar EPUB
  Future<void> setDownloaded(bool value) async {
    // Actualizar en SQLite
    await localDataSource.updateDownloadStatus(id, value);
  }
}
```

**⚠️ AJUSTE: Resolución de rutas relativas en EPUB**

Los archivos EPUB usan rutas relativas para imágenes, CSS y contenido. Al cargar desde almacenamiento local, estas rutas deben resolverse correctamente:

```dart
class EpubPathResolver {
  final int libroId;
  final String basePath;

  EpubPathResolver(this.libroId, this.basePath);

  /// Resuelve ruta relativa a ruta absoluta local
  String resolveRelativePath(String relativePath) {
    if (relativePath.startsWith('/')) {
      relativePath = relativePath.substring(1);
    }

    if (relativePath.startsWith('../')) {
      return _resolveParentPath(relativePath);
    }

    return path.join(basePath, relativePath);
  }

  String _resolveParentPath(String relativePath) {
    var result = relativePath;
    var base = basePath;
    
    while (result.startsWith('../')) {
      base = path.dirname(base);
      result = result.substring(3);
    }
    
    return path.join(base, result);
  }

  Future<String?> getResourceContent(String relativePath) async {
    final resolvedPath = resolveRelativePath(relativePath);
    final file = File(resolvedPath);
    
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  Future<List<int>?> getResourceBytes(String relativePath) async {
    final resolvedPath = resolveRelativePath(relativePath);
    final file = File(resolvedPath);
    
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }
}
```

**Ejemplos:**
| Ruta relativa | Ruta resuelta |
|---------------|---------------|
| `Images/cover.png` | `/epub/123/Images/cover.png` |
| `../style.css` | `/epub/123/style.css` |

---

## Sprint 5 - Motor de Sincronización

### Objetivo
Hacer que todo se sincronice automáticamente.

---

### 5.1 SyncService

```dart
class SyncService {
  final SyncQueueDataSource queueDataSource;
  final BibliotecaRepository bibliotecaRepo;
  final HistorialRepository historialRepo;
  final NetworkInfo networkInfo;

  // Triggers de sincronización
  void onInternetBack();
  void onAppInit();
  void onAppResumed();
  void onOperationAdded();
}
```

---

### 5.2 Triggers de Sincronización

| Trigger | Cuándo | Prioridad |
|---------|--------|-----------|
| onInternetBack | Vuelve la conexión | Alta |
| onAppInit | App inicia | Media |
| onAppResumed | App vuelve a foreground | Baja |
| onOperationAdded | Nueva operación local | Alta (intentar inmediatamente) |

---

### 5.3 Algoritmo de Sync

```dart
Future<void> processSyncQueue() async {
  // 1. Obtener operaciones pendientes ordenadas por prioridad
  final pendingOps = await queueDataSource.getPending(
    orderBy: 'priority DESC, created_at ASC',
  );

  for (final op in pendingOps) {
    // 2. Marcar como procesando
    await queueDataSource.markAsProcessing(op.id);

    try {
      // 3. Ejecutar según tipo
      switch (op.operation) {
        case 'add_biblioteca':
          await _syncAddBiblioteca(op.entityId);
          break;
        case 'remove_biblioteca':
          await _syncRemoveBiblioteca(op.entityId);
          break;
        case 'add_historial':
          await _syncAddHistorial(op.entityId);
          break;
      }

      // 4. Éxito: marcar como synced
      await queueDataSource.markAsSynced(op.id);
      await bibliotecaDataSource.markAsSynced(op.entityId);

    } catch (e) {
      // 5. Fallo: reintentar
      await queueDataSource.markAsFailed(op.id, e.toString());
      await bibliotecaDataSource.markAsFailed(
        op.entityId, 
        e.toString(),
      );
    }
  }
}
```

---

### 5.4 Reintentos Automáticos

```dart
// Constantes de configuración
const int MAX_RETRY_COUNT = 3;
const Duration RETRY_DELAY = Duration(seconds: 30);
const Duration EXPONENTIAL_BACKOFF = Duration(minutes: 5);

// En proceso de sync
if (op.retryCount >= MAX_RETRY_COUNT) {
  // Descartar operación después de 3 intentos
  await queueDataSource.markAsDiscarded(op.id);
  await _notifyUser(op); // Notificar al usuario
} else {
  // Programar reintento con backoff exponencial
  final delay = Duration(
    milliseconds: RETRY_DELAY.inMilliseconds * 
    (pow(2, op.retryCount).toInt()),
  );
  await Future.delayed(delay);
  await processSyncQueue(); // Reintentar
}
```

---

### 5.5 Diagrama de Flujo de Sync

```
┌─────────────────────────────────────────────────────────────────┐
│                     MOTOR DE SYNC                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│    ┌──────────────────────────────────────────────┐            │
│    │           EVENTO DE SYNC                     │            │
│    │ (internet back / app init / foreground)     │            │
│    └──────────────────┬───────────────────────────┘            │
│                       │                                          │
│                       ▼                                          │
│    ┌──────────────────────────────────────────────┐            │
│    │         VERIFICAR CONEXIÓN                    │            │
│    └──────────────────┬───────────────────────────┘            │
│                       │                                          │
│              ┌───────┴───────┐                                 │
│              ▼               ▼                                 │
│       ┌──────────┐    ┌──────────────┐                         │
│       │ CONECTADO│    │ SIN CONEXIÓN │                         │
│       └──────┬───┘    └──────────────┘                         │
│              │                                                 │
│              ▼                                                 │
│    ┌────────────────────────────────────────┐                 │
│    │    OBTENER OPERACIONES PENDIENTES      │                 │
│    │    order by priority, created_at      │                 │
│    └──────────────────┬───────────────────┘                 │
│                       │                                          │
│                       ▼                                          │
│    ┌────────────────────────────────────────┐                 │
│    │      PROCESAR CADA OPERACIÓN           │                 │
│    └──────────────────┬───────────────────┘                 │
│                       │                                          │
│         ┌─────────────┴─────────────┐                          │
│         ▼                           ▼                          │
│  ┌──────────────┐            ┌──────────────┐                │
│  │    ÉXITO     │            │    FALLO     │                │
│  │ synced + 1   │            │ failed + 1   │                │
│  └──────────────┘            └──────────────┘                │
│                                               │               │
│                                               ▼               │
│                                    ┌──────────────────┐      │
│                                    │ ¿retry < MAX?    │      │
│                                    └────────┬─────────┘      │
│                                    yes      │      no         │
│                                    ▼        │                 ▼ │
│                              ┌──────────┐  │     ┌────────────┐│
│                              │ REINTENTAR│  │     │ DESCARTAR ││
│                              └──────────┘  │     └────────────┘│
│                                              │                 │
└──────────────────────────────────────────────┴─────────────────┘
```

---

## Consideraciones Generales

### Manejo de Errores

| Escenario | Acción |
|-----------|--------|
| Sin conexión | Usar cache local, encolar para sync |
| Token expirado | Redirect a login, no hacer sync |
| Error 500 | Reintentar con backoff |
| Conflicto de datos | Last-write-wins (timestamp) |
| Libro no encontrado (remoto) | Eliminar de cache local |

### Testing

| Componente | Tipo de Test |
|------------|--------------|
| UseCases | Unit tests |
| Repository | Integration tests |
| SyncService | Unit tests con mocks |
| LocalDataSource | Integration tests (SQLite) |
| EPUB Storage | Integration tests (filesystem) |

### Rendimiento

- Usar transacciones SQLite para operaciones múltiples
- Limitar tamaño de cache en memoria
- Comprimir imágenes antes de guardar
- Usar paginación en descargas grandes

### Seguridad

- NO guardar token en SQLite (usar flutter_secure_storage)
- Limpiar datos sensibles al hacer logout
- Encriptar contenido EPUB si es necesario

---

## Dependencias Requeridas

Todas estas librerías ya están instaladas en el proyecto:

| Librería | Uso | Estado |
|----------|-----|--------|
| sqflite | Base de datos local | ✅ Instalada |
| connectivity_plus | Detección de red | ✅ Instalada |
| path_provider | Rutas de archivos | ✅ Instalada |
| dio | HTTP client | ✅ Instalada |
| get_it | Inyección de dependencias | ✅ Instalada |
| equatable | Comparación de objetos | ✅ Instalada |
| flutter_secure_storage | Token seguro | ✅ Instalada |

---

## Roadmap Final

| Sprint | Focus | Entregable |
|--------|-------|------------|
| 1 | Infraestructura | NetworkInfo + SQLite + Tablas |
| 2 | Biblioteca offline | UseCases + Repository + Sync |
| 3 | Historial offline | Reutilización de patrón |
| 4 | EPUB offline | EpubLocalStorage + Reader |
| 5 | Sync automático | Queue processing + Reintentos |
| 6 | Testing | Tests unitarios e integrales |

---

*Documento creado: 2026-03-26*
*Proyecto: Open Books Mobile*
