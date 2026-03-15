import 'package:equatable/equatable.dart';

import '../../data/models/models.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final Usuario usuario;
  final String token;

  const AuthLoginSuccess({
    required this.usuario,
    required this.token,
  });

  @override
  List<Object?> get props => [usuario, token];
}

class AuthRegisterSuccess extends AuthState {
  final Usuario usuario;
  final String token;

  const AuthRegisterSuccess({
    required this.usuario,
    required this.token,
  });

  @override
  List<Object?> get props => [usuario, token];
}

class AuthRecoverySent extends AuthState {
  final String message;

  const AuthRecoverySent(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
