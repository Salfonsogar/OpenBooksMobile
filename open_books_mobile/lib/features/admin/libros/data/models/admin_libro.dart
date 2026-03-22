import 'package:equatable/equatable.dart';

class AdminLibro extends Equatable {
  final int id;
  final String titulo;
  final String autor;
  final String? descripcion;
  final String? portadaBase64;
  final DateTime fechaPublicacion;
  final bool activo;
  final List<String> categorias;

  const AdminLibro({
    required this.id,
    required this.titulo,
    required this.autor,
    this.descripcion,
    this.portadaBase64,
    required this.fechaPublicacion,
    required this.activo,
    required this.categorias,
  });

  String? get portadaUrl {
    if (portadaBase64 != null && portadaBase64!.isNotEmpty) {
      return portadaBase64;
    }
    return null;
  }

  factory AdminLibro.fromJson(Map<String, dynamic> json) {
    return AdminLibro(
      id: json['id'] as int,
      titulo: json['titulo'] as String? ?? '',
      autor: json['autor'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      portadaBase64: json['portadaBase64'] as String?,
      fechaPublicacion: json['fechaPublicacion'] != null
          ? DateTime.parse(json['fechaPublicacion'] as String)
          : DateTime.now(),
      activo: json['activo'] as bool? ?? true,
      categorias: (json['categorias'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        titulo,
        autor,
        descripcion,
        portadaBase64,
        fechaPublicacion,
        activo,
        categorias,
      ];
}

class PagedLibros {
  final List<AdminLibro> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const PagedLibros({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PagedLibros.empty() {
    return const PagedLibros(
      items: [],
      pageNumber: 1,
      pageSize: 10,
      totalCount: 0,
      totalPages: 0,
    );
  }
}

class CreateLibroRequest {
  final String titulo;
  final String autor;
  final String? descripcion;
  final List<int> categoriasIds;
  final String? portadaBase64;
  final String? archivoBase64;
  final String? nombreArchivo;

  CreateLibroRequest({
    required this.titulo,
    required this.autor,
    this.descripcion,
    required this.categoriasIds,
    this.portadaBase64,
    this.archivoBase64,
    this.nombreArchivo,
  });

  Map<String, dynamic> toFormData() {
    return {
      'titulo': titulo,
      'autor': autor,
      if (descripcion != null) 'descripcion': descripcion,
      'categoriasIds': categoriasIds,
      if (portadaBase64 != null) 'portada': portadaBase64,
      if (archivoBase64 != null) 'archivo': archivoBase64,
      if (nombreArchivo != null) 'nombreArchivo': nombreArchivo,
    };
  }
}

class UpdateLibroRequest {
  final String? titulo;
  final String? autor;
  final String? descripcion;
  final List<int>? categoriasIds;
  final String? portadaBase64;
  final bool? activo;

  UpdateLibroRequest({
    this.titulo,
    this.autor,
    this.descripcion,
    this.categoriasIds,
    this.portadaBase64,
    this.activo,
  });

  Map<String, dynamic> toFormData() {
    return {
      if (titulo != null) 'titulo': titulo,
      if (autor != null) 'autor': autor,
      if (descripcion != null) 'descripcion': descripcion,
      if (categoriasIds != null) 'categoriasIds': categoriasIds,
      if (portadaBase64 != null) 'portada': portadaBase64,
      if (activo != null) 'activo': activo.toString(),
    };
  }
}
