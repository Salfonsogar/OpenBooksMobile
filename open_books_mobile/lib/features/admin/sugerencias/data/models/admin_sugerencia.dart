import 'package:equatable/equatable.dart';

class AdminSugerencia extends Equatable {
  final int id;
  final int usuarioId;
  final String nombreUsuario;
  final String titulo;
  final String? descripcion;
  final DateTime fechaCreacion;

  const AdminSugerencia({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.titulo,
    this.descripcion,
    required this.fechaCreacion,
  });

  factory AdminSugerencia.fromJson(Map<String, dynamic> json) {
    return AdminSugerencia(
      id: json['id'] as int,
      usuarioId: json['usuarioId'] as int? ?? 0,
      nombreUsuario: json['nombreUsuario'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        usuarioId,
        nombreUsuario,
        titulo,
        descripcion,
        fechaCreacion,
      ];
}

class PagedSugerencias {
  final List<AdminSugerencia> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const PagedSugerencias({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PagedSugerencias.fromJson(Map<String, dynamic> json) {
    List<dynamic> resultsList = [];
    
    if (json.containsKey('results')) {
      resultsList = json['results'] as List<dynamic>? ?? [];
    } else if (json.containsKey('items')) {
      resultsList = json['items'] as List<dynamic>? ?? [];
    } else if (json['results'] is List) {
      resultsList = json['results'] as List;
    }

    return PagedSugerencias(
      items: resultsList.map((e) => AdminSugerencia.fromJson(e as Map<String, dynamic>)).toList(),
      pageNumber: json['currentPage'] ?? json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalRecords'] ?? json['totalCount'] ?? resultsList.length,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  factory PagedSugerencias.empty() {
    return const PagedSugerencias(
      items: [],
      pageNumber: 1,
      pageSize: 10,
      totalCount: 0,
      totalPages: 0,
    );
  }
}
