import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_notification.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  NotificationCubit() : super(NotificationInitial());

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    
    emit(NotificationLoaded(
      notifications: List.from(_notifications),
      unreadCount: _unreadCount,
    ));
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].leida) {
      _notifications[index] = _notifications[index].copyWith(leida: true);
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      
      emit(NotificationLoaded(
        notifications: List.from(_notifications),
        unreadCount: _unreadCount,
      ));
    }
  }

  void markAllAsRead() {
    _notifications.clear();
    _notifications.addAll(
      _notifications.map((n) => n.copyWith(leida: true)),
    );
    _unreadCount = 0;
    
    emit(NotificationLoaded(
      notifications: List.from(_notifications),
      unreadCount: _unreadCount,
    ));
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    
    emit(const NotificationLoaded(
      notifications: [],
      unreadCount: 0,
    ));
  }

  int get unreadCount => _unreadCount;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
}
