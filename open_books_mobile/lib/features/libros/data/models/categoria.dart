class Categoria {
  final int id;
  final String nombre;
  final int totalLibros;

  Categoria({
    required this.id,
    required this.nombre,
    this.totalLibros = 0,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as int? ?? json['Id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? json['Nombre'] as String? ?? '',
      totalLibros: json['totalLibros'] as int? ?? json['TotalLibros'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'totalLibros': totalLibros,
    };
  }
}
