import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/admin/dashboard/data/models/admin_stats.dart';
import 'package:open_books_mobile/features/admin/dashboard/data/repositories/admin_dashboard_repository.dart';
import 'package:open_books_mobile/features/admin/dashboard/logic/cubit/admin_dashboard_cubit.dart';
import 'package:open_books_mobile/features/admin/dashboard/logic/cubit/admin_dashboard_state.dart';
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/services/local_database.dart';

class MockAdminDashboardRepository extends Mock implements AdminDashboardRepository {}

class MockLocalDatabase extends Mock implements LocalDatabase {}

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  late MockAdminDashboardRepository repository;
  late MockLocalDatabase localDatabase;
  late MockSessionCubit sessionCubit;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async => null,
    );
  });

  setUp(() {
    repository = MockAdminDashboardRepository();
    localDatabase = MockLocalDatabase();
    sessionCubit = MockSessionCubit();
  });

  final stats = AdminStats(
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

  group('AdminDashboardCubit', () {
    blocTest<AdminDashboardCubit, AdminDashboardState>(
      'initial state is AdminDashboardInitial',
      build: () => AdminDashboardCubit(
        repository,
        localDatabase: localDatabase,
        sessionCubit: sessionCubit,
      ),
      verify: (cubit) => expect(cubit.state, isA<AdminDashboardInitial>()),
    );

    blocTest<AdminDashboardCubit, AdminDashboardState>(
      'loadStats success emits [AdminDashboardLoading, AdminDashboardLoaded]',
      setUp: () {
        when(() => repository.getStats()).thenAnswer((_) async => stats);
      },
      build: () => AdminDashboardCubit(
        repository,
        localDatabase: localDatabase,
        sessionCubit: sessionCubit,
      ),
      act: (cubit) => cubit.loadStats(),
      expect: () => [
        isA<AdminDashboardLoading>(),
        isA<AdminDashboardLoaded>().having(
          (s) => s.stats.totalUsuarios,
          'totalUsuarios',
          100,
        ),
      ],
    );

    blocTest<AdminDashboardCubit, AdminDashboardState>(
      'loadStats failure emits [AdminDashboardLoading, AdminDashboardError]',
      setUp: () {
        when(() => repository.getStats()).thenThrow(Exception('Error'));
      },
      build: () => AdminDashboardCubit(
        repository,
        localDatabase: localDatabase,
        sessionCubit: sessionCubit,
      ),
      act: (cubit) => cubit.loadStats(),
      expect: () => [
        isA<AdminDashboardLoading>(),
        isA<AdminDashboardError>().having(
          (s) => s.message,
          'message',
          'Exception: Error',
        ),
      ],
    );
  });
}
