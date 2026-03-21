import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/roles_repository.dart';
import '../../../../shared/core/session/session_cubit.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final RolesRepository _rolesRepository;
  final SessionCubit _sessionCubit;

  AuthCubit({
    required AuthRepository authRepository,
    required RolesRepository rolesRepository,
    required SessionCubit sessionCubit,
  })  : _authRepository = authRepository,
        _rolesRepository = rolesRepository,
        _sessionCubit = sessionCubit,
        super(AuthInitial());

  Future<void> login(String correo, String contrasena) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(correo, contrasena);
      
      String nombreRol = 'Usuario';
      try {
        final rol = await _rolesRepository.getRol(response.usuario.rolId);
        if (rol != null) {
          nombreRol = rol.nombre;
        }
      } catch (_) {}

      await _sessionCubit.login(
        userId: response.usuario.id,
        userName: response.usuario.userName,
        email: response.usuario.email,
        nombreCompleto: response.usuario.nombreCompleto,
        rolId: response.usuario.rolId,
        nombreRol: nombreRol,
        sancionado: response.usuario.sancionado,
        token: response.token,
        fotoPerfilBase64: response.usuario.fotoPerfilBase64,
      );

      emit(AuthLoginSuccess(
        usuario: response.usuario,
        token: response.token,
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> register({
    required String nombreUsuario,
    required String correo,
    required String contrasena,
    required int rolId,
    required String nombreCompleto,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(
        nombreUsuario: nombreUsuario,
        correo: correo,
        contrasena: contrasena,
        rolId: rolId,
        nombreCompleto: nombreCompleto,
      );

      String nombreRol = 'Usuario';
      try {
        final rol = await _rolesRepository.getRol(rolId);
        if (rol != null) {
          nombreRol = rol.nombre;
        }
      } catch (_) {}

      await _sessionCubit.login(
        userId: response.usuario.id,
        userName: response.usuario.userName,
        email: response.usuario.email,
        nombreCompleto: response.usuario.nombreCompleto,
        rolId: rolId,
        nombreRol: nombreRol,
        sancionado: response.usuario.sancionado,
        token: response.token,
      );

      emit(AuthRegisterSuccess(
        usuario: response.usuario,
        token: response.token,
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> solicitarRecuperacion(String correo) async {
    emit(AuthLoading());
    try {
      await _authRepository.solicitarRecuperacion(correo);
      emit(const AuthRecoverySent('Se ha enviado un correo de recuperación a tu email'));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> resetearContrasena(String token, String nuevaContrasena) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetearContrasena(token, nuevaContrasena);
      emit(AuthPasswordResetSuccess());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void resetState() {
    emit(AuthInitial());
  }
}
