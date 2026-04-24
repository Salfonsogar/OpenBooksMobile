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
    if (userName != null && userName!.isNotEmpty) map['userName'] = userName;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (nombreCompleto != null && nombreCompleto!.isNotEmpty) map['nombreCompleto'] = nombreCompleto;
    if (fotoPerfilBase64 != null && fotoPerfilBase64!.isNotEmpty) map['fotoPerfilBase64'] = fotoPerfilBase64;
    return map;
  }
}
