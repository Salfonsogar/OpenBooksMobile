class LoginResponse {
  final String token;
  final String username;
  final String correo;
  final String? fotoPerfilUrl;

  LoginResponse({
    required this.token,
    required this.username,
    required this.correo,
    this.fotoPerfilUrl,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      username: json['username'] as String,
      correo: json['correo'] as String,
      fotoPerfilUrl: json['fotoPerfilUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
      'correo': correo,
      'fotoPerfilUrl': fotoPerfilUrl,
    };
  }
}
