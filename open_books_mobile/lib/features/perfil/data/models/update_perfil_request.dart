class UpdatePerfilRequest {
  final String? userName;
  final String? email;
  final String? nombreCompleto;
  final String? fotoPerfilBase64;

  UpdatePerfilRequest({
    this.userName,
    this.email,
    this.nombreCompleto,
    this.fotoPerfilBase64,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (userName != null) map['userName'] = userName;
    if (email != null) map['email'] = email;
    if (nombreCompleto != null) map['nombreCompleto'] = nombreCompleto;
    if (fotoPerfilBase64 != null) map['fotoPerfil'] = fotoPerfilBase64;
    return map;
  }
}
