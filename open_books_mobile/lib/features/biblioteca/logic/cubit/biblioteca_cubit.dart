import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../data/models/libro_biblioteca.dart';
import '../../data/repositories/biblioteca_repository.dart';

abstract class BibliotecaState extends Equatable {
  const BibliotecaState();

  @override
  List<Object?> get props => [];
}

class BibliotecaInitial extends BibliotecaState {}

class BibliotecaLoading extends BibliotecaState {}

class BibliotecaLoaded extends BibliotecaState {
  final List<LibroBiblioteca> libros;

  const BibliotecaLoaded({required this.libros});

  @override
  List<Object> get props => [libros];

  BibliotecaLoaded copyWith({List<LibroBiblioteca>? libros}) {
    return BibliotecaLoaded(libros: libros ?? this.libros);
  }

  bool tieneLibro(int libroId) {
    return libros.any((l) => l.id == libroId);
  }
}

class BibliotecaError extends BibliotecaState {
  final String message;

  const BibliotecaError(this.message);

  @override
  List<Object> get props => [message];
}

class BibliotecaCubit extends Cubit<BibliotecaState> {
  final BibliotecaRepository _repository;
  final SessionCubit _sessionCubit;
  bool _isLoading = false;

  BibliotecaCubit({
    required BibliotecaRepository repository,
    required SessionCubit sessionCubit,
  })  : _repository = repository,
        _sessionCubit = sessionCubit,
        super(BibliotecaInitial());

  Future<void> cargarBiblioteca() async {
    if (_isLoading) return;

    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) {
      return;
    }

    _isLoading = true;
    emit(BibliotecaLoading());

    try {
      final libros = await _repository.getLibrosBiblioteca(sessionState.userId);
      emit(BibliotecaLoaded(libros: libros));
    } catch (e) {
      emit(BibliotecaError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> agregarLibro(int libroId) async {
    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    try {
      await _repository.agregarLibro(sessionState.userId, libroId);
      await cargarBiblioteca();
    } catch (e) {
      emit(BibliotecaError(e.toString().replaceAll('Exception: ', '')));
      await cargarBiblioteca();
    }
  }

  Future<void> quitarLibro(int libroId) async {
    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    try {
      await _repository.quitarLibro(sessionState.userId, libroId);
      await cargarBiblioteca();
    } catch (e) {
      emit(BibliotecaError(e.toString().replaceAll('Exception: ', '')));
      await cargarBiblioteca();
    }
  }

  bool tieneLibro(int libroId) {
    final currentState = state;
    if (currentState is BibliotecaLoaded) {
      return currentState.tieneLibro(libroId);
    }
    return false;
  }

  Future<void> refresh() async {
    await cargarBiblioteca();
  }

  Future<String> descargarLibro(int libroId) async {
    return _repository.descargarLibro(libroId);
  }
}
