import '../datasources/index.dart';
import '../models/index.dart';

class LibrosRepository {
  final LibrosDataSource _librosDataSource;
  final CategoriasDataSource _categoriasDataSource;
  final ValoracionesDataSource _valoracionesDataSource;
  final ResenasDataSource _resenasDataSource;

  LibrosRepository(
    this._librosDataSource,
    this._categoriasDataSource,
    this._valoracionesDataSource,
    this._resenasDataSource,
  );

  Future<List<Libro>> getCatalogo() {
    return _librosDataSource.getCatalogo();
  }

  Future<PagedResult<Libro>> getLibrosPaged({
    String? query,
    int page = 1,
    int pageSize = 10,
    List<int>? categorias,
    String? autor,
  }) {
    return _librosDataSource.getLibrosPaged(
      query: query,
      page: page,
      pageSize: pageSize,
      categorias: categorias,
      autor: autor,
    );
  }

  Future<Libro?> getLibroById(int id) {
    return _librosDataSource.getLibroById(id);
  }

  Future<LibroDetalle?> getLibroDetalle(int id) async {
    final libro = await _librosDataSource.getLibroById(id);
    if (libro == null) return null;
    return LibroDetalle.fromLibro(libro);
  }

  Future<PagedResult<Categoria>> getCategorias({int pageNumber = 1, int pageSize = 50}) {
    return _categoriasDataSource.getCategorias(pageNumber: pageNumber, pageSize: pageSize);
  }

  Future<void> crearValoracion(int libroId, int puntuacion) {
    return _valoracionesDataSource.crearValoracion(libroId, puntuacion);
  }

  Future<void> actualizarValoracion(int libroId, int puntuacion) {
    return _valoracionesDataSource.actualizarValoracion(libroId, puntuacion);
  }

  Future<void> eliminarValoracion(int libroId) {
    return _valoracionesDataSource.eliminarValoracion(libroId);
  }

  Future<Resena> crearResena(int libroId, String texto) {
    return _resenasDataSource.crearResena(libroId, texto);
  }

  Future<Resena> actualizarResena(int idResena, String texto) {
    return _resenasDataSource.actualizarResena(idResena, texto);
  }

  Future<void> eliminarResena(int idResena) {
    return _resenasDataSource.eliminarResena(idResena);
  }

  Future<PagedResult<Resena>> getResenasLibro(int idLibro, {int page = 1, int pageSize = 5}) {
    return _resenasDataSource.getResenasLibro(idLibro, page: page, pageSize: pageSize);
  }

  Future<List<Libro>> getTop5Libros() {
    return _valoracionesDataSource.getTop5Libros();
  }

  Future<List<Libro>> getLibrosAleatorios({int limit = 10}) async {
    final result = await _librosDataSource.getCatalogo();
    final libros = result.toList();
    libros.shuffle();
    return libros.take(limit).toList();
  }

  Future<DenunciaResena> crearDenunciaResena({
    required String idDenunciante,
    required String idDenunciado,
    required int idResena,
    required String motivo,
    String? comentario,
  }) {
    return _resenasDataSource.crearDenunciaResena(
      idDenunciante: idDenunciante,
      idDenunciado: idDenunciado,
      idResena: idResena,
      motivo: motivo,
      comentario: comentario,
    );
  }
}
