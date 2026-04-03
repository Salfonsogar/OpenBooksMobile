import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'injection_container.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/libros/logic/cubit/cubit.dart';
import 'features/biblioteca/logic/cubit/biblioteca_cubit.dart';
import 'features/perfil/logic/cubit/perfil_cubit.dart';
import 'features/historial/logic/cubit/historial_cubit.dart';
import 'features/notifications/logic/cubit/notification_cubit.dart';
import 'features/notifications/ui/widgets/notification_overlay_manager.dart';
import 'features/reader/data/models/reader_settings.dart';
import 'features/reader/logic/cubit/reader_settings_cubit.dart';
import 'features/admin/dashboard/logic/cubit/admin_dashboard_cubit.dart';
import 'features/admin/usuarios/logic/cubit/admin_usuarios_cubit.dart';
import 'features/admin/libros/logic/cubit/admin_libros_cubit.dart';
import 'features/admin/categorias/logic/cubit/admin_categorias_cubit.dart';
import 'features/admin/moderacion/logic/cubit/admin_denuncias_cubit.dart';
import 'features/admin/moderacion/logic/cubit/admin_sanciones_cubit.dart';
import 'features/admin/moderacion/logic/cubit/admin_roles_cubit.dart';
import 'features/admin/sugerencias/logic/cubit/admin_sugerencias_cubit.dart';
import 'features/biblioteca/logic/cubit/upload_libro_cubit.dart';
import 'shared/core/session/session_cubit.dart';
import 'shared/core/theme/app_theme.dart';
import 'shared/services/sync_service.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await setupDependencies();

  runApp(const OpenBooksApp());
}

class OpenBooksApp extends StatefulWidget {
  const OpenBooksApp({super.key});

  @override
  State<OpenBooksApp> createState() => _OpenBooksAppState();
}

class _OpenBooksAppState extends State<OpenBooksApp> with WidgetsBindingObserver {
  late final SessionCubit _sessionCubit;
  late final AuthCubit _authCubit;
  late final LibrosCubit _librosCubit;
  late final LibroDetalleCubit _libroDetalleCubit;
  late final CategoriasCubit _categoriasCubit;
  late final AppRouter _appRouter;
  late final BibliotecaCubit _bibliotecaCubit;
  late final PerfilCubit _perfilCubit;
  late final HistorialCubit _historialCubit;
  late final NotificationCubit _notificationCubit;
  late final ReaderSettingsCubit _settingsCubit;
  late final AdminDashboardCubit _adminDashboardCubit;
  late final AdminUsuariosCubit _adminUsuariosCubit;
  late final AdminLibrosCubit _adminLibrosCubit;
  late final AdminCategoriasCubit _adminCategoriasCubit;
  late final AdminDenunciasCubit _adminDenunciasCubit;
  late final AdminSancionesCubit _adminSancionesCubit;
  late final AdminRolesCubit _adminRolesCubit;
  late final AdminSugerenciasCubit _adminSugerenciasCubit;
  late final UploadLibroCubit _uploadLibroCubit;
  late final SyncService _syncService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _sessionCubit = getIt<SessionCubit>();
    _authCubit = getIt<AuthCubit>();
    _librosCubit = getIt<LibrosCubit>();
    _libroDetalleCubit = getIt<LibroDetalleCubit>();
    _categoriasCubit = getIt<CategoriasCubit>();
    _historialCubit = getIt<HistorialCubit>();
    _bibliotecaCubit = getIt<BibliotecaCubit>();
    _perfilCubit = getIt<PerfilCubit>();
    _notificationCubit = getIt<NotificationCubit>();
    _sessionCubit.setNotificationCubit(_notificationCubit);
    _settingsCubit = getIt<ReaderSettingsCubit>();
    _adminDashboardCubit = getIt<AdminDashboardCubit>();
    _adminUsuariosCubit = getIt<AdminUsuariosCubit>();
    _adminLibrosCubit = getIt<AdminLibrosCubit>();
    _adminCategoriasCubit = getIt<AdminCategoriasCubit>();
    _adminDenunciasCubit = getIt<AdminDenunciasCubit>();
    _adminSancionesCubit = getIt<AdminSancionesCubit>();
    _adminRolesCubit = getIt<AdminRolesCubit>();
    _adminSugerenciasCubit = getIt<AdminSugerenciasCubit>();
    _uploadLibroCubit = getIt<UploadLibroCubit>();
    _syncService = getIt<SyncService>();
    _appRouter = AppRouter(sessionCubit: _sessionCubit);

