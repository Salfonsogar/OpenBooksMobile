import 'dart:async';

import 'local_database.dart';
import 'network_info.dart';
import 'models/sync_queue_model.dart';
import 'models/reading_session_model.dart';
import 'models/biblioteca_local_model.dart';
import 'progress_cache.dart';
import '../../features/biblioteca/data/repositories/biblioteca_repository_impl.dart';
import '../../features/historial/data/repositories/historial_repository_impl.dart';
import '../../features/reader/data/datasources/epub_datasource.dart';
import '../core/enums/download_status.dart';
import '../core/utils/concurrency_pool.dart';

class SyncService {
  final LocalDatabase localDatabase;
  final BibliotecaRepositoryImpl bibliotecaRepository;
  final HistorialRepositoryImpl historialRepository;
  final NetworkInfo networkInfo;
  EpubDataSource? _epubDataSource;

  static const int _maxRetryCount = 3;
  static const Duration _retryDelay = Duration(seconds: 30);
  static const int _bookContentBatchSize = 3;
  static const int _maxConcurrentDownloads = 5;
  static const int _maxDownloadAttempts = 3;

  StreamSubscription<bool>? _connectivitySubscription;
  final StreamController<SyncEvent> _syncEventController =
      StreamController<SyncEvent>.broadcast();

  SyncService({
    required this.localDatabase,
    required this.bibliotecaRepository,
    required this.historialRepository,
    required this.networkInfo,
  }) {
    _initConnectivityListener();
  }

  Stream<SyncEvent> get syncEvents => _syncEventController.stream;

