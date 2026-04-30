import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../injection_container.dart';
import '../shared/core/session/session_cubit.dart';
import '../shared/core/session/session_state.dart';
import '../features/auth/logic/cubit/auth_cubit.dart';
import '../features/auth/ui/pages/login_page.dart';
import '../features/auth/ui/pages/register_page.dart';
import '../features/auth/ui/pages/recovery_page.dart';
import '../features/libros/logic/cubit/index.dart';
import '../features/libros/ui/pages/home_page.dart';
import '../features/libros/ui/pages/search_page.dart';
import '../features/libros/ui/pages/book_detail_page.dart';
import '../features/biblioteca/logic/cubit/biblioteca_cubit.dart';
import '../features/biblioteca/logic/cubit/upload_libro_cubit.dart';
import '../features/biblioteca/ui/pages/library_page.dart';
import '../features/biblioteca/ui/pages/upload_libro_page.dart';
import '../features/perfil/logic/cubit/perfil_cubit.dart';
import '../features/perfil/ui/pages/profile_page.dart';
import '../features/perfil/ui/pages/edit_profile_page.dart';
import '../features/perfil/ui/pages/ayuda_comentarios_page.dart';
import '../features/historial/logic/cubit/historial_cubit.dart';
import '../features/historial/ui/pages/history_page.dart';
import '../features/reader/ui/pages/reader_page.dart';
import '../features/settings/ui/pages/settings_page.dart';
import '../features/reader/logic/cubit/reader_settings_cubit.dart';
import '../features/reader/logic/cubit/reader_cubit.dart';
import '../features/reader/logic/cubit/bookmark_cubit.dart';
import '../features/reader/logic/cubit/highlight_cubit.dart';
import '../features/reader/logic/cubit/audio_player_cubit.dart';
import '../features/reader/data/datasources/highlight_datasource.dart';
import '../features/notifications/ui/pages/notifications_page.dart';
import '../features/admin/ui/pages/admin_page.dart';
import '../features/admin/dashboard/logic/cubit/admin_dashboard_cubit.dart';
import '../features/admin/dashboard/ui/pages/admin_dashboard_page.dart';
import '../features/admin/libros/logic/cubit/admin_libros_cubit.dart';
import '../features/admin/categorias/logic/cubit/admin_categorias_cubit.dart';
import '../features/admin/libros/ui/pages/admin_libros_page.dart';
import '../features/admin/moderacion/logic/cubit/admin_denuncias_cubit.dart';
import '../features/admin/moderacion/logic/cubit/admin_sanciones_cubit.dart';
import '../features/admin/moderacion/logic/cubit/admin_roles_cubit.dart';
import '../features/admin/moderacion/ui/pages/admin_moderacion_page.dart';
import '../features/admin/sugerencias/logic/cubit/admin_sugerencias_cubit.dart';
import '../features/admin/sugerencias/ui/pages/admin_sugerencias_page.dart';
import '../features/admin/usuarios/logic/cubit/admin_usuarios_cubit.dart';
import '../features/admin/usuarios/ui/pages/admin_usuarios_page.dart';
import '../features/onboarding/logic/cubit/onboarding_cubit.dart';
import '../features/onboarding/ui/pages/onboarding_page.dart';
import '../shared/ui/widgets/search_header.dart';
import '../features/auth/data/models/index.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  final SessionCubit sessionCubit;
  final ReaderSettingsCubit settingsCubit;

  AppRouter({required this.sessionCubit, required this.settingsCubit});

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: RouterRefreshNotifier(sessionCubit),
    redirect: (context, state) {
      final onboardingCubit = getIt<OnboardingCubit>();
      final onboardingState = onboardingCubit.state;
      final hasSeenOnboarding =
          onboardingState is OnboardingChecked &&
          onboardingState.hasSeenOnboarding;

      final sessionState = sessionCubit.state;
      final isLoggedIn = sessionState is SessionAuthenticated;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/recovery' ||
          state.matchedLocation == '/onboarding';

      final showOnboarding =
          state.matchedLocation != '/onboarding' &&
          !hasSeenOnboarding &&
          !isLoggedIn;

      if (showOnboarding) {
        return '/onboarding';
      }

      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isAdmin =
          sessionState is SessionAuthenticated && sessionState.isAdmin;

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return isAdmin ? '/admin' : '/home';
      }

      if (isAdminRoute && !isAdmin) {
        return '/home';
      }

      if (!isAdminRoute && isAdmin) {
        final exemptRoutes = [
          '/profile',
          '/settings',
          '/notifications',
          '/search',
          '/book',
          '/reader',
          '/library',
          '/history',
          '/ayuda-comentarios',
        ];
        final isExempt = exemptRoutes.any(
          (route) => state.matchedLocation.startsWith(route),
        );
        if (!isExempt) {
          return '/admin';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => BlocProvider.value(
          value: getIt<OnboardingCubit>(),
          child: const OnboardingPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/recovery',
        builder: (context, state) => const RecoveryPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<LibrosCubit>()),
                BlocProvider(create: (_) => getIt<CategoriasCubit>()),
              ],
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<BibliotecaCubit>(),
              child: const LibraryPage(),
            ),
          ),
          GoRoute(
            path: '/library/upload',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<UploadLibroCubit>()),
                BlocProvider(create: (_) => getIt<AdminCategoriasCubit>()),
              ],
              child: const UploadLibroPage(),
            ),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<HistorialCubit>(),
              child: const HistoryPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final autor = state.uri.queryParameters['autor'];
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<LibrosCubit>()),
              BlocProvider(create: (_) => getIt<CategoriasCubit>()),
            ],
            child: SearchPage(autorInicial: autor),
          );
        },
      ),
      GoRoute(
        path: '/book/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<LibroDetalleCubit>()),
            ],
            child: BookDetailPage(libroId: id),
          );
        },
      ),
      GoRoute(
        path: '/reader/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<ReaderCubit>(param1: id)),
              BlocProvider.value(value: getIt<ReaderSettingsCubit>()),
              BlocProvider(create: (_) => getIt<BookmarkCubit>()),
              BlocProvider(create: (_) => getIt<HighlightCubit>(param1: getIt<HighlightDataSource>())),
              BlocProvider(create: (_) => getIt<AudioPlayerCubit>(param1: id)),
            ],
            child: ReaderPage(libroId: id),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<PerfilCubit>(),
          child: const ProfilePage(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) {
          final usuario = state.extra as Usuario;
          return BlocProvider(
            create: (_) => getIt<PerfilCubit>(),
            child: EditProfilePage(usuario: usuario),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => BlocProvider.value(
          value: settingsCubit,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/ayuda-comentarios',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<PerfilCubit>(),
          child: const AyudaComentariosPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final route = state.matchedLocation;
          final title = _getModuleTitle(route);
          return AdminPage(
            moduleTitle: title,
            moduleRoute: route,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<AdminDashboardCubit>(),
              child: const AdminDashboardPage(),
            ),
          ),
          GoRoute(
            path: '/admin/usuarios',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<AdminUsuariosCubit>()),
                BlocProvider(create: (_) => getIt<AdminRolesCubit>()),
              ],
              child: const AdminUsuariosPage(),
            ),
          ),
          GoRoute(
            path: '/admin/libros',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<AdminLibrosCubit>()),
                BlocProvider(create: (_) => getIt<AdminCategoriasCubit>()),
              ],
              child: const AdminLibrosPage(),
            ),
          ),
          GoRoute(
            path: '/admin/moderacion',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<AdminDenunciasCubit>()),
                BlocProvider(create: (_) => getIt<AdminSancionesCubit>()),
              ],
              child: const AdminModeracionPage(),
            ),
          ),
          GoRoute(
            path: '/admin/sugerencias',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<AdminSugerenciasCubit>(),
              child: const AdminSugerenciasPage(),
            ),
          ),
        ],
      ),
    ],
  );
}

String _getModuleTitle(String route) {
  switch (route) {
    case '/admin':
      return 'Dashboard';
    case '/admin/usuarios':
      return 'Usuarios';
    case '/admin/libros':
      return 'Libros y Categorías';
    case '/admin/moderacion':
      return 'Moderación';
    case '/admin/sugerencias':
      return 'Sugerencias';
    default:
      return 'Panel Admin';
  }
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SearchHeader(
            onSearchTap: () => context.pushReplacement('/search'),
            onProfileTap: () => context.pushReplacement('/profile'),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.library_books_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              Icons.library_books,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              Icons.history,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            label: 'Historial',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/library')) return 1;
    if (location.startsWith('/history')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/library');
        break;
      case 2:
        context.go('/history');
        break;
    }
  }
}

class RouterRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription _subscription;

  RouterRefreshNotifier(SessionCubit sessionCubit) {
    notifyListeners();
    _subscription = sessionCubit.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
