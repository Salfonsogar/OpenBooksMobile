class RegisterRequest {
  final String userName;
  final String correo;
  final String contrasena;

  RegisterRequest({
    required this.userName,
    required this.correo,
    required this.contrasena,
  });

  Map<String, dynamic> toJson() {
    return {
      'UserName': userName,
      'Correo': correo,
      'Contrasena': contrasena,
    };
  }
}
