class ReadingSessionModel {
  final int? id;
  final int progressId;
  final int libroId;
  final int usuarioId;
  final int pagesReadInSession;
  final int sessionTimestamp;
  final String? notes;
  final int? createdAt;

  ReadingSessionModel({
    this.id,
    required this.progressId,
    required this.libroId,
    required this.usuarioId,
    required this.pagesReadInSession,
    required this.sessionTimestamp,
    this.notes,
    this.createdAt,
  });

  factory ReadingSessionModel.fromMap(Map<String, dynamic> map) {
    return ReadingSessionModel(
      id: map['id'] as int?,
      progressId: map['progress_id'] as int,
      libroId: map['libro_id'] as int,
      usuarioId: map['usuario_id'] as int,
      pagesReadInSession: map['pages_read_in_session'] as int? ?? 0,
      sessionTimestamp: map['session_timestamp'] as int,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'progress_id': progressId,
      'libro_id': libroId,
      'usuario_id': usuarioId,
      'pages_read_in_session': pagesReadInSession,
      'session_timestamp': sessionTimestamp,
      'notes': notes,
      'created_at': createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  ReadingSessionModel copyWith({
    int? id,
    int? progressId,
    int? libroId,
    int? usuarioId,
    int? pagesReadInSession,
    int? sessionTimestamp,
    String? notes,
    int? createdAt,
  }) {
    return ReadingSessionModel(
      id: id ?? this.id,
      progressId: progressId ?? this.progressId,
      libroId: libroId ?? this.libroId,
      usuarioId: usuarioId ?? this.usuarioId,
      pagesReadInSession: pagesReadInSession ?? this.pagesReadInSession,
      sessionTimestamp: sessionTimestamp ?? this.sessionTimestamp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}