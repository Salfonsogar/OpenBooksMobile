class Resena {
  final int id;
  final String usuarioId;
  final String nombreUsuario;
  final String texto;
  final DateTime fecha;

  Resena({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.texto,
    required this.fecha,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      id: (json['id'] as num?)?.toInt() ?? 0,
      usuarioId: (json['usuarioId'] as String?) ?? (json['usuarioId'] as num?)?.toString() ?? '',
      nombreUsuario: (json['nombreUsuario'] ?? json['NombreUsuario'] ?? 'Usuario') as String,
      texto: (json['texto'] ?? json['Texto'] ?? '') as String,
      fecha: (json['fecha'] ?? json['Fecha']) != null
          ? DateTime.parse((json['fecha'] ?? json['Fecha']) as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'texto': texto,
      'fecha': fecha.toIso8601String(),
    };
  }
}
