class Sugerencia {
  final int id;
  final String idUsuario;
  final String nombreUsuario;
  final String comentario;

  Sugerencia({
    required this.id,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.comentario,
  });

  factory Sugerencia.fromJson(Map<String, dynamic> json) {
    return Sugerencia(
      id: json['id'] as int,
      idUsuario: (json['idUsuario'] as String?) ?? (json['idUsuario'] as num?)?.toString() ?? '',
      nombreUsuario: json['nombreUsuario'] as String? ?? '',
      comentario: json['comentario'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'nombreUsuario': nombreUsuario,
      'comentario': comentario,
    };
  }
}
