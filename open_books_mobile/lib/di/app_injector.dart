import '../../features/notifications/logic/cubit/notification_cubit.dart';
import '../../features/onboarding/logic/cubit/onboarding_cubit.dart';
import '../../features/reader/logic/cubit/reader_settings_cubit.dart';
import '../../shared/core/session/session_cubit.dart';
import '../../shared/services/sync_service.dart';

class AppInjector {
  final SyncService syncService;
  final SessionCubit sessionCubit;
  final NotificationCubit notificationCubit;
  final ReaderSettingsCubit settingsCubit;
  final OnboardingCubit onboardingCubit;

  AppInjector({
    required this.syncService,
    required this.sessionCubit,
    required this.notificationCubit,
    required this.settingsCubit,
    required this.onboardingCubit,
  });
}

late final AppInjector injector;