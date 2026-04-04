class HistorialLocalModel {
  final int? id;
  final int libroId;
  final int usuarioId;
  final String titulo;
  final String? autor;
  final String? portadaBase64;
  final int ultimaLectura;
  final String status;
  final int createdAt;

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
  });

  factory HistorialLocalModel.fromMap(Map<String, dynamic> map) {
    return HistorialLocalModel(
      id: map['id'] as int?,
      libroId: map['libro_id'] as int,
      usuarioId: map['usuario_id'] as int,
      titulo: map['titulo'] as String,
      autor: map['autor'] as String?,
      portadaBase64: map['portada_base64'] as String?,
      ultimaLectura: map['ultima_lectura'] as int,
      status: map['status'] as String? ?? 'synced',
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
      'portada_base64': portadaBase64,
      'ultima_lectura': ultimaLectura,
      'status': status,
      'created_at': createdAt,
    };
  }

  HistorialLocalModel copyWith({
    int? id,
    int? libroId,
    int? usuarioId,
    String? titulo,
    String? autor,
    String? portadaBase64,
    int? ultimaLectura,
    String? status,
    int? createdAt,
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
    );
  }
}
