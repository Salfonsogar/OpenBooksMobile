import 'package:get_it/get_it.dart';

import 'shared/core/network/api_client.dart';
import 'shared/core/session/session_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Session
  getIt.registerLazySingleton<SessionCubit>(() => SessionCubit());
}
