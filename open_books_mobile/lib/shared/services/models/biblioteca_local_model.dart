class BibliotecaLocalModel {
  final int? id;
  final int libroId;
  final int usuarioId;
  final String titulo;
  final String? autor;
  final String? descripcion;
  final String? portadaBase64;
  final String? portadaCustomBase64;
  final String? categorias;
  final double progreso;
  final bool isDownloaded;
  final int? page;
  final int? lastReadAt;
  final int? readingStreak;
  final String? syncStatus;
  final int? localVersion;
  final int? updatedAt;
  final int createdAt;

  BibliotecaLocalModel({
    this.id,
    required this.libroId,
    required this.usuarioId,
    required this.titulo,
    this.autor,
    this.descripcion,
    this.portadaBase64,
    this.portadaCustomBase64,
    this.categorias,
    this.progreso = 0.0,
    this.isDownloaded = false,
    this.page,
    this.lastReadAt,
    this.readingStreak,
    this.syncStatus,
    this.localVersion,
    this.updatedAt,
    required this.createdAt,
  });

  factory BibliotecaLocalModel.fromMap(Map<String, dynamic> map) {
    return BibliotecaLocalModel(
      id: map['id'] as int?,
      libroId: map['libro_id'] as int,
      usuarioId: map['usuario_id'] as int,
      titulo: map['titulo'] as String,
      autor: map['autor'] as String?,
      descripcion: map['descripcion'] as String?,
      portadaBase64: map['portada_base64'] as String?,
      portadaCustomBase64: map['portada_custom_base64'] as String?,
      categorias: map['categorias'] as String?,
      progreso: (map['progreso'] as num?)?.toDouble() ?? 0.0,
      isDownloaded: (map['is_downloaded'] as int?) == 1,
      page: map['page'] as int?,
      lastReadAt: map['last_read_at'] as int?,
      readingStreak: map['reading_streak'] as int?,
      syncStatus: map['sync_status'] as String?,
      localVersion: map['local_version'] as int?,
      updatedAt: map['updated_at'] as int?,
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'libro_id': libroId,
      'usuario_id': usuarioId,
      'titulo': titulo,
      'autor': autor,
      'descripcion': descripcion,
      'portada_base64': portadaBase64,
      'portada_custom_base64': portadaCustomBase64,
      'categorias': categorias,
      'progreso': progreso,
      'is_downloaded': isDownloaded ? 1 : 0,
      'page': page,
      'last_read_at': lastReadAt,
      'reading_streak': readingStreak,
      'sync_status': syncStatus,
      'local_version': localVersion,
      'updated_at': updatedAt,
      'created_at': createdAt,
    };
  }

  BibliotecaLocalModel copyWith({
    int? id,
    int? libroId,
    int? usuarioId,
    String? titulo,
    String? autor,
    String? descripcion,
    String? portadaBase64,
    String? portadaCustomBase64,
    String? categorias,
    double? progreso,
    bool? isDownloaded,
    int? page,
    int? lastReadAt,
    int? readingStreak,
    String? syncStatus,
    int? localVersion,
    int? updatedAt,
    int? createdAt,
  }) {
    return BibliotecaLocalModel(
      id: id ?? this.id,
      libroId: libroId ?? this.libroId,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      descripcion: descripcion ?? this.descripcion,
      portadaBase64: portadaBase64 ?? this.portadaBase64,
      portadaCustomBase64: portadaCustomBase64 ?? this.portadaCustomBase64,
      categorias: categorias ?? this.categorias,
      progreso: progreso ?? this.progreso,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      page: page ?? this.page,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      readingStreak: readingStreak ?? this.readingStreak,
      syncStatus: syncStatus ?? this.syncStatus,
      localVersion: localVersion ?? this.localVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
