class RegisterRequest {
  final String nombreUsuario;
  final String correo;
  final String contrasena;
  final int rolId;
  final String nombreCompleto;

  RegisterRequest({
    required this.nombreUsuario,
    required this.correo,
    required this.contrasena,
    required this.rolId,
    required this.nombreCompleto,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreUsuario': nombreUsuario,
      'correo': correo,
      'Contraseña': contrasena,
      'rolId': rolId,
      'nombreCompleto': nombreCompleto,
    };
  }
}
