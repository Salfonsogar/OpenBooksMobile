// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/onboarding/logic/cubit/onboarding_cubit.dart';
import 'injection_container.dart';
import 'di/app_injector.dart';

class AppInitializer {
  static late OnboardingCubit onboardingCubit;

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
    await setupDependencies();

    onboardingCubit = getIt<OnboardingCubit>();
    await onboardingCubit.checkOnboardingStatus();

    injector = AppInjector(
      syncService: getIt(),
      sessionCubit: getIt(),
      notificationCubit: getIt(),
      settingsCubit: getIt(),
      onboardingCubit: onboardingCubit,
    );
  }
}