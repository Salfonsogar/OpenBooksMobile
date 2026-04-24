import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/admin_dashboard_cubit.dart';
import '../../logic/cubit/admin_dashboard_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_libros_bar_chart.dart';
import '../widgets/evolucion_lectura_line_chart.dart';
import '../widgets/distribucion_categorias_pie_chart.dart';
import '../widgets/reading_stats_bar_chart.dart';
import '../widgets/date_filter_chips.dart';
import '../widgets/export_button.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardCubit>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _repaintKey,
      child: RefreshIndicator(
        onRefresh: () => context.read<AdminDashboardCubit>().refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildFilterSection(context),
              const SizedBox(height: 24),
              _buildMainContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Estadísticas y métricas del sistema',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        ExportButton(
          repaintKey: _repaintKey,
          title: 'Exportar',
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        DateFilter currentFilter = DateFilter.mes;
        if (state is AdminDashboardLoaded) {
          currentFilter = state.dateFilter;
        }

        return DateFilterChips(
          currentFilter: currentFilter,
          onFilterChanged: (filter) {
            context.read<AdminDashboardCubit>().changeFilter(filter);
          },
          onCustomRange: () async {
            final range = await showCustomDateRangePicker(context);
            if (range != null && context.mounted) {
              context.read<AdminDashboardCubit>().changeFilter(
                DateFilter.personalizado,
                startDate: range.start,
                endDate: range.end,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
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

        final stats = state is AdminDashboardLoaded ? state.stats : null;
        if (stats == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKpiSection(stats),
            const SizedBox(height: 24),
            _buildReadingStatsSection(stats),
            const SizedBox(height: 24),
            _buildChartsSection(stats),
            const SizedBox(height: 32),
            _buildModulesSection(context),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildKpiSection(stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              title: 'Usuarios',
              value: stats.totalUsuarios,
              icon: Icons.people,
              color: Colors.blue,
              subtitle: '${stats.usuariosActivos} activos',
            ),
            StatCard(
              title: 'Libros',
              value: stats.totalLibros,
              icon: Icons.menu_book,
              color: Colors.green,
              subtitle: '${stats.librosEnBiblioteca} en biblioteca',
            ),
            StatCard(
              title: 'Denuncias',
              value: stats.denunciasPendientes,
              icon: Icons.warning,
              color: Colors.orange,
            ),
            StatCard(
              title: 'Sugerencias',
              value: stats.sugerenciasNuevas,
              icon: Icons.lightbulb,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadingStatsSection(stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actividad de Lectura',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ReadingStatsBarChart(
              pagesToday: stats.paginasLeidasHoy,
              pagesWeek: stats.paginasLeidasSemana,
              pagesMonth: stats.paginasLeidasMes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis Detallado',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildChartsGrid(stats),
      ],
    );
  }

  Widget _buildChartsGrid(stats) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Libros Más Leídos',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TopLibrosBarChart(topLibros: stats.topLibros),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.show_chart,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Evolución de Lectura',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                EvolucionLecturaLineChart(data: stats.evolucionLectura),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Distribución por Categoría',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DistribucionCategoriasPieChart(
                  categorias: stats.distribucionCategorias,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModulesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
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