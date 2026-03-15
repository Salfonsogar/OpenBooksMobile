import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
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
}
