import 'package:equatable/equatable.dart';

class AdminSancion extends Equatable {
  final int id;
  final int usuarioId;
  final String nombreUsuario;
  final String tipoSancion;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool activa;

  const AdminSancion({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.tipoSancion,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.activa,
  });

  factory AdminSancion.fromJson(Map<String, dynamic> json) {
    return AdminSancion(
      id: json['id'] as int,
      usuarioId: json['usuarioId'] as int,
      nombreUsuario: json['nombreUsuario'] as String? ?? '',
      tipoSancion: json['tipoSancion'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.parse(json['fechaInicio'] as String)
          : DateTime.now(),
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'] as String)
          : null,
      activa: json['activa'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'tipoSancion': tipoSancion,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      if (fechaFin != null) 'fechaFin': fechaFin!.toIso8601String(),
      'activa': activa,
    };
  }

  @override
  List<Object?> get props => [
        id,
        usuarioId,
        nombreUsuario,
        tipoSancion,
        descripcion,
        fechaInicio,
        fechaFin,
        activa,
      ];
}

class PagedSanciones {
  final List<AdminSancion> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const PagedSanciones({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PagedSanciones.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] ?? [];
    return PagedSanciones(
      items: itemsJson.map((e) => AdminSancion.fromJson(e)).toList(),
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  factory PagedSanciones.empty() {
    return const PagedSanciones(
      items: [],
      pageNumber: 1,
      pageSize: 10,
      totalCount: 0,
      totalPages: 0,
    );
  }
}

class CreateSancionRequest {
  final int usuarioId;
  final String tipoSancion;
  final String? descripcion;
  final DateTime? fechaFin;

  CreateSancionRequest({
    required this.usuarioId,
    required this.tipoSancion,
    this.descripcion,
    this.fechaFin,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'tipoSancion': tipoSancion,
      if (descripcion != null) 'descripcion': descripcion,
      if (fechaFin != null) 'fechaFin': fechaFin!.toIso8601String(),
    };
  }
}

class UpdateSancionRequest {
  final String? tipoSancion;
  final String? descripcion;
  final DateTime? fechaFin;
  final bool? activa;

  UpdateSancionRequest({
    this.tipoSancion,
    this.descripcion,
    this.fechaFin,
    this.activa,
  });

  Map<String, dynamic> toJson() {
    return {
      if (tipoSancion != null) 'tipoSancion': tipoSancion,
      if (descripcion != null) 'descripcion': descripcion,
      if (fechaFin != null) 'fechaFin': fechaFin!.toIso8601String(),
      if (activa != null) 'activa': activa,
    };
  }
}
