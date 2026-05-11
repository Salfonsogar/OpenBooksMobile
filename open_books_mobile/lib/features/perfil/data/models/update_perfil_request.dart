class UpdatePerfilRequest {
  final String? userName;
  final String? email;
  final String? nombreCompleto;
  final String? fotoPerfilUrl;

  UpdatePerfilRequest({
    this.userName,
    this.email,
    this.nombreCompleto,
    this.fotoPerfilUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (userName != null) map['userName'] = userName;
    if (email != null) map['email'] = email;
    if (nombreCompleto != null) map['nombreCompleto'] = nombreCompleto;
    if (fotoPerfilUrl != null) map['fotoPerfilUrl'] = fotoPerfilUrl;
    return map;
  }
}
