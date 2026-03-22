import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../usuarios/data/datasources/admin_usuarios_datasource.dart';
import '../../../usuarios/data/models/admin_usuario.dart';
import '../../../libros/data/datasources/admin_libros_datasource.dart';
import '../../../libros/data/models/admin_libro.dart';
import '../../../moderacion/data/datasources/admin_denuncias_datasource.dart';
import '../../../moderacion/data/models/admin_denuncia.dart';
import '../../../sugerencias/data/datasources/admin_sugerencias_datasource.dart';
import '../../../sugerencias/data/models/admin_sugerencia.dart';
import '../../data/models/admin_stats.dart';

class AdminDashboardDataSource {
  late final Dio _dio;
  late final AdminUsuariosDataSource _usuariosDataSource;
  late final AdminLibrosDataSource _librosDataSource;
  late final AdminDenunciasDataSource _denunciasDataSource;
  late final AdminSugerenciasDataSource _sugerenciasDataSource;

  AdminDashboardDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5201',
        connectTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _usuariosDataSource = AdminUsuariosDataSource();
    _librosDataSource = AdminLibrosDataSource();
    _denunciasDataSource = AdminDenunciasDataSource();
    _sugerenciasDataSource = AdminSugerenciasDataSource();
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _usuariosDataSource.setToken(token);
    _librosDataSource.setToken(token);
    _denunciasDataSource.setToken(token);
    _sugerenciasDataSource.setToken(token);
  }

  Future<AdminStats> getStats() async {
    try {
      final results = await Future.wait([
        _usuariosDataSource.getUsuarios(pageNumber: 1, pageSize: 1),
        _librosDataSource.getLibros(pageNumber: 1, pageSize: 1),
        _denunciasDataSource.getDenuncias(pageNumber: 1, pageSize: 1),
        _sugerenciasDataSource.getSugerencias(pageNumber: 1, pageSize: 1),
      ]);

      final pagedUsuarios = results[0] as PagedUsuarios;
      final pagedLibros = results[1] as PagedLibros;
      final pagedDenuncias = results[2] as PagedDenuncias;
      final pagedSugerencias = results[3] as PagedSugerencias;

      return AdminStats(
        totalUsuarios: pagedUsuarios.totalCount,
        totalLibros: pagedLibros.totalCount,
        denunciasPendientes: pagedDenuncias.totalCount,
        sugerenciasNuevas: pagedSugerencias.totalCount,
        sancionesActivas: 0,
      );
    } catch (e) {
      return AdminStats.empty;
    }
  }
}
