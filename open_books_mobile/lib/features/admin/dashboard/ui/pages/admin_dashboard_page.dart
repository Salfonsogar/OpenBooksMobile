import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/admin_dashboard_cubit.dart';
import '../../logic/cubit/admin_dashboard_state.dart';
import '../widgets/stat_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardCubit>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<AdminDashboardCubit>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
              builder: (context, state) {
                if (state is AdminDashboardLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is AdminDashboardError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar estadísticas',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context.read<AdminDashboardCubit>().loadStats();
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final stats = state is AdminDashboardLoaded
                    ? state.stats
                    : null;

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: 'Usuarios',
                      value: stats?.totalUsuarios ?? 0,
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Libros',
                      value: stats?.totalLibros ?? 0,
                      icon: Icons.menu_book,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Denuncias',
                      value: stats?.denunciasPendientes ?? 0,
                      icon: Icons.warning,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Sugerencias',
                      value: stats?.sugerenciasNuevas ?? 0,
                      icon: Icons.lightbulb,
                      color: Colors.purple,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Módulos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ModuleCard(
              icon: Icons.people,
              title: 'Usuarios',
              description: 'Gestionar usuarios, roles y sanciones',
              color: Colors.blue,
              onTap: () => context.go('/admin/usuarios'),
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              icon: Icons.library_books,
              title: 'Libros y Categorías',
              description: 'Gestionar libros y categorías del sistema',
              color: Colors.green,
              onTap: () => context.go('/admin/libros'),
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              icon: Icons.gavel,
              title: 'Moderación',
              description: 'Denuncias y sanciones de usuarios',
              color: Colors.orange,
              onTap: () => context.go('/admin/moderacion'),
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              icon: Icons.lightbulb,
              title: 'Sugerencias',
              description: 'Ver y gestionar sugerencias de usuarios',
              color: Colors.purple,
              onTap: () => context.go('/admin/sugerencias'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
