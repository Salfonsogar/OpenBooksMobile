import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_datasource.dart';
import 'features/auth/data/datasources/roles_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/repositories/roles_repository.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/libros/data/datasources/datasources.dart';
import 'features/libros/data/repositories/libros_repository.dart';
import 'features/libros/logic/cubit/cubit.dart';
import 'features/biblioteca/data/datasources/biblioteca_datasource.dart';
import 'features/biblioteca/data/repositories/biblioteca_repository_impl.dart';
import 'features/biblioteca/domain/usecases/get_biblioteca_usecase.dart';
import 'features/biblioteca/domain/usecases/add_libro_biblioteca_usecase.dart';
import 'features/biblioteca/domain/usecases/remove_libro_biblioteca_usecase.dart';
import 'features/biblioteca/logic/cubit/biblioteca_cubit.dart';
import 'features/biblioteca/logic/cubit/upload_libro_cubit.dart';
import 'features/perfil/data/datasources/perfil_datasource.dart';
import 'features/perfil/data/repositories/perfil_repository.dart';
import 'features/perfil/logic/cubit/perfil_cubit.dart';
import 'features/historial/data/datasources/historial_datasource.dart';
import 'features/historial/data/repositories/historial_repository_impl.dart';
import 'features/historial/domain/usecases/get_historial_usecase.dart';
import 'features/historial/domain/usecases/add_to_historial_usecase.dart';
import 'features/historial/logic/cubit/historial_cubit.dart';
import 'features/reader/data/datasources/bookmark_datasource.dart';
import 'features/reader/data/datasources/epub_datasource.dart';
import 'features/reader/data/repositories/bookmark_repository.dart';
import 'features/reader/data/repositories/epub_repository.dart';
import 'features/reader/logic/cubit/bookmark_cubit.dart';
import 'features/reader/logic/cubit/reader_settings_cubit.dart';
import 'features/notifications/logic/cubit/notification_cubit.dart';
import 'features/admin/dashboard/data/datasources/admin_dashboard_datasource.dart';
import 'features/admin/dashboard/data/repositories/admin_dashboard_repository.dart';
import 'features/admin/dashboard/logic/cubit/admin_dashboard_cubit.dart';
import 'features/admin/usuarios/data/datasources/admin_usuarios_datasource.dart';
import 'features/admin/usuarios/data/repositories/admin_usuarios_repository.dart';
import 'features/admin/usuarios/logic/cubit/admin_usuarios_cubit.dart';
import 'features/admin/libros/data/datasources/admin_libros_datasource.dart';
import 'features/admin/libros/data/repositories/admin_libros_repository.dart';
import 'features/admin/libros/logic/cubit/admin_libros_cubit.dart';
import 'features/admin/categorias/data/datasources/admin_categorias_datasource.dart';
import 'features/admin/categorias/data/repositories/admin_categorias_repository.dart';
import 'features/admin/categorias/logic/cubit/admin_categorias_cubit.dart';
import 'features/admin/moderacion/data/datasources/admin_denuncias_datasource.dart';
import 'features/admin/moderacion/data/datasources/admin_sanciones_datasource.dart';
import 'features/admin/moderacion/data/datasources/admin_roles_datasource.dart';
import 'features/admin/moderacion/data/repositories/admin_denuncias_repository.dart';
import 'features/admin/moderacion/data/repositories/admin_sanciones_repository.dart';
import 'features/admin/moderacion/data/repositories/admin_roles_repository.dart';
import 'features/admin/moderacion/logic/cubit/admin_denuncias_cubit.dart';
import 'features/admin/moderacion/logic/cubit/admin_sanciones_cubit.dart';
import 'features/admin/moderacion/logic/cubit/admin_roles_cubit.dart';
import 'features/admin/sugerencias/data/datasources/admin_sugerencias_datasource.dart';
import 'features/admin/sugerencias/data/repositories/admin_sugerencias_repository.dart';
import 'features/admin/sugerencias/logic/cubit/admin_sugerencias_cubit.dart';
import 'shared/core/network/api_client.dart';
import 'shared/core/session/session_cubit.dart';
import 'shared/services/network_info.dart';
import 'shared/services/local_database.dart';
import 'shared/services/epub_local_storage_service.dart';
import 'shared/services/sync_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  final localDatabase = LocalDatabase();
  await localDatabase.init();
  getIt.registerLazySingleton<LocalDatabase>(() => localDatabase);

  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  getIt.registerLazySingleton<SessionCubit>(() => SessionCubit());

  getIt.registerLazySingleton<NotificationCubit>(() => NotificationCubit());

  getIt.registerLazySingleton<AuthDataSource>(
    () => AuthDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<RolesDataSource>(
    () => RolesDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthDataSource>()),
  );
  getIt.registerLazySingleton<RolesRepository>(
    () => RolesRepository(getIt<RolesDataSource>()),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      rolesRepository: getIt<RolesRepository>(),
      sessionCubit: getIt<SessionCubit>(),
    ),
  );

  getIt.registerLazySingleton<LibrosDataSource>(
    () => LibrosDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CategoriasDataSource>(
    () => CategoriasDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ValoracionesDataSource>(
    () => ValoracionesDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ResenasDataSource>(
    () => ResenasDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<LibrosRepository>(
    () => LibrosRepository(
      getIt<LibrosDataSource>(),
      getIt<CategoriasDataSource>(),
      getIt<ValoracionesDataSource>(),
      getIt<ResenasDataSource>(),
    ),
  );
  getIt.registerFactory<LibrosCubit>(
    () => LibrosCubit(getIt<LibrosRepository>()),
  );
  getIt.registerFactory<LibroDetalleCubit>(
    () => LibroDetalleCubit(
      getIt<LibrosRepository>(),
      getIt<BibliotecaDataSource>(),
      getIt<SessionCubit>(),
    ),
  );
  getIt.registerFactory<CategoriasCubit>(
    () => CategoriasCubit(getIt<LibrosRepository>()),
  );

  getIt.registerLazySingleton<BibliotecaDataSource>(
    () => BibliotecaDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<PerfilDataSource>(
    () => PerfilDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PerfilRepository>(
    () => PerfilRepository(getIt<PerfilDataSource>()),
  );

  getIt.registerLazySingleton<HistorialDataSource>(
    () => HistorialDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<HistorialRepositoryImpl>(
    () => HistorialRepositoryImpl(
      localDatabase: getIt<LocalDatabase>(),
      remoteDataSource: getIt<HistorialDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GetHistorialUseCase>(
    () => GetHistorialUseCase(getIt<HistorialRepositoryImpl>()),
  );

  getIt.registerLazySingleton<AddToHistorialUseCase>(
    () => AddToHistorialUseCase(getIt<HistorialRepositoryImpl>()),
  );

  getIt.registerLazySingleton<BibliotecaRepositoryImpl>(
    () => BibliotecaRepositoryImpl(
      localDatabase: getIt<LocalDatabase>(),
      remoteDataSource: getIt<BibliotecaDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      librosRepository: getIt<LibrosRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetBibliotecaUseCase>(
    () => GetBibliotecaUseCase(
      getIt<BibliotecaRepositoryImpl>(),
      getIt<BibliotecaRepositoryImpl>(),
      getIt<LibrosRepository>(),
    ),
  );

  getIt.registerLazySingleton<AddLibroBibliotecaUseCase>(
    () => AddLibroBibliotecaUseCase(getIt<BibliotecaRepositoryImpl>()),
  );

  getIt.registerLazySingleton<RemoveLibroBibliotecaUseCase>(
    () => RemoveLibroBibliotecaUseCase(getIt<BibliotecaRepositoryImpl>()),
  );

  getIt.registerLazySingleton<BibliotecaCubit>(
    () => BibliotecaCubit(
      getBibliotecaUseCase: getIt<GetBibliotecaUseCase>(),
      addLibroBibliotecaUseCase: getIt<AddLibroBibliotecaUseCase>(),
      removeLibroBibliotecaUseCase: getIt<RemoveLibroBibliotecaUseCase>(),
      epubLocalStorageService: getIt<EpubLocalStorageService>(),
      sessionCubit: getIt<SessionCubit>(),
    ),
  );

  getIt.registerFactory<UploadLibroCubit>(
    () => UploadLibroCubit(),
  );

  getIt.registerLazySingleton<PerfilCubit>(
    () => PerfilCubit(
      repository: getIt<PerfilRepository>(),
      sessionCubit: getIt<SessionCubit>(),
    ),
  );

  getIt.registerLazySingleton<HistorialCubit>(
    () => HistorialCubit(
      getHistorialUseCase: getIt<GetHistorialUseCase>(),
      addToHistorialUseCase: getIt<AddToHistorialUseCase>(),
      sessionCubit: getIt<SessionCubit>(),
    ),
  );

  getIt.registerLazySingleton<SyncService>(
    () => SyncService(
      localDatabase: getIt<LocalDatabase>(),
      bibliotecaRepository: getIt<BibliotecaRepositoryImpl>(),
      historialRepository: getIt<HistorialRepositoryImpl>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<EpubDataSource>(
    () => EpubDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<EpubRepository>(
    () => EpubRepository(getIt<EpubDataSource>()),
  );
  getIt.registerLazySingleton<EpubLocalStorageService>(
    () => EpubLocalStorageService(
      localDatabase: getIt<LocalDatabase>(),
      epubDataSource: getIt<EpubDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton<ReaderSettingsCubit>(
    () => ReaderSettingsCubit(),
  );
  getIt.registerLazySingleton<BookmarkDataSource>(
    () => BookmarkDataSource(),
  );
  getIt.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepository(getIt<BookmarkDataSource>()),
  );
  getIt.registerLazySingleton<BookmarkCubit>(
    () => BookmarkCubit(getIt<BookmarkRepository>()),
  );

  // Admin Dashboard
  getIt.registerLazySingleton<AdminDashboardDataSource>(
    () => AdminDashboardDataSource(),
  );
  getIt.registerLazySingleton<AdminDashboardRepository>(
    () => AdminDashboardRepository(getIt<AdminDashboardDataSource>()),
  );
  getIt.registerFactory<AdminDashboardCubit>(
    () => AdminDashboardCubit(getIt<AdminDashboardRepository>()),
  );

  // Admin Usuarios
  getIt.registerLazySingleton<AdminUsuariosDataSource>(
    () => AdminUsuariosDataSource(),
  );
  getIt.registerLazySingleton<AdminUsuariosRepository>(
    () => AdminUsuariosRepository(getIt<AdminUsuariosDataSource>()),
  );
  getIt.registerFactory<AdminUsuariosCubit>(
    () => AdminUsuariosCubit(getIt<AdminUsuariosRepository>()),
  );

  // Admin Libros
  getIt.registerLazySingleton<AdminLibrosDataSource>(
    () => AdminLibrosDataSource(),
  );
  getIt.registerLazySingleton<AdminLibrosRepository>(
    () => AdminLibrosRepository(getIt<AdminLibrosDataSource>()),
  );
  getIt.registerFactory<AdminLibrosCubit>(
    () => AdminLibrosCubit(getIt<AdminLibrosRepository>()),
  );

  // Admin Categorías
  getIt.registerLazySingleton<AdminCategoriasDataSource>(
    () => AdminCategoriasDataSource(),
  );
  getIt.registerLazySingleton<AdminCategoriasRepository>(
    () => AdminCategoriasRepository(getIt<AdminCategoriasDataSource>()),
  );
  getIt.registerFactory<AdminCategoriasCubit>(
    () => AdminCategoriasCubit(getIt<AdminCategoriasRepository>()),
  );

  // Admin Moderación (Denuncias)
  getIt.registerLazySingleton<AdminDenunciasDataSource>(
    () => AdminDenunciasDataSource(),
  );
  getIt.registerLazySingleton<AdminDenunciasRepository>(
    () => AdminDenunciasRepository(getIt<AdminDenunciasDataSource>()),
  );
  getIt.registerFactory<AdminDenunciasCubit>(
    () => AdminDenunciasCubit(getIt<AdminDenunciasRepository>()),
  );

  // Admin Moderación (Sanciones)
  getIt.registerLazySingleton<AdminSancionesDataSource>(
    () => AdminSancionesDataSource(),
  );
  getIt.registerLazySingleton<AdminSancionesRepository>(
    () => AdminSancionesRepository(getIt<AdminSancionesDataSource>()),
  );
  getIt.registerFactory<AdminSancionesCubit>(
    () => AdminSancionesCubit(getIt<AdminSancionesRepository>()),
  );

  // Admin Moderación (Roles)
  getIt.registerLazySingleton<AdminRolesDataSource>(
    () => AdminRolesDataSource(),
  );
  getIt.registerLazySingleton<AdminRolesRepository>(
    () => AdminRolesRepository(getIt<AdminRolesDataSource>()),
  );
  getIt.registerFactory<AdminRolesCubit>(
    () => AdminRolesCubit(getIt<AdminRolesRepository>()),
  );

  // Admin Sugerencias
  getIt.registerLazySingleton<AdminSugerenciasDataSource>(
    () => AdminSugerenciasDataSource(),
  );
  getIt.registerLazySingleton<AdminSugerenciasRepository>(
    () => AdminSugerenciasRepository(getIt<AdminSugerenciasDataSource>()),
  );
  getIt.registerFactory<AdminSugerenciasCubit>(
    () => AdminSugerenciasCubit(getIt<AdminSugerenciasRepository>()),
  );
}