import 'package:equatable/equatable.dart';

import '../../../features/auth/data/models/usuario.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionAuthenticated extends SessionState {
  final Usuario user;
  final String token;

  const SessionAuthenticated({
    required this.user,
    required this.token,
  });

  String get userId => user.id;
  String get userName => user.userName;
  String get email => user.email;
  String get nombreCompleto => user.nombreCompleto;
  String get nombreRol => user.nombreRol;
  String? get fotoPerfilUrl => user.fotoPerfilUrl;
  bool get isAdmin => user.isAdmin;

  @override
  List<Object?> get props => [user, token];
}

class SessionUnauthenticated extends SessionState {}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}
