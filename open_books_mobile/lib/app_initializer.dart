import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'injection_container.dart';
import 'di/app_injector.dart';

class AppInitializer {
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
    await setupDependencies();

    injector = AppInjector(
      syncService: getIt(),
      sessionCubit: getIt(),
      notificationCubit: getIt(),
      settingsCubit: getIt(),
    );
  }
}