import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'injection_container.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/libros/logic/cubit/cubit.dart';
import 'features/biblioteca/logic/cubit/biblioteca_cubit.dart';
import 'features/perfil/logic/cubit/perfil_cubit.dart';
import 'features/historial/logic/cubit/historial_cubit.dart';
import 'features/reader/data/models/reader_settings.dart';
import 'features/reader/logic/cubit/reader_settings_cubit.dart';
import 'shared/core/session/session_cubit.dart';
import 'shared/core/theme/app_theme.dart';
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

class _OpenBooksAppState extends State<OpenBooksApp> {
  late final SessionCubit _sessionCubit;
  late final AuthCubit _authCubit;
  late final LibrosCubit _librosCubit;
  late final LibroDetalleCubit _libroDetalleCubit;
  late final CategoriasCubit _categoriasCubit;
  late final AppRouter _appRouter;
  late final BibliotecaCubit _bibliotecaCubit;
  late final PerfilCubit _perfilCubit;
  late final HistorialCubit _historialCubit;
  late final ReaderSettingsCubit _settingsCubit;

  @override
  void initState() {
    super.initState();
    _sessionCubit = getIt<SessionCubit>();
    _authCubit = getIt<AuthCubit>();
    _librosCubit = getIt<LibrosCubit>();
    _libroDetalleCubit = getIt<LibroDetalleCubit>();
    _categoriasCubit = getIt<CategoriasCubit>();
    _historialCubit = getIt<HistorialCubit>();
    _bibliotecaCubit = getIt<BibliotecaCubit>();
    _perfilCubit = getIt<PerfilCubit>();
    _settingsCubit = getIt<ReaderSettingsCubit>();
    _appRouter = AppRouter(sessionCubit: _sessionCubit);

    _sessionCubit.checkSession();
    _settingsCubit.cargarSettings();
  }

  @override
  void dispose() {
    _bibliotecaCubit.close();
    _perfilCubit.close();
    _historialCubit.close();
    super.dispose();
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
        BlocProvider<ReaderSettingsCubit>.value(value: _settingsCubit),
      ],
      child: BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
        builder: (context, settings) {
          return MaterialApp.router(
            title: 'OpenBooks',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(settings.theme, Brightness.light),
            darkTheme: _buildTheme(settings.theme, Brightness.dark),
            themeMode: _getThemeMode(settings.theme),
            routerConfig: _appRouter.router,
            scrollBehavior: const ScrollBehavior().copyWith(
              scrollbars: false,
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
