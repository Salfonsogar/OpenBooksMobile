import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_notification.dart';
import '../../logic/cubit/notification_cubit.dart';
import '../../logic/cubit/notification_state.dart';
import 'notification_popup.dart';

class NotificationOverlayManager extends StatefulWidget {
  final Widget child;
  final VoidCallback? onViewNotifications;

  const NotificationOverlayManager({
    super.key,
    required this.child,
    this.onViewNotifications,
  });

  @override
  State<NotificationOverlayManager> createState() => _NotificationOverlayManagerState();
}

class _NotificationOverlayManagerState extends State<NotificationOverlayManager> {
  final List<AppNotification> _queue = [];
  bool _isShowing = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _setupSubscription();
  }

  void _setupSubscription() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<NotificationCubit>();
      _subscription = cubit.stream.listen((state) {
        if (state is NotificationLoaded && 
            state.notifications.isNotEmpty &&
            !state.notifications.first.leida) {
          _showNotification(state.notifications.first);
        }
      });
    });
  }

  void _showNotification(AppNotification notification) {
    if (_isShowing) {
      _queue.add(notification);
      return;
    }

    _isShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _displayNotification(notification);
    });
  }

  void _displayNotification(AppNotification notification) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: NotificationPopup(
            notification: notification,
            onView: () {
              entry.remove();
              _onPopupDismissed();
              widget.onViewNotifications?.call();
            },
            onDismiss: () {
              entry.remove();
              _onPopupDismissed();
            },
          ),
        ),
      ),
    );

    overlay.insert(entry);
  }

  void _onPopupDismissed() {
    _isShowing = false;
    
    if (_queue.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _queue.isNotEmpty) {
          final next = _queue.removeAt(0);
          _showNotification(next);
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
