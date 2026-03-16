class Valoracion {
  final int libroId;
  final int puntuacion;
  final int? usuarioId;

  Valoracion({
    required this.libroId,
    required this.puntuacion,
    this.usuarioId,
  });

  factory Valoracion.fromJson(Map<String, dynamic> json) {
    return Valoracion(
      libroId: json['libroId'] as int? ?? 0,
      puntuacion: json['puntuacion'] as int? ?? 0,
      usuarioId: json['usuarioId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libroId': libroId,
      'puntuacion': puntuacion,
      if (usuarioId != null) 'usuarioId': usuarioId,
    };
  }
}
