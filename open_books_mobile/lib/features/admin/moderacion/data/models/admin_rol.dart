import 'package:equatable/equatable.dart';

class AdminRol extends Equatable {
  final int id;
  final String nombre;

  const AdminRol({
    required this.id,
    required this.nombre,
  });

  factory AdminRol.fromJson(Map<String, dynamic> json) {
    return AdminRol(
      id: json['id'] as int,
      nombre: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nombre,
    };
  }

  bool get isAdministrador => nombre.toLowerCase() == 'administrador';

  @override
  List<Object?> get props => [id, nombre];
}

class CreateRolRequest {
  final String nombre;

  CreateRolRequest({required this.nombre});

  Map<String, dynamic> toJson() {
    return {'name': nombre};
  }
}

class UpdateRolRequest {
  final String? nombre;

  UpdateRolRequest({this.nombre});

  Map<String, dynamic> toJson() {
    return {
      if (nombre != null) 'name': nombre,
    };
  }
}
