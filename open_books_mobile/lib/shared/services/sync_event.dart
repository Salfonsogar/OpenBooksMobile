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
