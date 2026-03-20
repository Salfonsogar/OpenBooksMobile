import '../../../libros/data/models/libro.dart';

class LibroBiblioteca {
  final int id;
  final String titulo;
  final String autor;
  final String descripcion;
  final String? portadaBase64;
  final List<String> categorias;
  final double progreso;

  LibroBiblioteca({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.descripcion,
    this.portadaBase64,
    required this.categorias,
    this.progreso = 0.0,
  });

  factory LibroBiblioteca.fromJson(Map<String, dynamic> json) {
    return LibroBiblioteca(
      id: json['id'] as int,
      titulo: json['titulo'] as String? ?? '',
      autor: json['autor'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      portadaBase64: json['portadaBase64'] as String?,
      categorias: (json['categorias'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      progreso: (json['progreso'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory LibroBiblioteca.fromLibro(Libro libro, {double progreso = 0.0}) {
    return LibroBiblioteca(
      id: libro.id,
      titulo: libro.titulo,
      autor: libro.autor,
      descripcion: libro.descripcion,
      portadaBase64: libro.portadaBase64,
      categorias: libro.categorias,
      progreso: progreso,
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
      'progreso': progreso,
    };
  }
}
