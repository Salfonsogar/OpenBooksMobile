import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';
import 'package:open_books_mobile/features/admin/moderacion/data/models/admin_denuncia.dart';
import 'package:open_books_mobile/features/admin/moderacion/data/models/admin_sancion.dart';
import 'package:open_books_mobile/features/admin/moderacion/logic/cubit/admin_denuncias_cubit.dart';
import 'package:open_books_mobile/features/admin/moderacion/logic/cubit/admin_sanciones_cubit.dart';
import 'package:open_books_mobile/features/admin/moderacion/ui/widgets/denuncia_detail_dialog.dart';
import 'package:open_books_mobile/features/admin/moderacion/ui/widgets/denuncia_delete_dialog.dart';
import 'package:open_books_mobile/features/admin/moderacion/ui/widgets/sancion_form_dialog.dart';
import 'package:open_books_mobile/features/admin/moderacion/ui/widgets/sancion_delete_dialog.dart';

class AdminModeracionPage extends StatefulWidget {
  const AdminModeracionPage({super.key});

  @override
  State<AdminModeracionPage> createState() => _AdminModeracionPageState();
}

class _AdminModeracionPageState extends State<AdminModeracionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollControllerDenuncias = ScrollController();
  final _scrollControllerSanciones = ScrollController();
  bool _scrollListenersAttached = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initCubits();
    _attachScrollListeners();
  }

  void _attachScrollListeners() {
    if (_scrollListenersAttached) return;
    _scrollListenersAttached = true;

    _scrollControllerDenuncias.addListener(_onDenunciasScroll);
    _scrollControllerSanciones.addListener(_onSancionesScroll);
  }

  void _onDenunciasScroll() {
    if (_scrollControllerDenuncias.position.pixels >=
        _scrollControllerDenuncias.position.maxScrollExtent - 200) {
      context.read<AdminDenunciasCubit>().loadMoreDenuncias();
    }
  }

  void _onSancionesScroll() {
    if (_scrollControllerSanciones.position.pixels >=
        _scrollControllerSanciones.position.maxScrollExtent - 200) {
      context.read<AdminSancionesCubit>().loadMoreSanciones();
    }
  }

  void _initCubits() {
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) {
      context.read<AdminDenunciasCubit>().setToken(sessionState.token);
      context.read<AdminSancionesCubit>().setToken(sessionState.token);
    }
    context.read<AdminDenunciasCubit>().loadDenuncias();
    context.read<AdminSancionesCubit>().loadSanciones();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollControllerDenuncias.dispose();
    _scrollControllerSanciones.dispose();
    super.dispose();
  }

  void _showDenunciaDetailDialog(AdminDenuncia denuncia) {
    showDialog(
      context: context,
      builder: (dialogContext) => DenunciaDetailDialog(denuncia: denuncia),
    );
  }

  void _showDenunciaDeleteDialog(AdminDenuncia denuncia) {
    showDialog(
      context: context,
      builder: (dialogContext) => DenunciaDeleteDialog(
        denuncia: denuncia,
        onConfirm: () async {
          return await context.read<AdminDenunciasCubit>().deleteDenuncia(denuncia.id);
        },
      ),
    );
  }

  void _showSancionCreateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => SancionFormDialog(
        onSave: (request) async {
          return await context.read<AdminSancionesCubit>().createSancion(request);
        },
      ),
    );
  }

  void _showSancionDeleteDialog(AdminSancion sancion) {
    showDialog(
      context: context,
      builder: (dialogContext) => SancionDeleteDialog(
        sancion: sancion,
        onConfirm: () async {
          return await context.read<AdminSancionesCubit>().deleteSancion(sancion.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Denuncias'),
            Tab(text: 'Sanciones'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDenunciasTab(),
              _buildSancionesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDenunciasTab() {
    return BlocBuilder<AdminDenunciasCubit, AdminDenunciasState>(
      builder: (context, state) {
        if (state is AdminDenunciasLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminDenunciasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminDenunciasCubit>().loadDenuncias();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (state is AdminDenunciasLoaded) {
          return _buildDenunciasList(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDenunciasList(AdminDenunciasLoaded state) {
    if (state.denuncias.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay denuncias',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AdminDenunciasCubit>().refresh();
      },
      child: ListView.builder(
        controller: _scrollControllerDenuncias,
        padding: const EdgeInsets.all(16),
        itemCount: state.denuncias.items.length,
        itemBuilder: (context, index) {
          final denuncia = state.denuncias.items[index];
          return _DenunciaCard(
            denuncia: denuncia,
            onTap: () => _showDenunciaDetailDialog(denuncia),
            onDelete: () => _showDenunciaDeleteDialog(denuncia),
          );
        },
      ),
    );
  }

  Widget _buildSancionesTab() {
    return BlocBuilder<AdminSancionesCubit, AdminSancionesState>(
      builder: (context, state) {
        if (state is AdminSancionesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminSancionesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminSancionesCubit>().loadSanciones();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (state is AdminSancionesLoaded) {
          return _buildSancionesList(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSancionesList(AdminSancionesLoaded state) {
    if (state.sanciones.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay sanciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton.filled(
                onPressed: _showSancionCreateDialog,
                icon: const Icon(Icons.add),
                tooltip: 'Nueva Sanción',
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<AdminSancionesCubit>().refresh();
            },
            child: ListView.builder(
              controller: _scrollControllerSanciones,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.sanciones.items.length,
              itemBuilder: (context, index) {
                final sancion = state.sanciones.items[index];
                return _SancionCard(
                  sancion: sancion,
                  onDelete: () => _showSancionDeleteDialog(sancion),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DenunciaCard extends StatelessWidget {
  final AdminDenuncia denuncia;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DenunciaCard({
    required this.denuncia,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      denuncia.motivo,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(denuncia.fechaCreacion),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Denunciante: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    denuncia.nombreUsuarioDenunciante,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_off_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Denunciado: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    denuncia.nombreUsuarioDenunciado,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                  ),
                ],
              ),
              if (denuncia.descripcion != null && denuncia.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  denuncia.descripcion!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outlined, size: 16),
                    label: const Text('Eliminar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SancionCard extends StatelessWidget {
  final AdminSancion sancion;
  final VoidCallback onDelete;

  const _SancionCard({
    required this.sancion,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sancion.nombreUsuario,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: sancion.activa
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sancion.tipoSancion,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: sancion.activa ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sancion.activa
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sancion.activa ? 'Activa' : 'Inactiva',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: sancion.activa ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            if (sancion.descripcion != null && sancion.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                sancion.descripcion!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Desde: ${_formatDate(sancion.fechaInicio)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (sancion.fechaFin != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.event_outlined, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Hasta: ${_formatDate(sancion.fechaFin!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outlined, size: 16),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
