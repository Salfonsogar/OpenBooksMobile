import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_providers.dart';
import 'di/app_injector.dart';
import 'routing/app_router.dart';
import 'theme_factory.dart';
import 'features/reader/logic/cubit/reader_settings_cubit.dart';
import 'features/reader/data/models/reader_settings.dart';
import 'features/notifications/logic/cubit/notification_cubit.dart';
import 'features/notifications/ui/widgets/notification_overlay_manager.dart';
import 'shared/core/session/session_cubit.dart';

class OpenBooksApp extends StatefulWidget {
  final AppInjector injector;

  const OpenBooksApp({super.key, required this.injector});

  @override
  State<OpenBooksApp> createState() => _OpenBooksAppState();
}

class _OpenBooksAppState extends State<OpenBooksApp>
    with WidgetsBindingObserver {
  late final SessionCubit _sessionCubit;
  late final ReaderSettingsCubit _settingsCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _sessionCubit = widget.injector.sessionCubit;
    _settingsCubit = widget.injector.settingsCubit;
    _appRouter = AppRouter(sessionCubit: _sessionCubit);

    _sessionCubit.setNotificationCubit(widget.injector.notificationCubit);
    _sessionCubit.checkSession();
    _settingsCubit.cargarSettings();
    widget.injector.syncService.onAppInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.injector.syncService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.injector.syncService.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>.value(value: widget.injector.sessionCubit),
        BlocProvider<NotificationCubit>.value(value: widget.injector.notificationCubit),
        BlocProvider<ReaderSettingsCubit>.value(value: widget.injector.settingsCubit),
        ...AppProviders.build(widget.injector),
      ],
      child: BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
        builder: (context, settings) {
          return NotificationOverlayManager(
            onViewNotifications: () {
              _appRouter.router.push('/notifications');
            },
            child: MaterialApp.router(
              title: 'OpenBooks',
              debugShowCheckedModeBanner: false,
              theme: ThemeFactory.build(settings.theme, Brightness.light),
              darkTheme: ThemeFactory.build(settings.theme, Brightness.dark),
              themeMode: ThemeFactory.getMode(settings.theme),
              routerConfig: _appRouter.router,
            ),
          );
        },
      ),
    );
  }
}