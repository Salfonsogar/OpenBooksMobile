class Resena {
  final int id;
  final int usuarioId;
  final String nombreUsuario;
  final String? fotoPerfilBase64;
  final String texto;
  final DateTime fecha;

  Resena({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    this.fotoPerfilBase64,
    required this.texto,
    required this.fecha,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      id: json['id'] as int,
      usuarioId: json['usuarioId'] as int? ?? 0,
      nombreUsuario: json['nombreUsuario'] as String? ?? 'Usuario',
      fotoPerfilBase64: json['fotoPerfil'] as String?,
      texto: json['texto'] as String? ?? '',
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'fotoPerfil': fotoPerfilBase64,
      'texto': texto,
      'fecha': fecha.toIso8601String(),
    };
  }
}
