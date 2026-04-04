class SyncQueueModel {
  final int? id;
  final String operation;
  final String entityType;
  final int entityId;
  final String? payload;
  final int priority;
  final String status;
  final int retryCount;
  final String? errorMessage;
  final int createdAt;
  final int? processedAt;

  SyncQueueModel({
    this.id,
    required this.operation,
    required this.entityType,
    required this.entityId,
    this.payload,
    this.priority = 0,
    this.status = 'pending',
    this.retryCount = 0,
    this.errorMessage,
    required this.createdAt,
    this.processedAt,
  });

  factory SyncQueueModel.fromMap(Map<String, dynamic> map) {
    return SyncQueueModel(
      id: map['id'] as int?,
      operation: map['operation'] as String,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as int,
      payload: map['payload'] as String?,
      priority: map['priority'] as int? ?? 0,
      status: map['status'] as String? ?? 'pending',
      retryCount: map['retry_count'] as int? ?? 0,
      errorMessage: map['error_message'] as String?,
      createdAt: map['created_at'] as int,
      processedAt: map['processed_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'operation': operation,
      'entity_type': entityType,
      'entity_id': entityId,
      'payload': payload,
      'priority': priority,
      'status': status,
      'retry_count': retryCount,
      'error_message': errorMessage,
      'created_at': createdAt,
      'processed_at': processedAt,
    };
  }

  SyncQueueModel copyWith({
    int? id,
    String? operation,
    String? entityType,
    int? entityId,
    String? payload,
    int? priority,
    String? status,
    int? retryCount,
    String? errorMessage,
    int? createdAt,
    int? processedAt,
  }) {
    return SyncQueueModel(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  static const String operationAddBiblioteca = 'add_biblioteca';
  static const String operationRemoveBiblioteca = 'remove_biblioteca';
  static const String operationAddHistorial = 'add_historial';

  static const String entityTypeBiblioteca = 'biblioteca';
  static const String entityTypeHistorial = 'historial';

  static const String statusPending = 'pending';
  static const String statusProcessing = 'processing';
  static const String statusSynced = 'synced';
  static const String statusFailed = 'failed';

  static const int priorityLow = -1;
  static const int priorityNormal = 0;
  static const int priorityHigh = 1;
}
