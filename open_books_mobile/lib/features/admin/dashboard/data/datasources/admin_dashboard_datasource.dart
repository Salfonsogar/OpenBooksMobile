import '../../../../../shared/services/local_database.dart';
import '../../../usuarios/data/datasources/admin_usuarios_datasource.dart';
import '../../../libros/data/datasources/admin_libros_datasource.dart';
import '../../../moderacion/data/datasources/admin_denuncias_datasource.dart';
import '../../../sugerencias/data/datasources/admin_sugerencias_datasource.dart';
import '../../../sugerencias/data/models/admin_sugerencia.dart';
import '../models/admin_stats.dart';

class AdminDashboardDataSource {
  late AdminUsuariosDataSource _usuariosDataSource;
  late AdminLibrosDataSource _librosDataSource;
  late AdminDenunciasDataSource _denunciasDataSource;
  late AdminSugerenciasDataSource _sugerenciasDataSource;
  LocalDatabase? _localDatabase;

  AdminDashboardDataSource();

  void setDependencies({
    required LocalDatabase localDatabase,
    required String token,
  }) {
    _localDatabase = localDatabase;
    _usuariosDataSource = AdminUsuariosDataSource()..setToken(token);
    _librosDataSource = AdminLibrosDataSource()..setToken(token);
    _denunciasDataSource = AdminDenunciasDataSource()..setToken(token);
    _sugerenciasDataSource = AdminSugerenciasDataSource()..setToken(token);
  }

  Future<AdminStats> getStats() async {
    try {
      final results = await Future.wait([
        _usuariosDataSource.getUsuarios(pageNumber: 1, pageSize: 1),
        _librosDataSource.getLibros(pageNumber: 1, pageSize: 1),
        _denunciasDataSource.getDenuncias(pageNumber: 1, pageSize: 1),
        _sugerenciasDataSource.getSugerencias(pageNumber: 1, pageSize: 1),
        _getLocalAnalytics(),
      ]);

      final pagedUsuarios = results[0] as dynamic;
      final pagedLibros = results[1] as dynamic;
      final pagedDenuncias = results[2] as dynamic;
      final pagedSugerencias = results[3] as PagedSugerencias;
      final localAnalytics = results[4] as LocalAnalyticsData;

      return AdminStats(
        totalUsuarios: pagedUsuarios.totalCount as int,
        totalLibros: pagedLibros.totalCount as int,
        denunciasPendientes: pagedDenuncias.totalCount as int,
        sugerenciasNuevas: pagedSugerencias.totalCount,
        sancionesActivas: 0,
        usuariosActivos: localAnalytics.usuariosActivos,
        librosEnBiblioteca: localAnalytics.librosEnBiblioteca,
        paginasLeidasHoy: localAnalytics.paginasLeidasHoy,
        paginasLeidasSemana: localAnalytics.paginasLeidasSemana,
        paginasLeidasMes: localAnalytics.paginasLeidasMes,
        ratingPromedio: 0.0,
        topLibros: localAnalytics.topLibros,
        distribucionCategorias: localAnalytics.distribucionCategorias,
        evolucionLectura: localAnalytics.evolucionLectura,
      );
    } catch (e) {
      return AdminStats.empty;
    }
  }

  Future<LocalAnalyticsData> _getLocalAnalytics() async {
    if (_localDatabase == null || !_localDatabase!.isInitialized) {
      return LocalAnalyticsData.empty;
    }

    final db = _localDatabase!;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: todayStart.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    int paginasLeidasHoy = 0;
    int paginasLeidasSemana = 0;
    int paginasLeidasMes = 0;
    int usuariosActivos = 0;
    int librosEnBiblioteca = 0;
    List<LibroPopularData> topLibros = [];
    List<CategoriaData> distribucionCategorias = [];
    List<LecturaDiariaData> evolucionLectura = [];

    try {
      final todayMs = todayStart.millisecondsSinceEpoch;
      final weekMs = weekStart.millisecondsSinceEpoch;
      final monthMs = monthStart.millisecondsSinceEpoch;

      paginasLeidasHoy = await db.readingSessionsDataSource.getTotalPagesInRange(todayMs);
      paginasLeidasSemana = await db.readingSessionsDataSource.getTotalPagesInRange(weekMs);
      paginasLeidasMes = await db.readingSessionsDataSource.getTotalPagesInRange(monthMs);
      usuariosActivos = await db.readingSessionsDataSource.getActiveUsersCount(monthMs);
      librosEnBiblioteca = await db.bibliotecaLocalDataSource.getCount();

      final topLibrosResults = await db.readingSessionsDataSource.getTopLibros();
      topLibros = topLibrosResults.map((row) => LibroPopularData(
        libroId: row.libroId,
        titulo: row.titulo,
        totalLecturas: row.totalLecturas,
        paginasLeidas: row.paginasLeidas,
      )).toList();

      final catResults = await db.bibliotecaLocalDataSource.getDistribucionCategorias();
      distribucionCategorias = catResults.map((row) => CategoriaData(
        nombre: row.nombre,
        cantidad: row.cantidad,
        porcentaje: row.porcentaje,
      )).toList();

      final evolResults = await db.readingSessionsDataSource.getEvolucionLectura(
        monthStart.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
      evolucionLectura = evolResults.map((row) => LecturaDiariaData(
        fecha: row.fecha,
        paginasLeidas: row.paginasLeidas,
        sesiones: row.sesiones,
      )).toList();
    } catch (_) {}

    return LocalAnalyticsData(
      paginasLeidasHoy: paginasLeidasHoy,
      paginasLeidasSemana: paginasLeidasSemana,
      paginasLeidasMes: paginasLeidasMes,
      usuariosActivos: usuariosActivos,
      librosEnBiblioteca: librosEnBiblioteca,
      topLibros: topLibros,
      distribucionCategorias: distribucionCategorias,
      evolucionLectura: evolucionLectura,
    );
  }
}

class LocalAnalyticsData {
  final int paginasLeidasHoy;
  final int paginasLeidasSemana;
  final int paginasLeidasMes;
  final int usuariosActivos;
  final int librosEnBiblioteca;
  final List<LibroPopularData> topLibros;
  final List<CategoriaData> distribucionCategorias;
  final List<LecturaDiariaData> evolucionLectura;

  const LocalAnalyticsData({
    required this.paginasLeidasHoy,
    required this.paginasLeidasSemana,
    required this.paginasLeidasMes,
    required this.usuariosActivos,
    required this.librosEnBiblioteca,
    required this.topLibros,
    required this.distribucionCategorias,
    required this.evolucionLectura,
  });

  static const empty = LocalAnalyticsData(
    paginasLeidasHoy: 0,
    paginasLeidasSemana: 0,
    paginasLeidasMes: 0,
    usuariosActivos: 0,
    librosEnBiblioteca: 0,
    topLibros: [],
    distribucionCategorias: [],
    evolucionLectura: [],
  );
}