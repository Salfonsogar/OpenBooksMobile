import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../features/notifications/data/models/app_notification.dart';
import '../../../features/notifications/logic/cubit/notification_cubit.dart';
import '../../services/signalr_service.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  SignalRService? _signalRService;
  NotificationCubit? _notificationCubit;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  SessionCubit() : super(SessionInitial());

  void setNotificationCubit(NotificationCubit cubit) {
    _notificationCubit = cubit;
  }

  Future<void> checkSession() async {
    emit(SessionLoading());

    try {
      final token = await _storage.read(key: _tokenKey);
      final userData = await _storage.read(key: _userKey);

      if (token != null && userData != null) {
        final user = jsonDecode(userData);
        emit(SessionAuthenticated(
          userId: user['id'],
          userName: user['userName'] ?? '',
          email: user['email'] ?? '',
          nombreCompleto: user['nombreCompleto'] ?? '',
          nombreRol: user['nombreRol'] ?? 'Usuario',
          sancionado: user['sancionado'] ?? false,
          token: token,
          fotoPerfilBase64: user['fotoPerfilBase64'],
        ));
        _connectSignalR();
      } else {
        emit(SessionUnauthenticated());
      }
    } catch (e) {
      emit(SessionUnauthenticated());
    }
  }

  Future<void> login({
    required int userId,
    required String userName,
    required String email,
    required String nombreCompleto,
    required String nombreRol,
    required bool sancionado,
    required String token,
    String? fotoPerfilBase64,
  }) async {
    await _storage.write(key: _tokenKey, value: token);

    final user = {
      'id': userId,
      'userName': userName,
      'email': email,
      'nombreCompleto': nombreCompleto,
      'nombreRol': nombreRol,
      'sancionado': sancionado,
      'fotoPerfilBase64': fotoPerfilBase64,
    };
    await _storage.write(key: _userKey, value: jsonEncode(user));

    emit(SessionAuthenticated(
      userId: userId,
      userName: userName,
      email: email,
      nombreCompleto: nombreCompleto,
      nombreRol: nombreRol,
      sancionado: sancionado,
      token: token,
      fotoPerfilBase64: fotoPerfilBase64,
    ));

    _connectSignalR();
  }

  void _connectSignalR() {
    if (_signalRService != null) return;

    _signalRService = SignalRService(
      onNotificationReceived: _handleNotification,
      onConnected: () {
        // ignore: avoid_print
        print('SignalR: Conectado');
      },
      onError: (error) {
        // ignore: avoid_print
        print('SignalR Error: $error');
      },
    );

    _signalRService!.connect();
  }

  void _handleNotification(AppNotification notification) {
    _notificationCubit?.addNotification(notification);
  }

  Future<void> logout() async {
    await _signalRService?.disconnect();
    _signalRService = null;
    _notificationCubit?.clearNotifications();
    
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    emit(SessionUnauthenticated());
  }

  Future<void> updateUser({
    String? userName,
    String? email,
    String? nombreCompleto,
    String? fotoPerfilBase64,
  }) async {
    final currentState = state;
    if (currentState is SessionAuthenticated) {
      final user = {
        'id': currentState.userId,
        'userName': userName ?? currentState.userName,
        'email': email ?? currentState.email,
        'nombreCompleto': nombreCompleto ?? currentState.nombreCompleto,
        'nombreRol': currentState.nombreRol,
        'sancionado': currentState.sancionado,
        'fotoPerfilBase64': fotoPerfilBase64 ?? currentState.fotoPerfilBase64,
      };
      await _storage.write(key: _userKey, value: jsonEncode(user));

      emit(SessionAuthenticated(
        userId: currentState.userId,
        userName: userName ?? currentState.userName,
        email: email ?? currentState.email,
        nombreCompleto: nombreCompleto ?? currentState.nombreCompleto,
        nombreRol: currentState.nombreRol,
        sancionado: currentState.sancionado,
        token: currentState.token,
        fotoPerfilBase64: fotoPerfilBase64 ?? currentState.fotoPerfilBase64,
      ));
    }
  }
}