    _sessionCubit.checkSession();
    _settingsCubit.cargarSettings();
    _syncService.onAppInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bibliotecaCubit.close();
    _perfilCubit.close();
    _historialCubit.close();
    _notificationCubit.close();
    _adminDashboardCubit.close();
    _adminUsuariosCubit.close();
    _adminLibrosCubit.close();
    _adminCategoriasCubit.close();
    _adminDenunciasCubit.close();
    _adminSancionesCubit.close();
    _adminRolesCubit.close();
    _adminSugerenciasCubit.close();
    _syncService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncService.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>.value(value: _sessionCubit),
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<LibrosCubit>.value(value: _librosCubit),
        BlocProvider<LibroDetalleCubit>.value(value: _libroDetalleCubit),
        BlocProvider<CategoriasCubit>.value(value: _categoriasCubit),
        BlocProvider<BibliotecaCubit>.value(value: _bibliotecaCubit),
        BlocProvider<PerfilCubit>.value(value: _perfilCubit),
        BlocProvider<HistorialCubit>.value(value: _historialCubit),
        BlocProvider<NotificationCubit>.value(value: _notificationCubit),
        BlocProvider<ReaderSettingsCubit>.value(value: _settingsCubit),
        BlocProvider<AdminDashboardCubit>.value(value: _adminDashboardCubit),
        BlocProvider<AdminUsuariosCubit>.value(value: _adminUsuariosCubit),
        BlocProvider<AdminLibrosCubit>.value(value: _adminLibrosCubit),
        BlocProvider<AdminCategoriasCubit>.value(value: _adminCategoriasCubit),
        BlocProvider<AdminDenunciasCubit>.value(value: _adminDenunciasCubit),
        BlocProvider<AdminSancionesCubit>.value(value: _adminSancionesCubit),
        BlocProvider<AdminRolesCubit>.value(value: _adminRolesCubit),
        BlocProvider<AdminSugerenciasCubit>.value(value: _adminSugerenciasCubit),
        BlocProvider<UploadLibroCubit>.value(value: _uploadLibroCubit),
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
              theme: _buildTheme(settings.theme, Brightness.light),
              darkTheme: _buildTheme(settings.theme, Brightness.dark),
              themeMode: _getThemeMode(settings.theme),
              routerConfig: _appRouter.router,
              scrollBehavior: const ScrollBehavior().copyWith(
                scrollbars: false,
              ),
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(String theme, Brightness brightness) {
    final baseTheme = brightness == Brightness.light
        ? AppTheme.lightTheme
        : AppTheme.darkTheme;

    Color surfaceColor;
    Color surfaceContainerHighestColor;
    Color onSurfaceColor;
    Color onSurfaceVariantColor;
    Color primaryColor;
    Color onPrimaryColor;
    Color surfaceContainerLowColor;
    Color onPrimaryContainerColor;
    Color primaryContainerColor;

    switch (theme) {
      case 'sepia':
        surfaceColor = const Color(0xFFF4ECD8);
        surfaceContainerHighestColor = const Color(0xFFE8DFC8);
        surfaceContainerLowColor = const Color(0xFFFAF6EE);
        onSurfaceColor = const Color(0xFF5B4636);
        onSurfaceVariantColor = const Color(0xFF7D6652);
        primaryColor = const Color(0xFF8B4513);
        onPrimaryColor = const Color(0xFFF4ECD8);
        onPrimaryContainerColor = const Color(0xFF8B4513);
        primaryContainerColor = const Color(0xFFE8D5C0);
        break;
      case 'dark':
        surfaceColor = Colors.grey[900]!;
        surfaceContainerHighestColor = Colors.grey[800]!;
        surfaceContainerLowColor = Colors.grey[850]!;
        onSurfaceColor = Colors.grey[300]!;
        onSurfaceVariantColor = Colors.grey[400]!;
        primaryColor = Colors.white;
        onPrimaryColor = Colors.grey[900]!;
        onPrimaryContainerColor = Colors.grey[300]!;
        primaryContainerColor = Colors.grey[700]!;
        break;
      default:
        return baseTheme;
    }

    if (brightness == Brightness.light) {
      return baseTheme.copyWith(
        scaffoldBackgroundColor: surfaceColor,
        colorScheme: ColorScheme.light(
          surface: surfaceColor,
          surfaceContainerHighest: surfaceContainerHighestColor,
          surfaceContainerLow: surfaceContainerLowColor,
          onSurface: onSurfaceColor,
          onSurfaceVariant: onSurfaceVariantColor,
          primary: primaryColor,
          onPrimary: onPrimaryColor,
          onPrimaryContainer: onPrimaryContainerColor,
          primaryContainer: primaryContainerColor,
        ),
        cardTheme: CardThemeData(
          color: surfaceContainerHighestColor,
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: onSurfaceColor),
          bodyMedium: TextStyle(color: onSurfaceColor),
          bodySmall: TextStyle(color: onSurfaceVariantColor),
          titleLarge: TextStyle(color: onSurfaceColor),
          titleMedium: TextStyle(color: onSurfaceColor),
          titleSmall: TextStyle(color: onSurfaceColor),
          labelLarge: TextStyle(color: onSurfaceColor),
          labelMedium: TextStyle(color: onSurfaceVariantColor),
          labelSmall: TextStyle(color: onSurfaceVariantColor),
        ),
      );
    } else {
      return baseTheme.copyWith(
        scaffoldBackgroundColor: surfaceColor,
        colorScheme: ColorScheme.dark(
          surface: surfaceColor,
          surfaceContainerHighest: surfaceContainerHighestColor,
          surfaceContainerLow: surfaceContainerLowColor,
          onSurface: onSurfaceColor,
          onSurfaceVariant: onSurfaceVariantColor,
          primary: primaryColor,
          onPrimary: onPrimaryColor,
          onPrimaryContainer: onPrimaryContainerColor,
          primaryContainer: primaryContainerColor,
        ),
        cardTheme: CardThemeData(
          color: surfaceContainerHighestColor,
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: onSurfaceColor),
          bodyMedium: TextStyle(color: onSurfaceColor),
          bodySmall: TextStyle(color: onSurfaceVariantColor),
          titleLarge: TextStyle(color: onSurfaceColor),
          titleMedium: TextStyle(color: onSurfaceColor),
          titleSmall: TextStyle(color: onSurfaceColor),
          labelLarge: TextStyle(color: onSurfaceColor),
          labelMedium: TextStyle(color: onSurfaceVariantColor),
          labelSmall: TextStyle(color: onSurfaceVariantColor),
        ),
      );
    }
  }

  ThemeMode _getThemeMode(String theme) {
    switch (theme) {
      case 'dark':
      case 'sepia':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }
}
