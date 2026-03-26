class DenunciaResena {
  final int id;
  final int idDenunciante;
  final String nombreDenunciante;
  final int idDenunciado;
  final String nombreDenunciado;
  final String comentario;
  final int? idResena;
  final String? motivo;

  DenunciaResena({
    required this.id,
    required this.idDenunciante,
    required this.nombreDenunciante,
    required this.idDenunciado,
    required this.nombreDenunciado,
    required this.comentario,
    this.idResena,
    this.motivo,
  });

  factory DenunciaResena.fromJson(Map<String, dynamic> json) {
    return DenunciaResena(
      id: json['id'] as int,
      idDenunciante: json['idDenunciante'] as int? ?? 0,
      nombreDenunciante: json['nombreDenunciante'] as String? ?? '',
      idDenunciado: json['idDenunciado'] as int? ?? 0,
      nombreDenunciado: json['nombreDenunciado'] as String? ?? '',
      comentario: json['comentario'] as String? ?? '',
      idResena: json['idResena'] as int?,
      motivo: json['motivo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idDenunciante': idDenunciante,
      'nombreDenunciante': nombreDenunciante,
      'idDenunciado': idDenunciado,
      'nombreDenunciado': nombreDenunciado,
      'comentario': comentario,
      'idResena': idResena,
      'motivo': motivo,
    };
  }
}

class DenunciaCreate {
  final int idDenunciante;
  final int idDenunciado;
  final String comentario;
  final int idResena;
  final String motivo;

  DenunciaCreate({
    required this.idDenunciante,
    required this.idDenunciado,
    required this.comentario,
    required this.idResena,
    required this.motivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'idDenunciante': idDenunciante,
      'idDenunciado': idDenunciado,
      'comentario': comentario,
      'idResena': idResena,
      'motivo': motivo,
    };
  }
}

const List<String> motivosDenuncia = [
  'Contenido inapropiado',
  'Spam o publicidad',
  'Lenguaje ofensivo o abusivo',
  'Información falsa o engañosa',
  'No relacionado con el libro',
  'Otro',
];
