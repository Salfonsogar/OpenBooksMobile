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
  final String? portadaBase64;
  final List<String> categorias;

  LibroDetalle({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.descripcion,
    required this.promedioValoraciones,
    required this.cantidadValoraciones,
    required this.resenas,
    required this.totalResenas,
    this.portadaBase64,
    required this.categorias,
  });

  factory LibroDetalle.fromJson(Map<String, dynamic> json) {
    return LibroDetalle(
      id: json['id'] as int,
      titulo: json['titulo'] as String? ?? '',
      autor: json['autor'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      promedioValoraciones: (json['promedioValoraciones'] as num?)?.toDouble() ?? 0.0,
      cantidadValoraciones: json['cantidadValoraciones'] as int? ?? 0,
      resenas: (json['resenas'] as List<dynamic>?)
              ?.map((e) => Resena.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalResenas: json['totalResenas'] as int? ?? 0,
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
      'promedioValoraciones': promedioValoraciones,
      'cantidadValoraciones': cantidadValoraciones,
      'resenas': resenas.map((e) => e.toJson()).toList(),
      'totalResenas': totalResenas,
      'portadaBase64': portadaBase64,
      'categorias': categorias,
    };
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
    String? portadaBase64,
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
      portadaBase64: portadaBase64 ?? this.portadaBase64,
      categorias: categorias ?? this.categorias,
    );
  }
}
