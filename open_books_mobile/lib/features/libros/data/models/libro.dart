class Libro {
  final int id;
  final String titulo;
  final String autor;
  final String descripcion;
  final String? portadaUrl;
  final String archivoUrl;
  final bool esPublico;
  final DateTime? fechaCreacion;
  final String? usuarioCreadorId;
  final double promedioValoracion;
  final int totalValoraciones;
  final List<String> categorias;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.descripcion,
    this.portadaUrl,
    required this.archivoUrl,
    this.esPublico = true,
    this.fechaCreacion,
    this.usuarioCreadorId,
    this.promedioValoracion = 0.0,
    this.totalValoraciones = 0,
    required this.categorias,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] as int? ?? json['Id'] as int? ?? 0,
      titulo: json['titulo'] as String? ?? json['Titulo'] as String? ?? '',
      autor: json['autor'] as String? ?? json['Autor'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? json['Descripcion'] as String? ?? '',
      portadaUrl: json['portadaUrl'] as String? ?? json['PortadaUrl'] as String?,
      archivoUrl: json['archivoUrl'] as String? ?? json['ArchivoUrl'] as String? ?? '',
      esPublico: json['esPublico'] as bool? ?? json['EsPublico'] as bool? ?? true,
      fechaCreacion: (json['fechaCreacion'] ?? json['FechaCreacion']) != null
          ? DateTime.parse((json['fechaCreacion'] ?? json['FechaCreacion']) as String)
          : null,
      usuarioCreadorId: json['usuarioCreadorId'] as String? ?? json['UsuarioCreadorId'] as String?,
      promedioValoracion: ((json['promedioValoracion'] ?? json['PromedioValoracion']) as num?)?.toDouble() ?? 0.0,
      totalValoraciones: json['totalValoraciones'] as int? ?? json['TotalValoraciones'] as int? ?? 0,
      categorias: (json['categorias'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['Categorias'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'descripcion': descripcion,
      'portadaUrl': portadaUrl,
      'archivoUrl': archivoUrl,
      'esPublico': esPublico,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'usuarioCreadorId': usuarioCreadorId,
      'promedioValoracion': promedioValoracion,
      'totalValoraciones': totalValoraciones,
      'categorias': categorias,
    };
  }
}
