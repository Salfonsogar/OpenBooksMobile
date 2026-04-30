import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_notification.dart';
import '../../data/repositories/notification_repository_impl.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepositoryImpl repository;

  NotificationCubit({required this.repository}) : super(NotificationInitial());

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      final result = await repository.getNotifications();
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (notifications) {
          final unreadCount = notifications.where((n) => !n.leida).length;
          emit(NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ));
        },
      );
    } catch (e) {
      emit(NotificationError('Error inesperado: $e'));
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    try {
      final result = await repository.addNotification(notification);
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (_) {
          final currentState = state;
          if (currentState is NotificationLoaded) {
            final updatedList = [notification, ...currentState.notifications];
            emit(NotificationLoaded(
              notifications: updatedList,
              unreadCount: currentState.unreadCount + 1,
            ));
          }
          emit(NotificationReceived(notification));
        },
      );
    } catch (e) {
      emit(NotificationError('Error al agregar notificación: $e'));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final result = await repository.markAsRead(notificationId);
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (_) {
          final currentState = state;
          if (currentState is NotificationLoaded) {
            final updatedList = currentState.notifications.map((n) {
              return n.id == notificationId ? n.copyWith(leida: true) : n;
            }).toList();
            final unreadCount = updatedList.where((n) => !n.leida).length;
            emit(NotificationLoaded(
              notifications: updatedList,
              unreadCount: unreadCount,
            ));
          }
        },
      );
    } catch (e) {
      emit(NotificationError('Error al marcar como leída: $e'));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final result = await repository.markAllAsRead();
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (_) {
          final currentState = state;
          if (currentState is NotificationLoaded) {
            final updatedList = currentState.notifications
                .map((n) => n.copyWith(leida: true))
                .toList();
            emit(NotificationLoaded(
              notifications: updatedList,
              unreadCount: 0,
            ));
          }
        },
      );
    } catch (e) {
      emit(NotificationError('Error al marcar todas como leídas: $e'));
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final result = await repository.deleteNotification(notificationId);
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (_) {
          final currentState = state;
          if (currentState is NotificationLoaded) {
            final updatedList = currentState.notifications
                .where((n) => n.id != notificationId)
                .toList();
            final unreadCount = updatedList.where((n) => !n.leida).length;
            emit(NotificationLoaded(
              notifications: updatedList,
              unreadCount: unreadCount,
            ));
          }
        },
      );
    } catch (e) {
      emit(NotificationError('Error al eliminar notificación: $e'));
    }
  }

  Future<void> clearNotifications() async {
    try {
      final result = await repository.clearAll();
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (_) => emit(const NotificationLoaded(
          notifications: [],
          unreadCount: 0,
        )),
      );
    } catch (e) {
      emit(NotificationError('Error al limpiar notificaciones: $e'));
    }
  }
}

