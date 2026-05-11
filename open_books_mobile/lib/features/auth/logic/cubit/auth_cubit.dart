import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/usuario.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/utils/jwt_utils.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SessionCubit _sessionCubit;

  AuthCubit({
    required AuthRepository authRepository,
    required SessionCubit sessionCubit,
  }) : _authRepository = authRepository,
       _sessionCubit = sessionCubit,
       super(AuthInitial());

  Future<void> login(String correo, String contrasena) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(correo, contrasena);

      final userId = _extractUserId(response.token);
      final claims = _extractClaims(response.token);
      final nombreRol = claims.contains('Administrador') ? 'Administrador' : 'Usuario';

      final user = Usuario(
        id: userId,
        userName: response.username,
        nombreCompleto: response.username,
        email: response.correo,
        estado: true,
        fechaRegistro: DateTime.now(),
        nombreRol: nombreRol,
        fotoPerfilUrl: response.fotoPerfilUrl,
      );

      await _sessionCubit.login(user: user, token: response.token);
      emit(AuthLoginSuccess(usuario: user, token: response.token));
    } catch (e) {
      emit(AuthError(_formatError(e)));
    }
  }

  Future<void> register({
    required String userName,
    required String correo,
    required String contrasena,
  }) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(
        userName: userName,
        correo: correo,
        contrasena: contrasena,
      );
      await login(correo, contrasena);
    } catch (e) {
      emit(AuthError(_formatError(e)));
    }
  }

  Future<void> solicitarRecuperacion(String correo) async {
    emit(AuthLoading());
    try {
      await _authRepository.solicitarRecuperacion(correo);
      emit(
        const AuthRecoverySent(
          'Se ha enviado un correo de recuperación a tu email',
        ),
      );
    } catch (e) {
      emit(AuthError(_formatError(e)));
    }
  }

  Future<void> resetearContrasena(
    String email,
    String token,
    String nuevaContrasena,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetearContrasena(email, token, nuevaContrasena);
      emit(AuthPasswordResetSuccess());
    } catch (e) {
      emit(AuthError(_formatError(e)));
    }
  }

  String _extractUserId(String token) {
    final payload = decodeJwtPayload(token);
    const key = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
    return payload[key] as String? ?? '';
  }

  List<String> _extractClaims(String token) {
    final payload = decodeJwtPayload(token);
    const roleKey = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
    final role = payload[roleKey];
    if (role is List) return role.cast<String>();
    if (role is String) return [role];
    return [];
  }

  String _formatError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}
