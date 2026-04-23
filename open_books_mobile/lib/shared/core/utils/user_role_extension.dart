import '../../../features/auth/logic/cubit/auth_state.dart';
import '../../../features/auth/data/models/usuario.dart';

enum UserRole { admin, usuario }

extension RoleX on Usuario {
  bool get isAdmin => nombreRol == 'Admin';
  bool get isUsuario => nombreRol == 'Usuario';
}

extension SessionRoleX on AuthState {
  bool get isAdmin {
    final user = usuario;
    if (user == null) return false;
    return user.nombreRol == 'Admin';
  }

  Usuario? get usuario {
    if (this is AuthLoginSuccess) {
      return (this as AuthLoginSuccess).usuario;
    }
    if (this is AuthRegisterSuccess) {
      return (this as AuthRegisterSuccess).usuario;
    }
    return null;
  }
}
