import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';
import 'package:open_books_mobile/features/admin/sugerencias/data/models/admin_sugerencia.dart';
import 'package:open_books_mobile/features/admin/sugerencias/logic/cubit/admin_sugerencias_cubit.dart';
import 'package:open_books_mobile/features/admin/sugerencias/ui/widgets/sugerencia_detail_dialog.dart';
import 'package:open_books_mobile/features/admin/sugerencias/ui/widgets/sugerencia_delete_dialog.dart';

class AdminSugerenciasPage extends StatefulWidget {
  const AdminSugerenciasPage({super.key});

  @override
  State<AdminSugerenciasPage> createState() => _AdminSugerenciasPageState();
}

class _AdminSugerenciasPageState extends State<AdminSugerenciasPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initCubit();
    _scrollController.addListener(_onScroll);
  }

  void _initCubit() {
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) {
      context.read<AdminSugerenciasCubit>().setToken(sessionState.token);
    }
    context.read<AdminSugerenciasCubit>().loadSugerencias();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminSugerenciasCubit>().loadMoreSugerencias();
    }
  }

  void _showDetailDialog(AdminSugerencia sugerencia) {
    showDialog(
      context: context,
      builder: (dialogContext) => SugerenciaDetailDialog(sugerencia: sugerencia),
    );
  }

  void _showDeleteDialog(AdminSugerencia sugerencia) {
    showDialog(
      context: context,
      builder: (dialogContext) => SugerenciaDeleteDialog(
        sugerencia: sugerencia,
        onConfirm: () async {
          return await context.read<AdminSugerenciasCubit>().deleteSugerencia(sugerencia.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocBuilder<AdminSugerenciasCubit, AdminSugerenciasState>(
              builder: (context, state) {
                if (state is AdminSugerenciasLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AdminSugerenciasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AdminSugerenciasCubit>().loadSugerencias();
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is AdminSugerenciasLoaded) {
                  return _buildSugerenciasList(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Sugerencias',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugerenciasList(AdminSugerenciasLoaded state) {
    if (state.sugerencias.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay sugerencias',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AdminSugerenciasCubit>().refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.sugerencias.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.sugerencias.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final sugerencia = state.sugerencias.items[index];
          return _SugerenciaCard(
            sugerencia: sugerencia,
            onTap: () => _showDetailDialog(sugerencia),
            onDelete: () => _showDeleteDialog(sugerencia),
          );
        },
      ),
    );
  }
}

class _SugerenciaCard extends StatelessWidget {
  final AdminSugerencia sugerencia;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SugerenciaCard({
    required this.sugerencia,
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
                  Expanded(
                    child: Text(
                      sugerencia.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    _formatDate(sugerencia.fechaCreacion),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    sugerencia.nombreUsuario,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              if (sugerencia.descripcion != null && sugerencia.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  sugerencia.descripcion!,
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
