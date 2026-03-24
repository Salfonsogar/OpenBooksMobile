import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/core/session/session_cubit.dart';
import '../shared/core/session/session_state.dart';
import '../features/auth/ui/pages/login_page.dart';
import '../features/auth/ui/pages/register_page.dart';
import '../features/auth/ui/pages/recovery_page.dart';
import '../features/libros/ui/pages/home_page.dart';
import '../features/libros/ui/pages/search_page.dart';
import '../features/libros/ui/pages/book_detail_page.dart';
import '../features/biblioteca/ui/pages/library_page.dart';
import '../features/biblioteca/ui/pages/upload_libro_page.dart';
import '../features/perfil/ui/pages/profile_page.dart';
import '../features/perfil/ui/pages/edit_profile_page.dart';
import '../features/historial/ui/pages/history_page.dart';
import '../features/reader/ui/pages/reader_page.dart';
import '../features/settings/ui/pages/settings_page.dart';
import '../features/notifications/ui/pages/notifications_page.dart';
import '../features/admin/ui/pages/admin_page.dart';
import '../features/admin/dashboard/ui/pages/admin_dashboard_page.dart';
import '../features/admin/libros/ui/pages/admin_libros_page.dart';
import '../features/admin/moderacion/ui/pages/admin_moderacion_page.dart';
import '../features/admin/sugerencias/ui/pages/admin_sugerencias_page.dart';
import '../features/admin/usuarios/ui/pages/admin_usuarios_page.dart';
import '../shared/ui/widgets/search_header.dart';
import '../features/auth/data/models/usuario.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  final SessionCubit sessionCubit;

  AppRouter({required this.sessionCubit});

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: RouterRefreshNotifier(sessionCubit),
    redirect: (context, state) {
      final sessionState = sessionCubit.state;
      final isLoggedIn = sessionState is SessionAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/recovery';

      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isAdmin = sessionState is SessionAuthenticated &&
          sessionState.isAdmin;

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
        final exemptRoutes = ['/profile', '/settings', '/notifications', '/search', '/book', '/reader', '/library', '/history'];
        final isExempt = exemptRoutes.any((route) => state.matchedLocation.startsWith(route));
        if (!isExempt) {
          return '/admin';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
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
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryPage(),
          ),
          GoRoute(
            path: '/library/upload',
            builder: (context, state) => const UploadLibroPage(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final autor = state.uri.queryParameters['autor'];
          return SearchPage(autorInicial: autor);
        },
      ),
      GoRoute(
        path: '/book/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BookDetailPage(libroId: id);
        },
      ),
      GoRoute(
        path: '/reader/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ReaderPage(libroId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final usuario = state.extra as Usuario;
              return EditProfilePage(usuario: usuario);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final route = state.matchedLocation;
          final title = _getModuleTitle(route);
          return AdminPage(
            child: child,
            moduleTitle: title,
            moduleRoute: route,
          );
        },
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: '/admin/usuarios',
            builder: (context, state) => const AdminUsuariosPage(),
          ),
          GoRoute(
            path: '/admin/libros',
            builder: (context, state) => const AdminLibrosPage(),
          ),
          GoRoute(
            path: '/admin/moderacion',
            builder: (context, state) => const AdminModeracionPage(),
          ),
          GoRoute(
            path: '/admin/sugerencias',
            builder: (context, state) => const AdminSugerenciasPage(),
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
            icon: Icon(Icons.home_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.home, color: Theme.of(context).colorScheme.onPrimaryContainer),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.library_books, color: Theme.of(context).colorScheme.onPrimaryContainer),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.history, color: Theme.of(context).colorScheme.onPrimaryContainer),
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
