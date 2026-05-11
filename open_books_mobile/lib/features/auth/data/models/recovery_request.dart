class RecoveryRequest {
  final String correo;

  RecoveryRequest({required this.correo});

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
    };
  }
}

class ResetPasswordRequest {
  final String email;
  final String token;
  final String nuevaContrasena;

  ResetPasswordRequest({
    required this.email,
    required this.token,
    required this.nuevaContrasena,
  });

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'Token': token,
      'NuevaContrase\u00f1a': nuevaContrasena,
    };
  }
}
