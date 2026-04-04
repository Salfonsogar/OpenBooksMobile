import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../shared/core/environment/env.dart';
import '../../features/notifications/data/models/app_notification.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final void Function(AppNotification)? onNotificationReceived;
  final void Function()? onConnected;
  final void Function(Exception)? onError;
  final void Function()? onDisconnected;

  bool _isConnecting = false;
  bool _isConnected = false;

  SignalRService({
    this.onNotificationReceived,
    this.onConnected,
    this.onError,
    this.onDisconnected,
  });

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;
    _isConnecting = true;

    try {
      final env = Env();
      final hubUrl = '${env.signalrUrl}';

      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl)
          .withAutomaticReconnect(retryDelays: [1, 3, 5, 10, 15, 30])
          .build();

      _hubConnection!.on('RecibirNotificacion', (message) {
        if (message != null && message.isNotEmpty) {
          _handleNotification(message.first as Map<String, dynamic>);
        }
      });

      await _hubConnection!.start();
      _isConnected = true;
      _isConnecting = false;
      onConnected?.call();
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      onError?.call(e is Exception ? e : Exception(e.toString()));
    }
  }

  void _handleNotification(Map<String, dynamic> data) {
    try {
      final notification = AppNotification(
        id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: data['titulo'] ?? 'Notificación',
        mensaje: data['mensaje'] ?? '',
        tipo: data['tipo'] ?? 'sistema',
        createdAt: data['fecha'] != null
            ? DateTime.tryParse(data['fecha'].toString()) ?? DateTime.now()
            : DateTime.now(),
        leida: false,
      );

      onNotificationReceived?.call(notification);
    } catch (e) {
      // Silent fail for notification processing
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
      } catch (e) {
        // Silent fail on disconnect
      }
      _hubConnection = null;
    }
    _isConnected = false;
    _isConnecting = false;
  }

  Future<void> reconnect() async {
    await disconnect();
    await connect();
  }
}
