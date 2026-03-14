class ApiConstants {
  ApiConstants._();

  // Auth
  static const String login = '/api/Usuarios/Login';
  static const String register = '/api/Usuarios/Register';
  static const String solicitarRecuperacion = '/api/Usuarios/SolicitarRecuperacion';
  static const String resetearContrasena = '/api/Usuarios/ResetearContrasena';

  // Usuarios
  static const String usuarios = '/api/Usuarios';
  static String usuarioById(int id) => '/api/Usuarios/$id';

  // Libros
  static const String libros = '/api/Libros';
  static String libroById(int id) => '/api/Libros/$id';
  static String libroDetalle(int id) => '/api/Libros/$id/detalle';
  static String libroPortada(int id) => '/api/Libros/$id/portada';
  static String libroDescargar(int id) => '/api/Libros/$id/descargar';
  static String libroManifest(int id) => '/api/Libros/$id/epub/manifest';
  static String libroResource(int id) => '/api/Libros/$id/epub/resource';
  static const String libroUpload = '/api/Libros/upload';

  // Biblioteca
  static String bibliotecaLibros(int usuarioId) => '/api/Biblioteca/$usuarioId/libros';
  static String bibliotecaAgregar(int usuarioId, int libroId) => '/api/Biblioteca/$usuarioId/libros/$libroId';

  // Valoraciones
  static const String valoraciones = '/api/Valoraciones';
  static String valoracionesLibro(int id) => '/api/Valoraciones/libro/$id';
  static const String valoracionesTop5 = '/api/Valoraciones/top5';

  // Reseñas
  static const String resenas = '/api/Resenas';
  static String resenasLibro(int id) => '/api/Resenas/libro/$id';

  // Categorías
  static const String categorias = '/api/Categorias';
  static String categoriaById(int id) => '/api/Categorias/$id';

  // Historial
  static const String historialMisLibros = '/api/Historial/mis-libros';

  // Denuncias
  static const String denuncia = '/api/Denuncia';

  // Sugerencias
  static const String sugerencia = '/api/Sugerencia';

  // Sanciones
  static const String sancion = '/api/Sancion';
  static String sancionUsuario(int id) => '/api/Sancion/usuario/$id';

  // Roles
  static const String roles = '/api/Rols';
}
