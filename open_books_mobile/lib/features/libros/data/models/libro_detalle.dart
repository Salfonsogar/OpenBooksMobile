import 'libro.dart';
import 'resena.dart';

class LibroDetalle {
  final int id;
  final String titulo;
  final String autor;
  final String descripcion;
  final double promedioValoraciones;
  final int cantidadValoraciones;
  final List<Resena> resenas;
  final int totalResenas;
  final String? portadaUrl;
  final List<String> categorias;

  LibroDetalle({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.descripcion,
    this.promedioValoraciones = 0.0,
    this.cantidadValoraciones = 0,
    this.resenas = const [],
    this.totalResenas = 0,
    this.portadaUrl,
    this.categorias = const [],
  });

  factory LibroDetalle.fromLibro(Libro libro, {List<Resena> resenas = const [], int totalResenas = 0}) {
    return LibroDetalle(
      id: libro.id,
      titulo: libro.titulo,
      autor: libro.autor,
      descripcion: libro.descripcion,
      promedioValoraciones: libro.promedioValoracion,
      cantidadValoraciones: libro.totalValoraciones,
      portadaUrl: libro.portadaUrl,
      categorias: libro.categorias,
      resenas: resenas,
      totalResenas: totalResenas,
    );
  }

  LibroDetalle copyWith({
    int? id,
    String? titulo,
    String? autor,
    String? descripcion,
    double? promedioValoraciones,
    int? cantidadValoraciones,
    List<Resena>? resenas,
    int? totalResenas,
    String? portadaUrl,
    List<String>? categorias,
  }) {
    return LibroDetalle(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      descripcion: descripcion ?? this.descripcion,
      promedioValoraciones: promedioValoraciones ?? this.promedioValoraciones,
      cantidadValoraciones: cantidadValoraciones ?? this.cantidadValoraciones,
      resenas: resenas ?? this.resenas,
      totalResenas: totalResenas ?? this.totalResenas,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      categorias: categorias ?? this.categorias,
    );
  }
}
