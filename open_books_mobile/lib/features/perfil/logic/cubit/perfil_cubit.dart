import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../data/repositories/perfil_repository.dart';
import '../../data/models/update_perfil_request.dart';
import '../../../auth/data/models/usuario.dart';

abstract class PerfilState extends Equatable {
  const PerfilState();

  @override
  List<Object?> get props => [];
}

class PerfilInitial extends PerfilState {}

class PerfilLoading extends PerfilState {}

class PerfilLoaded extends PerfilState {
  final Usuario usuario;

  const PerfilLoaded({required this.usuario});

  @override
  List<Object> get props => [usuario];

  PerfilLoaded copyWith({Usuario? usuario}) {
    return PerfilLoaded(usuario: usuario ?? this.usuario);
  }
}

class PerfilError extends PerfilState {
  final String message;

  const PerfilError(this.message);

  @override
  List<Object> get props => [message];
}

class PerfilCubit extends Cubit<PerfilState> {
  final PerfilRepository _repository;
  final SessionCubit _sessionCubit;
  StreamSubscription? _sessionSubscription;

  PerfilCubit({
    required PerfilRepository repository,
    required SessionCubit sessionCubit,
  })  : _repository = repository,
        _sessionCubit = sessionCubit,
        super(PerfilInitial()) {
    _listenToSession();
  }

  void _listenToSession() {
    _sessionSubscription = _sessionCubit.stream.listen((sessionState) {
      if (sessionState is SessionAuthenticated) {
        cargarPerfil();
      } else if (sessionState is SessionUnauthenticated) {
        emit(PerfilInitial());
      }
    });

    if (_sessionCubit.state is SessionAuthenticated) {
      cargarPerfil();
    }
  }

  Future<void> cargarPerfil() async {
    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    emit(PerfilLoading());
    try {
      final usuario = await _repository.getPerfil(sessionState.userId);
      emit(PerfilLoaded(usuario: usuario));
    } catch (e) {
      emit(PerfilError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> actualizarPerfil({
    String? userName,
    String? nombreCompleto,
    String? fotoPerfilBase64,
  }) async {
    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    try {
      final request = UpdatePerfilRequest(
        userName: userName,
        nombreCompleto: nombreCompleto,
        fotoPerfilBase64: fotoPerfilBase64,
      );
      final usuario = await _repository.updatePerfil(sessionState.userId, request);
      
      if (fotoPerfilBase64 != null) {
        await _sessionCubit.updateUser(fotoPerfilBase64: fotoPerfilBase64);
      }
      
      emit(PerfilLoaded(usuario: usuario));
    } catch (e) {
      emit(PerfilError(e.toString().replaceAll('Exception: ', '')));
      await cargarPerfil();
    }
  }

  Future<void> actualizarCorreo({
    required String email,
    required String contrasena,
  }) async {
    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    try {
      await _repository.cambiarCorreo(sessionState.userId, email, contrasena);
      await cargarPerfil();
    } catch (e) {
      emit(PerfilError(e.toString().replaceAll('Exception: ', '')));
      await cargarPerfil();
    }
  }

  Future<void> actualizarContrasena({
    required String contrasenaActual,
    required String nuevaContrasena,
  }) async {
    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    try {
      await _repository.cambiarContrasena(sessionState.userId, contrasenaActual, nuevaContrasena);
      await cargarPerfil();
    } catch (e) {
      emit(PerfilError(e.toString().replaceAll('Exception: ', '')));
      await cargarPerfil();
    }
  }

  Future<void> refresh() async {
    await cargarPerfil();
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}
