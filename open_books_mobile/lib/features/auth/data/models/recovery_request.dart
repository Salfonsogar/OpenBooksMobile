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
  final String token;
  final String nuevaContrasena;

  ResetPasswordRequest({
    required this.token,
    required this.nuevaContrasena,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'nuevaContrasena': nuevaContrasena,
    };
  }
}
