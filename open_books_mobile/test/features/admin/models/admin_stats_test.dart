import 'package:flutter_test/flutter_test.dart';

import 'package:open_books_mobile/features/admin/dashboard/data/models/admin_stats.dart';

void main() {
  group('AdminStats', () {
    test('fromJson creates AdminStats correctly', () {
      final json = {
        'totalUsuarios': 100,
        'totalLibros': 50,
        'denunciasPendientes': 5,
        'sugerenciasNuevas': 3,
        'sancionesActivas': 2,
        'usuariosActivos': 80,
        'librosEnBiblioteca': 200,
        'paginasLeidasHoy': 1000,
        'paginasLeidasSemana': 7000,
        'paginasLeidasMes': 30000,
        'ratingPromedio': 4.5,
        'topLibros': const <Map<String, dynamic>>[],
        'distribucionCategorias': const <Map<String, dynamic>>[],
        'evolucionLectura': const <Map<String, dynamic>>[],
      };

      final stats = AdminStats.fromJson(json);

      expect(stats.totalUsuarios, 100);
      expect(stats.totalLibros, 50);
      expect(stats.denunciasPendientes, 5);
      expect(stats.sugerenciasNuevas, 3);
      expect(stats.sancionesActivas, 2);
      expect(stats.usuariosActivos, 80);
      expect(stats.librosEnBiblioteca, 200);
      expect(stats.paginasLeidasHoy, 1000);
      expect(stats.paginasLeidasSemana, 7000);
      expect(stats.paginasLeidasMes, 30000);
      expect(stats.ratingPromedio, 4.5);
      expect(stats.topLibros, isEmpty);
      expect(stats.distribucionCategorias, isEmpty);
      expect(stats.evolucionLectura, isEmpty);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final stats = AdminStats.fromJson(json);

      expect(stats.totalUsuarios, 0);
      expect(stats.totalLibros, 0);
      expect(stats.ratingPromedio, 0.0);
      expect(stats.topLibros, isEmpty);
    });

    test('empty constant has all zeros', () {
      expect(AdminStats.empty.totalUsuarios, 0);
      expect(AdminStats.empty.totalLibros, 0);
      expect(AdminStats.empty.topLibros, isEmpty);
      expect(AdminStats.empty.distribucionCategorias, isEmpty);
      expect(AdminStats.empty.evolucionLectura, isEmpty);
    });

    test('supports value equality', () {
      final stats1 = AdminStats(
        totalUsuarios: 100,
        totalLibros: 50,
        denunciasPendientes: 5,
        sugerenciasNuevas: 3,
        sancionesActivas: 2,
        usuariosActivos: 80,
        librosEnBiblioteca: 200,
        paginasLeidasHoy: 1000,
        paginasLeidasSemana: 7000,
        paginasLeidasMes: 30000,
        ratingPromedio: 4.5,
        topLibros: const [],
        distribucionCategorias: const [],
        evolucionLectura: const [],
      );
      final stats2 = AdminStats(
        totalUsuarios: 100,
        totalLibros: 50,
        denunciasPendientes: 5,
        sugerenciasNuevas: 3,
        sancionesActivas: 2,
        usuariosActivos: 80,
        librosEnBiblioteca: 200,
        paginasLeidasHoy: 1000,
        paginasLeidasSemana: 7000,
        paginasLeidasMes: 30000,
        ratingPromedio: 4.5,
        topLibros: const [],
        distribucionCategorias: const [],
        evolucionLectura: const [],
      );

      expect(stats1, equals(stats2));
    });
  });
}
