import 'package:equatable/equatable.dart';

class AdminStats extends Equatable {
  final int totalUsuarios;
  final int totalLibros;
  final int denunciasPendientes;
  final int sugerenciasNuevas;
  final int sancionesActivas;

  const AdminStats({
    required this.totalUsuarios,
    required this.totalLibros,
    required this.denunciasPendientes,
    required this.sugerenciasNuevas,
    required this.sancionesActivas,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsuarios: json['totalUsuarios'] ?? 0,
      totalLibros: json['totalLibros'] ?? 0,
      denunciasPendientes: json['denunciasPendientes'] ?? 0,
      sugerenciasNuevas: json['sugerenciasNuevas'] ?? 0,
      sancionesActivas: json['sancionesActivas'] ?? 0,
    );
  }

  static const empty = AdminStats(
    totalUsuarios: 0,
    totalLibros: 0,
    denunciasPendientes: 0,
    sugerenciasNuevas: 0,
    sancionesActivas: 0,
  );

  @override
  List<Object?> get props => [
        totalUsuarios,
        totalLibros,
        denunciasPendientes,
        sugerenciasNuevas,
        sancionesActivas,
      ];
}
