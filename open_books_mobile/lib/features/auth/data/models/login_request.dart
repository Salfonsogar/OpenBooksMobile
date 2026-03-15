class LoginRequest {
  final String correo;
  final String contrasena;

  LoginRequest({
    required this.correo,
    required this.contrasena,
  });

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'contrasena': contrasena,
    };
  }
}
