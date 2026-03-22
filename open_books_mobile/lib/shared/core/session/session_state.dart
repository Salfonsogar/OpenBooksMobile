import 'package:equatable/equatable.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionAuthenticated extends SessionState {
  final int userId;
  final String userName;
  final String email;
  final String nombreCompleto;
  final String nombreRol;
  final int rolId;
  final bool sancionado;
  final String token;
  final String? fotoPerfilBase64;

  const SessionAuthenticated({
    required this.userId,
    required this.userName,
    required this.email,
    required this.nombreCompleto,
    required this.nombreRol,
    required this.rolId,
    required this.sancionado,
    required this.token,
    this.fotoPerfilBase64,
  });

  bool get isAdmin => rolId == 1 || nombreRol.toLowerCase() == 'administrador';

  @override
  List<Object?> get props => [userId, userName, email, nombreCompleto, nombreRol, rolId, sancionado, token, fotoPerfilBase64];
}

class SessionUnauthenticated extends SessionState {}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}
