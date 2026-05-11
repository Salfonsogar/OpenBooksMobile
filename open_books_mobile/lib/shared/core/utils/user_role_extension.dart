import '../../../features/auth/logic/cubit/auth_state.dart';
import '../../../features/auth/data/models/usuario.dart';

enum UserRole { admin, usuario }

extension SessionRoleX on AuthState {
  bool get isAdmin {
    if (this is AuthLoginSuccess) {
      return (this as AuthLoginSuccess).usuario.isAdmin;
    }
    return false;
  }

  Usuario? get usuario {
    if (this is AuthLoginSuccess) {
      return (this as AuthLoginSuccess).usuario;
    }
    return null;
  }
}
