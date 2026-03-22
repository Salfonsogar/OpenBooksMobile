import 'package:equatable/equatable.dart';

class AdminCategoria extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final int cantidadLibros;

  const AdminCategoria({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.cantidadLibros,
  });

  factory AdminCategoria.fromJson(Map<String, dynamic> json) {
    final libros = json['libros'];
    int cantidad = 0;
    if (libros is List) {
      cantidad = libros.length;
    } else if (libros is int) {
      cantidad = libros;
    }

    return AdminCategoria(
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      cantidadLibros: cantidad,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidadLibros': cantidadLibros,
    };
  }

  @override
  List<Object?> get props => [id, nombre, descripcion, cantidadLibros];
}

class PagedCategorias {
  final List<AdminCategoria> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const PagedCategorias({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PagedCategorias.fromJson(Map<String, dynamic> json) {
    List<dynamic> resultsList = [];
    
    if (json.containsKey('results')) {
      resultsList = json['results'] as List<dynamic>? ?? [];
    } else if (json.containsKey('items')) {
      resultsList = json['items'] as List<dynamic>? ?? [];
    }

    return PagedCategorias(
      items: resultsList.map((e) => AdminCategoria.fromJson(e as Map<String, dynamic>)).toList(),
      pageNumber: json['currentPage'] ?? json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalRecords'] ?? json['totalCount'] ?? resultsList.length,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  factory PagedCategorias.empty() {
    return const PagedCategorias(
      items: [],
      pageNumber: 1,
      pageSize: 10,
      totalCount: 0,
      totalPages: 0,
    );
  }
}

class CreateCategoriaRequest {
  final String nombre;
  final String? descripcion;

  CreateCategoriaRequest({
    required this.nombre,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }
}

class UpdateCategoriaRequest {
  final String? nombre;
  final String? descripcion;

  UpdateCategoriaRequest({
    this.nombre,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }
}
