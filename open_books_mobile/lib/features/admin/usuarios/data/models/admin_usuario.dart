import 'package:equatable/equatable.dart';

class AdminUsuario extends Equatable {
  final int id;
  final String userName;
  final String nombreCompleto;
  final String email;
  final bool estado;
  final bool sancionado;
  final DateTime fechaRegistro;
  final String nombreRol;
  final int rolId;
  final String? fotoPerfilBase64;

  const AdminUsuario({
    required this.id,
    required this.userName,
    required this.nombreCompleto,
    required this.email,
    required this.estado,
    required this.sancionado,
    required this.fechaRegistro,
    required this.nombreRol,
    required this.rolId,
    this.fotoPerfilBase64,
  });

  factory AdminUsuario.fromJson(Map<String, dynamic> json) {
    return AdminUsuario(
      id: json['id'] as int,
      userName: json['userName'] as String? ?? '',
      nombreCompleto: json['nombreCompleto'] as String? ?? '',
      email: json['email'] as String? ?? '',
      estado: json['estado'] as bool? ?? true,
      sancionado: json['sancionado'] as bool? ?? false,
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'] as String)
          : DateTime.now(),
      nombreRol: json['nombreRol'] as String? ?? 'Usuario',
      rolId: json['rolId'] as int? ?? 2,
      fotoPerfilBase64: json['fotoPerfil'] as String?,
    );
  }

  bool get isAdmin => rolId == 1 || nombreRol.toLowerCase() == 'administrador';

  @override
  List<Object?> get props => [
        id,
        userName,
        nombreCompleto,
        email,
        estado,
        sancionado,
        fechaRegistro,
        nombreRol,
        rolId,
        fotoPerfilBase64,
      ];
}

class CreateUsuarioRequest {
  final String userName;
  final String email;
  final String contrasena;
  final int rolId;
  final String nombreCompleto;

  CreateUsuarioRequest({
    required this.userName,
    required this.email,
    required this.contrasena,
    required this.rolId,
    required this.nombreCompleto,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'contrasena': contrasena,
      'rolId': rolId,
      'nombreCompleto': nombreCompleto,
    };
  }
}

class UpdateUsuarioRequest {
  final String? userName;
  final String? email;
  final String? nombreCompleto;
  final int? rolId;
  final bool? estado;

  UpdateUsuarioRequest({
    this.userName,
    this.email,
    this.nombreCompleto,
    this.rolId,
    this.estado,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (userName != null) map['userName'] = userName;
    if (email != null) map['email'] = email;
    if (nombreCompleto != null) map['nombreCompleto'] = nombreCompleto;
    if (rolId != null) map['rolId'] = rolId;
    if (estado != null) map['estado'] = estado;
    return map;
  }
}

class PagedUsuarios {
  final List<AdminUsuario> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const PagedUsuarios({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PagedUsuarios.fromJson(Map<String, dynamic> json) {
    List<dynamic> resultsList = [];
    
    if (json.containsKey('results')) {
      resultsList = json['results'] as List<dynamic>? ?? [];
    } else if (json.containsKey('items')) {
      resultsList = json['items'] as List<dynamic>? ?? [];
    } else if (json['results'] is List) {
      resultsList = json['results'] as List;
    }

    return PagedUsuarios(
      items: resultsList.map((e) => AdminUsuario.fromJson(e as Map<String, dynamic>)).toList(),
      pageNumber: json['currentPage'] ?? json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalRecords'] ?? json['totalCount'] ?? resultsList.length,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  factory PagedUsuarios.empty() {
    return const PagedUsuarios(
      items: [],
      pageNumber: 1,
      pageSize: 10,
      totalCount: 0,
      totalPages: 0,
    );
  }
}
