import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/models.dart';
import '../../data/repositories/libros_repository.dart';

abstract class LibroDetalleState extends Equatable {
  const LibroDetalleState();

  @override
  List<Object?> get props => [];
}

class LibroDetalleInitial extends LibroDetalleState {}

class LibroDetalleLoading extends LibroDetalleState {}

class LibroDetalleLoaded extends LibroDetalleState {
  final LibroDetalle libro;

  const LibroDetalleLoaded(this.libro);

  @override
  List<Object> get props => [libro];
}

class LibroDetalleError extends LibroDetalleState {
  final String message;

  const LibroDetalleError(this.message);

  @override
  List<Object> get props => [message];
}

class ValoracionSuccess extends LibroDetalleState {
  final LibroDetalle libro;

  const ValoracionSuccess(this.libro);

  @override
  List<Object> get props => [libro];
}

class ResenaSuccess extends LibroDetalleState {
  final LibroDetalle libro;

  const ResenaSuccess(this.libro);

  @override
  List<Object> get props => [libro];
}

class LibroDetalleCubit extends Cubit<LibroDetalleState> {
  final LibrosRepository _repository;
  int? _libroId;

  LibroDetalleCubit(this._repository) : super(LibroDetalleInitial());

  Future<void> cargarDetalle(int libroId) async {
    _libroId = libroId;
    emit(LibroDetalleLoading());
    try {
      final libro = await _repository.getLibroDetalle(libroId);
      emit(LibroDetalleLoaded(libro));
    } catch (e) {
      emit(LibroDetalleError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> cargarMasResenas(int page) async {
    if (_libroId == null) return;
    
    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      final result = await _repository.getResenasLibro(_libroId!, page: page);
      final libroActualizado = currentState.libro.copyWith(
        resenas: [...currentState.libro.resenas, ...result.data],
      );
      emit(LibroDetalleLoaded(libroActualizado));
    } catch (e) {
      emit(LibroDetalleError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> valorar(int puntuacion) async {
    if (_libroId == null) return;

    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      await _repository.crearValoracion(_libroId!, puntuacion);
      final libro = await _repository.getLibroDetalle(_libroId!);
      emit(ValoracionSuccess(libro));
    } catch (e) {
      emit(LibroDetalleError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> actualizarValoracion(int puntuacion) async {
    if (_libroId == null) return;

    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      await _repository.actualizarValoracion(_libroId!, puntuacion);
      final libro = await _repository.getLibroDetalle(_libroId!);
      emit(ValoracionSuccess(libro));
    } catch (e) {
      emit(LibroDetalleError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> eliminarValoracion() async {
    if (_libroId == null) return;

    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      await _repository.eliminarValoracion(_libroId!);
      final libro = await _repository.getLibroDetalle(_libroId!);
      emit(ValoracionSuccess(libro));
    } catch (e) {
      emit(LibroDetalleError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> escribirResena(String texto) async {
    if (_libroId == null) return;

    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      await _repository.crearResena(_libroId!, texto);
      final libro = await _repository.getLibroDetalle(_libroId!);
      emit(ResenaSuccess(libro));
    } catch (e) {
      emit(LibroDetalleError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void recargar() {
    if (_libroId != null) {
      cargarDetalle(_libroId!);
    }
  }
}
