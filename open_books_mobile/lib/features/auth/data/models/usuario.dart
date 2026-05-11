class Usuario {
  final String id;
  final String userName;
  final String nombreCompleto;
  final String email;
  final bool estado;
  final DateTime fechaRegistro;
  final String nombreRol;
  final String? fotoPerfilUrl;

  Usuario({
    required this.id,
    required this.userName,
    required this.nombreCompleto,
    required this.email,
    required this.estado,
    required this.fechaRegistro,
    required this.nombreRol,
    this.fotoPerfilUrl,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String? ?? json['Id'] as String? ?? '',
      userName: json['userName'] as String? ?? json['UserName'] as String? ?? '',
      nombreCompleto: json['nombreCompleto'] as String? ?? json['NombreCompleto'] as String? ?? '',
      email: json['email'] as String? ?? json['Email'] as String? ?? '',
      estado: json['estado'] as bool? ?? json['Estado'] as bool? ?? true,
      fechaRegistro: (json['fechaRegistro'] ?? json['FechaRegistro']) != null
          ? DateTime.parse((json['fechaRegistro'] ?? json['FechaRegistro']) as String)
          : DateTime.now(),
      nombreRol: json['nombreRol'] as String? ?? json['NombreRol'] as String? ?? 'Usuario',
      fotoPerfilUrl: json['fotoPerfilUrl'] as String? ?? json['FotoPerfilUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'estado': estado,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'nombreRol': nombreRol,
      'fotoPerfilUrl': fotoPerfilUrl,
    };
  }

  bool get isAdmin => nombreRol.toLowerCase() == 'administrador';
}
