import 'package:open_books_mobile/shared/core/environment/env.dart';

class ApiConstants {
  ApiConstants._();

  static String get _baseUrl => Env().apiBaseUrl;

  // Auth
  static const String login = '/api/Auth/login';
  static const String register = '/api/Auth/register';

  // Usuarios
  static const String usuarios = '/api/Usuario';
  static String usuarioById(String id) => '/api/Usuario/$id';
  static const String usuarioUploadFoto = '/api/Usuario/upload-foto';
  static const String solicitarRecuperacion = '/api/Usuario/solicitar-recuperacion';
  static const String resetearContrasena = '/api/Usuario/reset-password';

  // Libros
  static const String libros = '/api/Libro';
  static String libroById(int id) => '/api/Libro/$id';
  static const String librosPaged = '/api/Libro/paged';
  static String libroDescargar(int id) => '/api/Libro/$id/descargar';
  static const String libroUploadLibro = '/api/Libro/upload-libro';
  static const String libroUploadPortada = '/api/Libro/upload-portada';

  // Biblioteca / UsuarioLibro
  static const String usuarioLibroBiblioteca = '/api/UsuarioLibro/biblioteca';
  static String usuarioLibroById(int libroId) => '/api/UsuarioLibro/$libroId';
  static const String usuarioLibroProgreso = '/api/UsuarioLibro/progreso';
  static String usuarioLibroFavorito(int libroId) => '/api/UsuarioLibro/favorito/$libroId';

  // Valoraciones
  static const String valoraciones = '/api/Valoraciones';
  static String valoracionesLibro(int id) => '/api/Valoraciones/libro/$id';
  static const String valoracionesTop5 = '/api/Valoraciones/top5';

  // Reseñas
  static const String resenas = '/api/Resena';
  static String resenasLibro(int id) => '/api/Resena/libro/$id';

  // Categorías
  static const String categorias = '/api/Categorias';
  static String categoriaById(int id) => '/api/Categorias/$id';

  // Denuncias
  static const String denuncia = '/api/Denuncia';

  // Sugerencias
  static const String sugerencia = '/api/Sugerencia';

  // Epub
  static String epubManifest(int libroId) => '/api/epub/$libroId/manifest';
  static String epubResource(int libroId) => '/api/epub/$libroId/resource';

  // Marcadores
  static const String marcadores = '/api/Marcadores';
  static const String marcadoresUsuario = '/api/Marcadores/usuario';
  static String marcadoresLibro(int libroId) => '/api/Marcadores/libro/$libroId';

  // Resaltadores
  static const String resaltadores = '/api/Resaltadores';
  static const String resaltadoresUsuario = '/api/Resaltadores/usuario';
  static String resaltadoresLibro(int libroId) => '/api/Resaltadores/libro/$libroId';

  // Reader
  static String libroResourceUrl(int libroId, String path) =>
      '$_baseUrl/api/epub/$libroId/resource?path=${Uri.encodeComponent(path)}';
}
