import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';

class AdminPage extends StatelessWidget {
  final Widget child;
  final String moduleTitle;
  final String moduleRoute;

  const AdminPage({
    super.key,
    required this.child,
    required this.moduleTitle,
    required this.moduleRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _AdminHeader(title: moduleTitle),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _AdminFooter(currentRoute: moduleRoute),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final String title;

  const _AdminHeader({required this.title});

  Widget _buildAvatar(BuildContext context, SessionState state) {
    if (state is SessionAuthenticated) {
      if (state.fotoPerfilBase64 != null && state.fotoPerfilBase64!.isNotEmpty) {
        try {
          return CircleAvatar(
            radius: 18,
            backgroundImage: MemoryImage(
              base64Decode(state.fotoPerfilBase64!),
            ),
          );
        } catch (_) {}
      }
      return CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          state.userName.isNotEmpty ? state.userName[0].toUpperCase() : '?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) {
              return InkWell(
                onTap: () {
                  context.go('/profile');
                },
                borderRadius: BorderRadius.circular(18),
                child: _buildAvatar(context, state),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminFooter extends StatelessWidget {
  final String currentRoute;

  const _AdminFooter({required this.currentRoute});

  int _calculateSelectedIndex() {
    if (currentRoute == '/admin') return 0;
    if (currentRoute == '/admin/libros') return 1;
    if (currentRoute == '/admin/moderacion') return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/libros');
        break;
      case 2:
        context.go('/admin/moderacion');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: Theme.of(context).colorScheme.primaryContainer,
      selectedIndex: _calculateSelectedIndex(),
      onDestinationSelected: (index) => _onItemTapped(index, context),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books),
          label: 'Libros',
        ),
        NavigationDestination(
          icon: Icon(Icons.gavel_outlined),
          selectedIcon: Icon(Icons.gavel),
          label: 'Moderación',
        ),
      ],
    );
  }
}
