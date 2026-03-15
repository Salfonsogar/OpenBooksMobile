import 'usuario.dart';

class LoginResponse {
  final Usuario usuario;
  final String token;

  LoginResponse({
    required this.usuario,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario.toJson(),
      'token': token,
    };
  }
}
