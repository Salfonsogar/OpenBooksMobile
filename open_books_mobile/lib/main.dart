import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'injection_container.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/libros/logic/cubit/cubit.dart';
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

  @override
  void initState() {
    super.initState();
    _sessionCubit = getIt<SessionCubit>();
    _authCubit = getIt<AuthCubit>();
    _librosCubit = getIt<LibrosCubit>();
    _libroDetalleCubit = getIt<LibroDetalleCubit>();
    _categoriasCubit = getIt<CategoriasCubit>();
    _appRouter = AppRouter(sessionCubit: _sessionCubit);
    _sessionCubit.checkSession();
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
      ],
      child: MaterialApp.router(
        title: 'OpenBooks',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
