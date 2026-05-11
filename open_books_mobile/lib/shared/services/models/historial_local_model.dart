class HistorialLocalModel {
  final int? id;
  final int libroId;
  final String usuarioId;
  final String titulo;
  final String? autor;
  final String? portadaBase64;
  final int ultimaLectura;
  final String status;
  final int createdAt;
  final int currentChapterIndex;
  final double scrollPosition;

  HistorialLocalModel({
    this.id,
    required this.libroId,
    required this.usuarioId,
    required this.titulo,
    this.autor,
    this.portadaBase64,
    required this.ultimaLectura,
    this.status = 'synced',
    required this.createdAt,
    this.currentChapterIndex = 0,
    this.scrollPosition = 0.0,
  });

  factory HistorialLocalModel.fromMap(Map<String, dynamic> map) {
    return HistorialLocalModel(
      id: map['id'] as int?,
      libroId: map['libro_id'] as int,
      usuarioId: map['usuario_id'] as String,
      titulo: map['titulo'] as String,
      autor: map['autor'] as String?,
      portadaBase64: map['portada_base64'] as String?,
      ultimaLectura: map['ultima_lectura'] as int,
      status: map['status'] as String? ?? 'synced',
      createdAt: map['created_at'] as int,
      currentChapterIndex: map['current_chapter_index'] as int? ?? 0,
      scrollPosition: map['scroll_position'] as double? ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'libro_id': libroId,
      'usuario_id': usuarioId,
      'titulo': titulo,
      'autor': autor,
      'portada_base64': portadaBase64,
      'ultima_lectura': ultimaLectura,
      'status': status,
      'created_at': createdAt,
      'current_chapter_index': currentChapterIndex,
      'scroll_position': scrollPosition,
    };
  }

  HistorialLocalModel copyWith({
    int? id,
    int? libroId,
    String? usuarioId,
    String? titulo,
    String? autor,
    String? portadaBase64,
    int? ultimaLectura,
    String? status,
    int? createdAt,
    int? currentChapterIndex,
    double? scrollPosition,
  }) {
    return HistorialLocalModel(
      id: id ?? this.id,
      libroId: libroId ?? this.libroId,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      portadaBase64: portadaBase64 ?? this.portadaBase64,
      ultimaLectura: ultimaLectura ?? this.ultimaLectura,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      scrollPosition: scrollPosition ?? this.scrollPosition,
    );
  }
}
