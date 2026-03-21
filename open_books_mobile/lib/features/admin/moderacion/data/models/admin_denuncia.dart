import 'package:equatable/equatable.dart';

class AdminDenuncia extends Equatable {
  final int id;
  final int usuarioDenuncianteId;
  final String nombreUsuarioDenunciante;
  final int usuarioDenunciadoId;
  final String nombreUsuarioDenunciado;
  final String motivo;
  final String? descripcion;
  final DateTime fechaCreacion;
  final String estado;

  const AdminDenuncia({
    required this.id,
    required this.usuarioDenuncianteId,
    required this.nombreUsuarioDenunciante,
    required this.usuarioDenunciadoId,
    required this.nombreUsuarioDenunciado,
    required this.motivo,
    this.descripcion,
    required this.fechaCreacion,
    required this.estado,
  });

  factory AdminDenuncia.fromJson(Map<String, dynamic> json) {
    return AdminDenuncia(
      id: json['id'] as int,
      usuarioDenuncianteId: json['usuarioDenuncianteId'] as int? ?? 0,
      nombreUsuarioDenunciante:
          json['nombreUsuarioDenunciante'] as String? ?? '',
      usuarioDenunciadoId: json['usuarioDenunciadoId'] as int? ?? 0,
      nombreUsuarioDenunciado:
          json['nombreUsuarioDenunciado'] as String? ?? '',
      motivo: json['motivo'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : DateTime.now(),
      estado: json['estado'] as String? ?? 'Pendiente',
    );
  }

  @override
  List<Object?> get props => [
        id,
        usuarioDenuncianteId,
        nombreUsuarioDenunciante,
        usuarioDenunciadoId,
        nombreUsuarioDenunciado,
        motivo,
        descripcion,
        fechaCreacion,
        estado,
      ];
}

class PagedDenuncias {
  final List<AdminDenuncia> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const PagedDenuncias({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PagedDenuncias.fromJson(Map<String, dynamic> json) {
    List<dynamic> resultsList = [];
    
    if (json.containsKey('results')) {
      resultsList = json['results'] as List<dynamic>? ?? [];
    } else if (json.containsKey('items')) {
      resultsList = json['items'] as List<dynamic>? ?? [];
    } else if (json['results'] is List) {
      resultsList = json['results'] as List;
    }

    return PagedDenuncias(
      items: resultsList.map((e) => AdminDenuncia.fromJson(e as Map<String, dynamic>)).toList(),
      pageNumber: json['currentPage'] ?? json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalRecords'] ?? json['totalCount'] ?? resultsList.length,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  factory PagedDenuncias.empty() {
    return const PagedDenuncias(
      items: [],
      pageNumber: 1,
      pageSize: 10,
      totalCount: 0,
      totalPages: 0,
    );
  }
}
