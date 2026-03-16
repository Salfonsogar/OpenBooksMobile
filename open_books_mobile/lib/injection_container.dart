import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/libros/data/datasources/datasources.dart';
import 'features/libros/data/repositories/libros_repository.dart';
import 'features/libros/logic/cubit/cubit.dart';
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
    () => LibroDetalleCubit(getIt<LibrosRepository>()),
  );
  getIt.registerFactory<CategoriasCubit>(
    () => CategoriasCubit(getIt<LibrosRepository>()),
  );
}
