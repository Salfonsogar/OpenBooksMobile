class Usuario {
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

  Usuario({
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

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'estado': estado,
      'sancionado': sancionado,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'nombreRol': nombreRol,
      'rolId': rolId,
      'fotoPerfil': fotoPerfilBase64,
    };
  }

  bool get isAdmin => nombreRol == 'Administrador';
}
