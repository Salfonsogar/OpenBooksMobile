import 'libro_biblioteca.dart';

class Biblioteca {
  final List<LibroBiblioteca> libros;

  Biblioteca({required this.libros});

  factory Biblioteca.fromJson(Map<String, dynamic> json) {
    return Biblioteca(
      libros: (json['libros'] as List<dynamic>?)
              ?.map((e) => LibroBiblioteca.fromJson(e as Map<String, dynamic>))
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