  void _initConnectivityListener() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (isConnected) {
        onInternetBack();
      }
    });
  }

  Future<void> onInternetBack() async {
    _syncEventController.add(SyncEvent.internetBackStarted());
    await processSyncQueue();
    _syncEventController.add(SyncEvent.internetBackCompleted());
  }

  Future<void> onAppInit() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    _syncEventController.add(SyncEvent.appInitStarted());
    await processSyncQueue();
    await _syncBookContents();
    _syncEventController.add(SyncEvent.appInitCompleted());
  }

  Future<void> onAppResumed() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    _syncEventController.add(SyncEvent.appResumedStarted());
    await processSyncQueue();
    await _syncBookContents();
    _syncEventController.add(SyncEvent.appResumedCompleted());
  }

  Future<void> onOperationAdded() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    await processSyncQueue();
  }

  Future<void> processSyncQueue() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    final pendingOps = await localDatabase.syncQueueDataSource.getPending();

    if (pendingOps.isEmpty) return;

    _syncEventController.add(SyncEvent.syncStarted());

    for (final op in pendingOps) {
      if (op.retryCount >= _maxRetryCount) {
        await localDatabase.syncQueueDataSource.markAsFailed(
          op.id!,
          'Max retry count exceeded',
        );
        _syncEventController.add(
          SyncEvent.operationFailed(
            op.operation,
            op.entityId,
            'Max retry count exceeded',
          ),
        );
        continue;
      }

      await localDatabase.syncQueueDataSource.markAsProcessing(op.id!);

      try {
        await _executeOperation(op);
        await localDatabase.syncQueueDataSource.markAsSynced(op.id!);
        _syncEventController.add(
          SyncEvent.operationSucceeded(op.operation, op.entityId),
        );
      } catch (e) {
        await localDatabase.syncQueueDataSource.markAsFailed(
          op.id!,
          e.toString(),
        );
        _syncEventController.add(
          SyncEvent.operationFailed(op.operation, op.entityId, e.toString()),
        );

        if (op.retryCount < _maxRetryCount - 1) {
          await _scheduleRetry(op);
        }
      }
    }

    await _cleanup();
    _syncEventController.add(SyncEvent.syncCompleted());
  }

  Future<void> _executeOperation(SyncQueueModel op) async {
    final payload = op.payload != null
        ? _parsePayload(op.payload!)
        : <String, dynamic>{};
    final usuarioId = payload['usuarioId'] as int? ?? 0;
    final libroId = payload['libroId'] as int? ?? op.entityId;

    switch (op.operation) {
      case SyncQueueModel.operationAddBiblioteca:
        await bibliotecaRepository.syncAddBiblioteca(usuarioId, libroId);
        break;
      case SyncQueueModel.operationRemoveBiblioteca:
        await bibliotecaRepository.syncRemoveBiblioteca(usuarioId, libroId);
        break;
      case SyncQueueModel.operationAddHistorial:
        await historialRepository.syncAddHistorial(libroId);
        break;
      case SyncQueueModel.operationUpdateProgress:
        await _handleProgressUpdate(payload);
        break;
      case SyncQueueModel.operationAddReadingSession:
        await _handleReadingSession(payload);
        break;
      default:
        break;
    }
  }

  Future<void> _handleProgressUpdate(Map<String, dynamic> payload) async {
    final libroId = payload['libroId'] as int? ?? 0;
    final usuarioId = payload['usuarioId'] as int? ?? 0;
    final progreso = (payload['progreso'] as num?)?.toDouble() ?? 0.0;
    final page = payload['page'] as int? ?? 0;
    final timestamp =
        payload['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;

    final existing = await localDatabase.bibliotecaLocalDataSource.getByLibroId(
      libroId,
      usuarioId,
    );
    if (existing != null) {
      await localDatabase.bibliotecaLocalDataSource.updateProgressWithTracking(
        id: existing.id!,
        progreso: progreso,
        page: page,
        timestamp: timestamp,
      );
      await localDatabase.bibliotecaLocalDataSource.updateSyncStatus(
        existing.id!,
        'synced',
      );
    }
  }

  Future<void> _handleReadingSession(Map<String, dynamic> payload) async {
    final libroId = payload['libroId'] as int? ?? 0;
    final usuarioId = payload['usuarioId'] as int? ?? 0;
    final progressId = payload['progressId'] as int? ?? 0;
    final pagesRead = payload['pagesRead'] as int? ?? 0;
    final notes = payload['notes'] as String?;
    final timestamp =
        payload['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;

    final session = ReadingSessionModel(
      progressId: progressId,
      libroId: libroId,
      usuarioId: usuarioId,
      pagesReadInSession: pagesRead,
      sessionTimestamp: timestamp,
      notes: notes,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await localDatabase.readingSessionsDataSource.insert(session);
  }

  Map<String, dynamic> _parsePayload(String payload) {
    try {
      return Map<String, dynamic>.from(
        (const JsonDecoder()).convert(payload) as Map,
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _scheduleRetry(SyncQueueModel op) async {
    final delay = _calculateBackoff(op.retryCount);
    await Future.delayed(delay);
    await processSyncQueue();
  }

  Duration _calculateBackoff(int retryCount) {
    if (retryCount == 0) return _retryDelay;
    return Duration(
      milliseconds: _retryDelay.inMilliseconds * (1 << retryCount),
    );
  }

  Future<void> _cleanup() async {
    await localDatabase.runCleanup();
  }

  Future<int> getPendingCount() async {
    return localDatabase.syncQueueDataSource.countPending();
  }

  Future<void> forceSyncNow() async {
    await processSyncQueue();
  }

  Future<void> addProgressUpdateToQueue({
    required int libroId,
    required int usuarioId,
    required double progreso,
    required int page,
    int? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    ProgressCache().set(libroId, progreso, page);

    final existing = await localDatabase.bibliotecaLocalDataSource.getByLibroId(
      libroId,
      usuarioId,
    );
    if (existing != null) {
      await localDatabase.bibliotecaLocalDataSource.updateProgressWithTracking(
        id: existing.id!,
        progreso: progreso,
        page: page,
        timestamp: now,
      );
    } else {
      await localDatabase.bibliotecaLocalDataSource.insert(
        BibliotecaLocalModel(
          libroId: libroId,
          usuarioId: usuarioId,
          titulo: 'Libro $libroId',
          progreso: progreso,
          page: page,
          lastReadAt: now,
          syncStatus: 'pending',
          createdAt: now,
        ),
      );
    }

    final payload = {
      'libroId': libroId,
      'usuarioId': usuarioId,
      'progreso': progreso,
      'page': page,
    };

    final operation = SyncQueueModel(
      operation: SyncQueueModel.operationUpdateProgress,
      entityType: SyncQueueModel.entityTypeProgress,
      entityId: libroId,
      payload: payload.toString(),
      priority: SyncQueueModel.priorityHigh,
      createdAt: now,
    );

    await localDatabase.syncQueueDataSource.insert(operation);
    if (existing != null) {
      await localDatabase.bibliotecaLocalDataSource.updateSyncStatus(
        existing.id!,
        'pending',
      );
    }
  }

  Future<void> addReadingSessionToQueue({
    required int libroId,
    required int usuarioId,
    required int progressId,
    required int pagesRead,
    String? notes,
    int? timestamp,
  }) async {
    final payload = {
      'libroId': libroId,
      'usuarioId': usuarioId,
      'progressId': progressId,
      'pagesRead': pagesRead,
      'notes': notes,
      'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
    };

    final operation = SyncQueueModel(
      operation: SyncQueueModel.operationAddReadingSession,
      entityType: SyncQueueModel.entityTypeReadingSession,
      entityId: libroId,
      payload: payload.toString(),
      priority: SyncQueueModel.priorityNormal,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await localDatabase.syncQueueDataSource.insert(operation);
  }

  Future<void> fallbackToLocal({
    required int libroId,
    required int usuarioId,
    required double progreso,
    required int page,
    String? errorMessage,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await localDatabase.bibliotecaLocalDataSource.updateProgressWithTracking(
      id:
          (await localDatabase.bibliotecaLocalDataSource.getByLibroId(
            libroId,
            usuarioId,
          ))?.id ??
          0,
      progreso: progreso,
      page: page,
      timestamp: timestamp,
    );

    await addProgressUpdateToQueue(
      libroId: libroId,
      usuarioId: usuarioId,
      progreso: progreso,
      page: page,
      timestamp: timestamp,
    );

    _syncEventController.add(
      SyncEvent.operationFailed(
        SyncQueueModel.operationUpdateProgress,
        libroId,
        errorMessage ?? 'Guardado localmente por fallo de conexion',
      ),
    );
  }

  Future<void> processProgressSync() async {
    final pendingProgress = await localDatabase.syncQueueDataSource
        .getPendingByEntityType(SyncQueueModel.entityTypeProgress);

    for (final op in pendingProgress) {
      await _processProgressOperation(op);
    }
  }

  Future<void> _processProgressOperation(SyncQueueModel op) async {
    final payload = op.payload != null
        ? _parsePayload(op.payload!)
        : <String, dynamic>{};
    final libroId = payload['libroId'] as int? ?? op.entityId;
    final progreso = (payload['progreso'] as num?)?.toDouble() ?? 0.0;
    final page = payload['page'] as int? ?? 0;

    try {
      await localDatabase.bibliotecaLocalDataSource.updateProgressWithTracking(
        id:
            (await localDatabase.bibliotecaLocalDataSource.getByLibroId(
              libroId,
              payload['usuarioId'] as int? ?? 0,
            ))?.id ??
            0,
        progreso: progreso,
        page: page,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await localDatabase.syncQueueDataSource.markAsSynced(op.id!);
      await localDatabase.bibliotecaLocalDataSource.updateSyncStatus(
        (await localDatabase.bibliotecaLocalDataSource.getByLibroId(
              libroId,
              payload['usuarioId'] as int? ?? 0,
            ))?.id ??
            0,
        'synced',
      );
    } catch (e) {
      await localDatabase.bibliotecaLocalDataSource.updateSyncStatus(
        (await localDatabase.bibliotecaLocalDataSource.getByLibroId(
              libroId,
              payload['usuarioId'] as int? ?? 0,
            ))?.id ??
            0,
        'conflict',
      );
    }
  }

  Future<void> resolveConflictWithLatestWrite({
    required int libroId,
    required int usuarioId,
    required int serverTimestamp,
    required double serverProgreso,
    required int serverPage,
  }) async {
    final local = await localDatabase.bibliotecaLocalDataSource.getByLibroId(
      libroId,
      usuarioId,
    );

    if (local == null) return;

    final localTimestamp = local.lastReadAt ?? 0;

    if (serverTimestamp > localTimestamp) {
      await localDatabase.bibliotecaLocalDataSource.updateProgressWithTracking(
        id: local.id!,
        progreso: serverProgreso,
        page: serverPage,
        timestamp: serverTimestamp,
      );
      await localDatabase.bibliotecaLocalDataSource.updateSyncStatus(
        local.id!,
        'synced',
      );
    }
  }

  Future<int> getPendingProgressCount() async {
    return localDatabase.syncQueueDataSource.countPendingByEntityType(
      SyncQueueModel.entityTypeProgress,
    );
  }

  double? getCachedProgress(int libroId) {
    return ProgressCache().get(libroId)?.progreso;
  }

  int? getCachedPage(int libroId) {
    return ProgressCache().get(libroId)?.page;
  }

  void clearProgressCache(int libroId) {
    ProgressCache().remove(libroId);
  }

  void setEpubDataSource(EpubDataSource dataSource) {
    _epubDataSource = dataSource;
  }

  Future<void> _syncBookContents() async {
    if (_epubDataSource == null) return;

    final dataSource = localDatabase.bookContentLocalDataSource;

    try {
      final booksToSync = await dataSource.getBooksToSync();
      final limitedBooks = booksToSync.take(_bookContentBatchSize).toList();

      for (final libroId in limitedBooks) {
        final status = await dataSource.getDownloadStatus(libroId);
        if (status == DownloadStatus.downloading) continue;

        await dataSource.updateDownloadStatus(
          libroId,
          DownloadStatus.downloading,
        );
        await _syncBookContentWithRetry(libroId);
      }
    } catch (e) {
      // Skip book content sync on error
    }
  }

  Future<void> _syncBookContentWithRetry(int libroId) async {
    final dataSource = localDatabase.bookContentLocalDataSource;

    for (int attempt = 0; attempt < _maxDownloadAttempts; attempt++) {
      try {
        await _syncBookContent(libroId);
        await dataSource.updateDownloadStatus(
          libroId,
          DownloadStatus.completed,
        );
        return;
      } catch (e) {
        if (attempt < _maxDownloadAttempts - 1) {
          final delay = (1 << attempt) * _retryDelay.inMilliseconds;
          await Future.delayed(Duration(milliseconds: delay));
        }
      }
    }

    await dataSource.updateDownloadStatus(libroId, DownloadStatus.failed);
  }

  Future<void> _syncBookContent(int libroId) async {
    if (_epubDataSource == null) return;

    final dataSource = localDatabase.bookContentLocalDataSource;

    // Version checking
    final remoteManifest = await _epubDataSource!.getManifest(libroId);

    final remoteVersion = remoteManifest.version ?? 1;
    final localVersion = await dataSource.getVersion(libroId);

    // Skip if remote version <= local version
    if (localVersion != null && remoteVersion <= localVersion) {
      await dataSource.updateDownloadStatus(libroId, DownloadStatus.completed);
      return;
    }

    // Delete previous content before downloading new version
    await dataSource.deleteContent(libroId);

    // Save manifest
    await dataSource.saveManifest(libroId, remoteManifest);

    // Download resources with concurrency control
    final pool = ConcurrencyPool(maxConcurrent: _maxConcurrentDownloads);
    final downloadTasks = remoteManifest.readingOrder.map((item) async {
      try {
        final content = await _epubDataSource!.getResource(libroId, item.href);
        await dataSource.saveResource(libroId, item.href, content);
      } catch (e) {
        // Fallo parcial - continuar con otros capítulos
      }
    }).toList();

    await pool.run(downloadTasks);

    // Verify critical resources exist
    final hasResources = await dataSource.hasContent(libroId);
    if (!hasResources) {
      throw Exception('No resources downloaded for libro $libroId');
    }

    await dataSource.updateVersion(libroId, remoteVersion);
  }

  Future<void> retryDownload(int libroId) async {
    final dataSource = localDatabase.bookContentLocalDataSource;
    await dataSource.updateDownloadStatus(libroId, DownloadStatus.downloading);
    await _syncBookContentWithRetry(libroId);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncEventController.close();
  }
}

enum SyncEventType {
  syncStarted,
  syncCompleted,
  internetBackStarted,
  internetBackCompleted,
  appInitStarted,
  appInitCompleted,
  appResumedStarted,
  appResumedCompleted,
  operationSucceeded,
  operationFailed,
}

class SyncEvent {
  final SyncEventType type;
  final String? operation;
  final int? entityId;
  final String? errorMessage;

  SyncEvent({
    required this.type,
    this.operation,
    this.entityId,
    this.errorMessage,
  });

  factory SyncEvent.syncStarted() => SyncEvent(type: SyncEventType.syncStarted);
  factory SyncEvent.syncCompleted() =>
      SyncEvent(type: SyncEventType.syncCompleted);
  factory SyncEvent.internetBackStarted() =>
      SyncEvent(type: SyncEventType.internetBackStarted);
  factory SyncEvent.internetBackCompleted() =>
      SyncEvent(type: SyncEventType.internetBackCompleted);
  factory SyncEvent.appInitStarted() =>
      SyncEvent(type: SyncEventType.appInitStarted);
  factory SyncEvent.appInitCompleted() =>
      SyncEvent(type: SyncEventType.appInitCompleted);
  factory SyncEvent.appResumedStarted() =>
      SyncEvent(type: SyncEventType.appResumedStarted);
  factory SyncEvent.appResumedCompleted() =>
      SyncEvent(type: SyncEventType.appResumedCompleted);
  factory SyncEvent.operationSucceeded(String operation, int entityId) =>
      SyncEvent(
        type: SyncEventType.operationSucceeded,
        operation: operation,
        entityId: entityId,
      );
  factory SyncEvent.operationFailed(
    String operation,
    int entityId,
    String errorMessage,
  ) => SyncEvent(
    type: SyncEventType.operationFailed,
    operation: operation,
    entityId: entityId,
    errorMessage: errorMessage,
  );

  String get name {
    switch (type) {
      case SyncEventType.syncStarted:
        return 'Sincronización iniciada';
      case SyncEventType.syncCompleted:
        return 'Sincronización completada';
      case SyncEventType.internetBackStarted:
        return 'Internet恢复 - Iniciando sync';
      case SyncEventType.internetBackCompleted:
        return 'Internet恢复 - Sync completado';
      case SyncEventType.appInitStarted:
        return 'App iniciada - Sync iniciado';
      case SyncEventType.appInitCompleted:
        return 'App iniciada - Sync completado';
      case SyncEventType.appResumedStarted:
        return 'App resumed - Sync iniciado';
      case SyncEventType.appResumedCompleted:
        return 'App resumed - Sync completado';
      case SyncEventType.operationSucceeded:
        return 'Operación sincronizada: $operation';
      case SyncEventType.operationFailed:
        return 'Operación fallida: $operation - $errorMessage';
    }
  }
}

class JsonDecoder {
  const JsonDecoder();
  dynamic convert(String input) {
    return _parseJson(input);
  }

  dynamic _parseJson(String input) {
    input = input.trim();
    if (input.isEmpty) return null;

    if (input == 'null') return null;
    if (input == 'true') return true;
    if (input == 'false') return false;

    if (input.startsWith('{') && input.endsWith('}')) {
      final map = <String, dynamic>{};
      final content = input.substring(1, input.length - 1).trim();
      if (content.isNotEmpty) {
        final pairs = _splitPairs(content);
        for (final pair in pairs) {
          final colonIndex = pair.indexOf(':');
          if (colonIndex == -1) continue;
          final key = pair.substring(0, colonIndex).trim().replaceAll('"', '');
          final value = pair.substring(colonIndex + 1).trim();
          map[key] = _parseValue(value);
        }
      }
      return map;
    }

    if (input.startsWith('[') && input.endsWith(']')) {
      final list = <dynamic>[];
      final content = input.substring(1, input.length - 1).trim();
      if (content.isNotEmpty) {
        final items = _splitElements(content);
        for (final item in items) {
          list.add(_parseValue(item));
        }
      }
      return list;
    }

    return _parseValue(input);
  }

  List<String> _splitPairs(String content) {
    final pairs = <String>[];
    var depth = 0;
    var start = 0;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];
      if (char == '{' || char == '[') depth++;
      if (char == '}' || char == ']') depth--;
      if (char == ',' && depth == 0) {
        pairs.add(content.substring(start, i).trim());
        start = i + 1;
      }
    }
    pairs.add(content.substring(start).trim());
    return pairs;
  }

  List<String> _splitElements(String content) {
    final elements = <String>[];
    var depth = 0;
    var start = 0;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];
      if (char == '{' || char == '[') depth++;
      if (char == '}' || char == ']') depth--;
      if (char == ',' && depth == 0) {
        elements.add(content.substring(start, i).trim());
        start = i + 1;
      }
    }
    elements.add(content.substring(start).trim());
    return elements;
  }

  dynamic _parseValue(String value) {
    value = value.trim();
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    if (value == 'null') return null;
    if (value == 'true') return true;
    if (value == 'false') return false;

    final intValue = int.tryParse(value);
    if (intValue != null) return intValue;

    final doubleValue = double.tryParse(value);
    if (doubleValue != null) return doubleValue;

    return value;
  }
}
