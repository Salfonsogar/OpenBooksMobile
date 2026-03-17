import '../../../libros/data/models/libro.dart';

class Biblioteca {
  final List<Libro> libros;

  Biblioteca({required this.libros});

  factory Biblioteca.fromJson(Map<String, dynamic> json) {
    return Biblioteca(
      libros: (json['libros'] as List<dynamic>?)
              ?.map((e) => Libro.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libros': libros.map((e) => e.toJson()).toList(),
    };
  }
}
