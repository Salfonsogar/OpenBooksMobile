import 'package:equatable/equatable.dart';

class CreateUserLibroRequest extends Equatable {
  final String titulo;
  final String autor;
  final String? descripcion;
  final List<int> categoriasIds;
  final String? portadaBase64;
  final String? archivoBase64;
  final String? nombreArchivo;

  const CreateUserLibroRequest({
    required this.titulo,
    required this.autor,
    this.descripcion,
    required this.categoriasIds,
    this.portadaBase64,
    this.archivoBase64,
    this.nombreArchivo,
  });

  Map<String, dynamic> toFormData() {
    return {
      'titulo': titulo,
      'autor': autor,
      if (descripcion != null) 'descripcion': descripcion,
      'categoriasIds': categoriasIds,
      if (portadaBase64 != null) 'portada': portadaBase64,
      if (archivoBase64 != null) 'archivo': archivoBase64,
      if (nombreArchivo != null) 'nombreArchivo': nombreArchivo,
    };
  }

  @override
  List<Object?> get props => [
        titulo,
        autor,
        descripcion,
        categoriasIds,
        portadaBase64,
        archivoBase64,
        nombreArchivo,
      ];
}
