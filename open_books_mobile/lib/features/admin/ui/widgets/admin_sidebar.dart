import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Admin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/admin',
                  isSelected: currentRoute == '/admin',
                  onTap: () => context.go('/admin'),
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: 'Usuarios',
                  route: '/admin/usuarios',
                  isSelected: currentRoute == '/admin/usuarios',
                  onTap: () => context.go('/admin/usuarios'),
                ),
                _SidebarItem(
                  icon: Icons.library_books_outlined,
                  selectedIcon: Icons.library_books,
                  label: 'Libros y Categorías',
                  route: '/admin/libros',
                  isSelected: currentRoute == '/admin/libros',
                  onTap: () => context.go('/admin/libros'),
                ),
                _SidebarItem(
                  icon: Icons.gavel_outlined,
                  selectedIcon: Icons.gavel,
                  label: 'Moderación',
                  route: '/admin/moderacion',
                  isSelected: currentRoute == '/admin/moderacion',
                  onTap: () => context.go('/admin/moderacion'),
                ),
                _SidebarItem(
                  icon: Icons.tips_and_updates_outlined,
                  selectedIcon: Icons.tips_and_updates,
                  label: 'Sugerencias',
                  route: '/admin/sugerencias',
                  isSelected: currentRoute == '/admin/sugerencias',
                  onTap: () => context.go('/admin/sugerencias'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Volver',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () => context.go('/home'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
      ),
    );
  }
}
