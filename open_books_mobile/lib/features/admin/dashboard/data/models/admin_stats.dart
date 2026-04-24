import 'package:equatable/equatable.dart';

class AdminStats extends Equatable {
  final int totalUsuarios;
  final int totalLibros;
  final int denunciasPendientes;
  final int sugerenciasNuevas;
  final int sancionesActivas;

  final int usuariosActivos;
  final int librosEnBiblioteca;
  final int paginasLeidasHoy;
  final int paginasLeidasSemana;
  final int paginasLeidasMes;
  final double ratingPromedio;

  final List<LibroPopularData> topLibros;
  final List<CategoriaData> distribucionCategorias;
  final List<LecturaDiariaData> evolucionLectura;

  const AdminStats({
    required this.totalUsuarios,
    required this.totalLibros,
    required this.denunciasPendientes,
    required this.sugerenciasNuevas,
    required this.sancionesActivas,
    required this.usuariosActivos,
    required this.librosEnBiblioteca,
    required this.paginasLeidasHoy,
    required this.paginasLeidasSemana,
    required this.paginasLeidasMes,
    required this.ratingPromedio,
    required this.topLibros,
    required this.distribucionCategorias,
    required this.evolucionLectura,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsuarios: json['totalUsuarios'] ?? 0,
      totalLibros: json['totalLibros'] ?? 0,
      denunciasPendientes: json['denunciasPendientes'] ?? 0,
      sugerenciasNuevas: json['sugerenciasNuevas'] ?? 0,
      sancionesActivas: json['sancionesActivas'] ?? 0,
      usuariosActivos: json['usuariosActivos'] ?? 0,
      librosEnBiblioteca: json['librosEnBiblioteca'] ?? 0,
      paginasLeidasHoy: json['paginasLeidasHoy'] ?? 0,
      paginasLeidasSemana: json['paginasLeidasSemana'] ?? 0,
      paginasLeidasMes: json['paginasLeidasMes'] ?? 0,
      ratingPromedio: (json['ratingPromedio'] as num?)?.toDouble() ?? 0.0,
      topLibros: (json['topLibros'] as List<dynamic>?)
              ?.map((e) => LibroPopularData.fromJson(e))
              .toList() ??
          [],
      distribucionCategorias: (json['distribucionCategorias'] as List<dynamic>?)
              ?.map((e) => CategoriaData.fromJson(e))
              .toList() ??
          [],
      evolucionLectura: (json['evolucionLectura'] as List<dynamic>?)
              ?.map((e) => LecturaDiariaData.fromJson(e))
              .toList() ??
          [],
    );
  }

  static const empty = AdminStats(
    totalUsuarios: 0,
    totalLibros: 0,
    denunciasPendientes: 0,
    sugerenciasNuevas: 0,
    sancionesActivas: 0,
    usuariosActivos: 0,
    librosEnBiblioteca: 0,
    paginasLeidasHoy: 0,
    paginasLeidasSemana: 0,
    paginasLeidasMes: 0,
    ratingPromedio: 0.0,
    topLibros: [],
    distribucionCategorias: [],
    evolucionLectura: [],
  );

  @override
  List<Object?> get props => [
        totalUsuarios,
        totalLibros,
        denunciasPendientes,
        sugerenciasNuevas,
        sancionesActivas,
        usuariosActivos,
        librosEnBiblioteca,
        paginasLeidasHoy,
        paginasLeidasSemana,
        paginasLeidasMes,
        ratingPromedio,
        topLibros,
        distribucionCategorias,
        evolucionLectura,
      ];
}

class LibroPopularData extends Equatable {
  final int libroId;
  final String titulo;
  final int totalLecturas;
  final int paginasLeidas;

  const LibroPopularData({
    required this.libroId,
    required this.titulo,
    required this.totalLecturas,
    required this.paginasLeidas,
  });

  factory LibroPopularData.fromJson(Map<String, dynamic> json) {
    return LibroPopularData(
      libroId: json['libroId'] ?? 0,
      titulo: json['titulo'] ?? '',
      totalLecturas: json['totalLecturas'] ?? 0,
      paginasLeidas: json['paginasLeidas'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [libroId, titulo, totalLecturas, paginasLeidas];
}

class CategoriaData extends Equatable {
  final String nombre;
  final int cantidad;
  final double porcentaje;

  const CategoriaData({
    required this.nombre,
    required this.cantidad,
    required this.porcentaje,
  });

  factory CategoriaData.fromJson(Map<String, dynamic> json) {
    return CategoriaData(
      nombre: json['nombre'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      porcentaje: (json['porcentaje'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [nombre, cantidad, porcentaje];
}

class LecturaDiariaData extends Equatable {
  final DateTime fecha;
  final int paginasLeidas;
  final int sesiones;

  const LecturaDiariaData({
    required this.fecha,
    required this.paginasLeidas,
    required this.sesiones,
  });

  factory LecturaDiariaData.fromJson(Map<String, dynamic> json) {
    return LecturaDiariaData(
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      paginasLeidas: json['paginasLeidas'] ?? 0,
      sesiones: json['sesiones'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [fecha, paginasLeidas, sesiones];
}