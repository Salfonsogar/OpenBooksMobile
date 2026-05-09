import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/usuario.dart';
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
  }) : _authRepository = authRepository,
       _rolesRepository = rolesRepository,
       _sessionCubit = sessionCubit,
       super(AuthInitial());

  Future<void> login(String correo, String contrasena) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(correo, contrasena);
      await _buildUserAndLogin(
        response.usuario,
        response.token,
        response.usuario.rolId,
      );
      emit(AuthLoginSuccess(usuario: response.usuario, token: response.token));
    } catch (e) {
      emit(AuthError(_formatError(e)));
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
      await _buildUserAndLogin(response.usuario, response.token, rolId);
      emit(
        AuthRegisterSuccess(usuario: response.usuario, token: response.token),
      );
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

  Future<void> resetearContrasena(String token, String nuevaContrasena) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetearContrasena(token, nuevaContrasena);
      emit(AuthPasswordResetSuccess());
    } catch (e) {
      emit(AuthError(_formatError(e)));
    }
  }

  Future<void> _buildUserAndLogin(
    Usuario source,
    String token,
    int rolId,
  ) async {
    final nombreRol = await _getRoleName(rolId);

    final user = Usuario(
      id: source.id,
      userName: source.userName,
      nombreCompleto: source.nombreCompleto,
      email: source.email,
      estado: true,
      sancionado: source.sancionado,
      fechaRegistro: DateTime.now(),
      nombreRol: nombreRol,
      rolId: rolId,
      fotoPerfilBase64: source.fotoPerfilBase64,
    );

    await _sessionCubit.login(user: user, token: token);
  }

  Future<String> _getRoleName(int rolId) async {
    try {
      final rol = await _rolesRepository.getRol(rolId);
      if (rol != null) return rol.nombre;
    } catch (_) {}
    return 'Usuario';
  }

  String _formatError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}
