import 'package:equatable/equatable.dart';

class Rol extends Equatable {
  final int id;
  final String nombre;

  const Rol({
    required this.id,
    required this.nombre,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'] ?? 0,
      nombre: json['name'] ?? '',
    );
  }

  bool get isAdministrador => nombre == 'Administrador';

  @override
  List<Object?> get props => [id, nombre];
}
