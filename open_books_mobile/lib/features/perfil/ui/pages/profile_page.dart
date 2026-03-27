import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/perfil_cubit.dart';
import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/ui/widgets/close_header.dart';
import '../../../../shared/ui/widgets/options_list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseHeader(
        onClose: () => context.go('/home'),
      ),
      body: BlocConsumer<PerfilCubit, PerfilState>(
        listener: (context, state) {
          if (state is PerfilError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PerfilLoading || state is PerfilInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PerfilError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<PerfilCubit>().cargarPerfil(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final usuario = state is PerfilLoaded ? state.usuario : null;

          if (usuario == null) {
            return const Center(child: Text('No se pudo cargar el perfil'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<PerfilCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: usuario.fotoPerfilBase64 != null &&
                                usuario.fotoPerfilBase64!.isNotEmpty
                            ? MemoryImage(base64Decode(usuario.fotoPerfilBase64!))
                            : null,
                        child: usuario.fotoPerfilBase64 == null ||
                                usuario.fotoPerfilBase64!.isEmpty
                            ? Text(
                                usuario.userName.isNotEmpty
                                    ? usuario.userName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 40),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              context.pushReplacement('/profile/edit', extra: usuario);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '@${usuario.userName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (usuario.sancionado) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tu cuenta está sancionada',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.pushReplacement('/profile/edit', extra: usuario);
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Gestionar tu cuenta'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  OptionsList(
                    options: [
                      OptionItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notificaciones',
                        onTap: () {
                          context.push('/notifications');
                        },
                      ),
                      OptionItem(
                        icon: Icons.tune,
                        title: 'Ajustes',
                        onTap: () {
                          context.push('/settings');
                        },
                      ),
                      OptionItem(
                        icon: Icons.help_outline,
                        title: 'Ayuda y comentarios',
                        onTap: () {
                          context.push('/ayuda-comentarios');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Cerrar sesión',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SessionCubit>().logout();
              context.go('/login');
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
