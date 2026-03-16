class Libro {
  final int id;
  final String titulo;
  final String autor;
  final String descripcion;
  final String? portadaBase64;
  final List<String> categorias;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.descripcion,
    this.portadaBase64,
    required this.categorias,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] as int,
      titulo: json['titulo'] as String? ?? '',
      autor: json['autor'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      portadaBase64: json['portadaBase64'] as String?,
      categorias: (json['categorias'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'descripcion': descripcion,
      'portadaBase64': portadaBase64,
      'categorias': categorias,
    };
  }
}
