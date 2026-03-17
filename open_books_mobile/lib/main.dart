import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'injection_container.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/libros/logic/cubit/cubit.dart';
import 'features/biblioteca/logic/cubit/biblioteca_cubit.dart';
import 'features/perfil/logic/cubit/perfil_cubit.dart';
import 'features/historial/logic/cubit/historial_cubit.dart';
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
    _appRouter = AppRouter(sessionCubit: _sessionCubit);

    _sessionCubit.checkSession();
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
      ],
      child: MaterialApp.router(
        title: 'OpenBooks',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
        scrollBehavior: const ScrollBehavior().copyWith(
          scrollbars: false,
        ),
      ),
    );
  }
}
