import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../../features/notifications/logic/cubit/notification_cubit.dart';
import '../../../features/notifications/logic/cubit/notification_state.dart';

class SearchHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onFilterTap;
  final bool showFilterIcon;

  const SearchHeader({
    super.key,
    this.onSearchTap,
    this.onProfileTap,
    this.onFilterTap,
    this.showFilterIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Expanded(
              child: GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Buscar libros...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: showFilterIcon ? onFilterTap : onProfileTap,
              child: showFilterIcon
                  ? const SizedBox.shrink()
                  : BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (context, notificationState) {
                        final unreadCount = notificationState is NotificationLoaded
                            ? notificationState.unreadCount
                            : 0;
                        
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            BlocBuilder<SessionCubit, SessionState>(
                              builder: (context, state) {
                                if (state is SessionAuthenticated &&
                                    state.fotoPerfilBase64 != null &&
                                    state.fotoPerfilBase64!.isNotEmpty) {
                                  try {
                                    return CircleAvatar(
                                      radius: 20,
                                      backgroundImage: MemoryImage(
                                        base64Decode(state.fotoPerfilBase64!),
                                      ),
                                    );
                                  } catch (e) {
                                    return CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primaryContainer,
                                      child: Text(
                                        state.userName.isNotEmpty
                                            ? state.userName[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                }
                                final initial = state is SessionAuthenticated &&
                                        state.userName.isNotEmpty
                                    ? state.userName[0].toUpperCase()
                                    : '?';
                                return CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primaryContainer,
                                  child: Text(
                                    initial,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onError,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
