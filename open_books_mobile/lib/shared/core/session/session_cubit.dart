import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../features/auth/data/models/usuario.dart';
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
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        final user = Usuario.fromJson(userJson);
        emit(SessionAuthenticated(
          user: user,
          token: token,
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
    required Usuario user,
    required String token,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

    emit(SessionAuthenticated(
      user: user,
      token: token,
    ));

    _connectSignalR();
  }

  void _connectSignalR() {
    if (_signalRService != null) return;

    _signalRService = SignalRService(
      onNotificationReceived: _handleNotification,
      onConnected: () {},
      onError: (error) {},
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
      final updatedUser = Usuario(
        id: currentState.user.id,
        userName: userName ?? currentState.user.userName,
        nombreCompleto: nombreCompleto ?? currentState.user.nombreCompleto,
        email: email ?? currentState.user.email,
        estado: currentState.user.estado,
        sancionado: currentState.user.sancionado,
        fechaRegistro: currentState.user.fechaRegistro,
        nombreRol: currentState.user.nombreRol,
        rolId: currentState.user.rolId,
        fotoPerfilBase64: fotoPerfilBase64 ?? currentState.user.fotoPerfilBase64,
      );
      
      await _storage.write(key: _userKey, value: jsonEncode(updatedUser.toJson()));

      emit(SessionAuthenticated(
        user: updatedUser,
        token: currentState.token,
      ));
    }
  }
}
