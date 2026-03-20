import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/libros/data/datasources/datasources.dart';
import 'features/libros/data/repositories/libros_repository.dart';
import 'features/libros/logic/cubit/cubit.dart';
import 'features/biblioteca/data/datasources/biblioteca_datasource.dart';
import 'features/biblioteca/data/repositories/biblioteca_repository.dart';
import 'features/biblioteca/logic/cubit/biblioteca_cubit.dart';
import 'features/perfil/data/datasources/perfil_datasource.dart';
import 'features/perfil/data/repositories/perfil_repository.dart';
import 'features/perfil/logic/cubit/perfil_cubit.dart';
import 'features/historial/data/datasources/historial_datasource.dart';
import 'features/historial/data/repositories/historial_repository.dart';
import 'features/historial/logic/cubit/historial_cubit.dart';
import 'features/reader/data/datasources/bookmark_datasource.dart';
import 'features/reader/data/datasources/epub_datasource.dart';
import 'features/reader/data/repositories/bookmark_repository.dart';
import 'features/reader/data/repositories/epub_repository.dart';
import 'features/reader/logic/cubit/bookmark_cubit.dart';
import 'features/reader/logic/cubit/reader_settings_cubit.dart';
import 'shared/core/network/api_client.dart';
import 'shared/core/session/session_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Session
  getIt.registerLazySingleton<SessionCubit>(() => SessionCubit());

  // Auth
  getIt.registerLazySingleton<AuthDataSource>(
    () => AuthDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthDataSource>()),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      sessionCubit: getIt<SessionCubit>(),
    ),
  );

  // Libros
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

  // Biblioteca
  getIt.registerLazySingleton<BibliotecaDataSource>(
    () => BibliotecaDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BibliotecaRepository>(
    () => BibliotecaRepository(getIt<BibliotecaDataSource>()),
  );

  // Perfil
  getIt.registerLazySingleton<PerfilDataSource>(
    () => PerfilDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PerfilRepository>(
    () => PerfilRepository(getIt<PerfilDataSource>()),
  );

  // Historial
  getIt.registerLazySingleton<HistorialDataSource>(
    () => HistorialDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<HistorialRepository>(
    () => HistorialRepository(getIt<HistorialDataSource>()),
  );

  // Biblioteca - singleton que escucha SessionCubit
  getIt.registerLazySingleton<BibliotecaCubit>(
    () => BibliotecaCubit(
      repository: getIt<BibliotecaRepository>(),
      sessionCubit: getIt<SessionCubit>(),
    ),
  );

  // Perfil - singleton que escucha SessionCubit
  getIt.registerLazySingleton<PerfilCubit>(
    () => PerfilCubit(
      repository: getIt<PerfilRepository>(),
      sessionCubit: getIt<SessionCubit>(),
    ),
  );

  // Historial
  getIt.registerFactory<HistorialCubit>(
    () => HistorialCubit(repository: getIt<HistorialRepository>()),
  );

  // Reader
  getIt.registerLazySingleton<EpubDataSource>(
    () => EpubDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<EpubRepository>(
    () => EpubRepository(getIt<EpubDataSource>()),
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
}
