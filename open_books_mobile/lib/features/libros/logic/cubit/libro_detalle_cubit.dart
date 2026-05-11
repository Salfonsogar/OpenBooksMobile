import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/index.dart';
import '../../data/repositories/libros_repository.dart';
import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../../biblioteca/data/datasources/biblioteca_datasource.dart';

enum OperationType { valoracion, resena, denuncia }

abstract class LibroDetalleState extends Equatable {
  const LibroDetalleState();

  @override
  List<Object?> get props => [];
}

class LibroDetalleInitial extends LibroDetalleState {}

class LibroDetalleLoading extends LibroDetalleState {}

class LibroDetalleLoaded extends LibroDetalleState {
  final LibroDetalle libro;
  final bool estaEnBiblioteca;
  final OperationType? operationType;

  const LibroDetalleLoaded({
    required this.libro,
    this.estaEnBiblioteca = false,
    this.operationType,
  });

  @override
  List<Object?> get props => [libro, estaEnBiblioteca, operationType];

  bool get isValoracionSuccess => operationType == OperationType.valoracion;
  bool get isResenaSuccess => operationType == OperationType.resena;
  bool get isDenunciaSuccess => operationType == OperationType.denuncia;

  LibroDetalleLoaded copyWith({
    LibroDetalle? libro,
    bool? estaEnBiblioteca,
    OperationType? operationType,
    bool clearOperationType = false,
  }) {
    return LibroDetalleLoaded(
      libro: libro ?? this.libro,
      estaEnBiblioteca: estaEnBiblioteca ?? this.estaEnBiblioteca,
      operationType: clearOperationType ? null : (operationType ?? this.operationType),
    );
  }
}

class LibroDetalleError extends LibroDetalleState {
  final String message;

  const LibroDetalleError(this.message);

  @override
  List<Object> get props => [message];
}

class LibroDetalleCubit extends Cubit<LibroDetalleState> {
  final LibrosRepository _repository;
  final BibliotecaDataSource _bibliotecaDataSource;
  final SessionCubit _sessionCubit;
  int? _libroId;
  bool _estaEnBiblioteca = false;

  LibroDetalleCubit(
    this._repository,
    this._bibliotecaDataSource,
    this._sessionCubit,
  ) : super(LibroDetalleInitial());

  Future<void> cargarDetalle(int libroId) async {
    _libroId = libroId;
    emit(LibroDetalleLoading());
    try {
      final libroDetalle = await _repository.getLibroDetalle(libroId);
      if (libroDetalle == null) {
        emit(const LibroDetalleError('Libro no encontrado'));
        return;
      }
      
      bool enBiblioteca = false;
      final sessionState = _sessionCubit.state;
      if (sessionState is SessionAuthenticated) {
        try {
          final librosBiblioteca = await _bibliotecaDataSource.getLibrosBiblioteca(sessionState.userId);
          enBiblioteca = librosBiblioteca.any((l) => l.id == libroId);
          _estaEnBiblioteca = enBiblioteca;
        } catch (_) {
          enBiblioteca = false;
        }
      }
      
      emit(LibroDetalleLoaded(
        libro: libroDetalle,
        estaEnBiblioteca: enBiblioteca,
      ));
    } catch (e) {
      _handleAuthError(e);
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
      emit(LibroDetalleLoaded(
        libro: libroActualizado,
        estaEnBiblioteca: _estaEnBiblioteca,
      ));
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<void> valorar(int puntuacion) async {
    if (_libroId == null) return;

    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      await _repository.crearValoracion(_libroId!, puntuacion);
      final libro = await _repository.getLibroDetalle(_libroId!);
      if (libro != null) {
        emit(LibroDetalleLoaded(
          libro: libro,
          estaEnBiblioteca: _estaEnBiblioteca,
          operationType: OperationType.valoracion,
        ));
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('Ya has valorado')) {
        try {
          await _repository.actualizarValoracion(_libroId!, puntuacion);
          final libro = await _repository.getLibroDetalle(_libroId!);
          if (libro != null) {
            emit(LibroDetalleLoaded(
              libro: libro,
              estaEnBiblioteca: _estaEnBiblioteca,
              operationType: OperationType.valoracion,
            ));
          }
        } catch (e2) {
          _handleAuthError(e2);
        }
      } else {
        _handleAuthError(e);
      }
    }
  }

  Future<void> actualizarValoracion(int puntuacion) async {
    if (_libroId == null) return;

    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      await _repository.actualizarValoracion(_libroId!, puntuacion);
      final libro = await _repository.getLibroDetalle(_libroId!);
      if (libro != null) {
        emit(LibroDetalleLoaded(
          libro: libro,
          estaEnBiblioteca: _estaEnBiblioteca,
          operationType: OperationType.valoracion,
        ));
      }
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<void> eliminarValoracion() async {
    if (_libroId == null) return;

    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      await _repository.eliminarValoracion(_libroId!);
      final libro = await _repository.getLibroDetalle(_libroId!);
      if (libro != null) {
        emit(LibroDetalleLoaded(
          libro: libro,
          estaEnBiblioteca: _estaEnBiblioteca,
          operationType: OperationType.valoracion,
        ));
      }
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<void> escribirResena(String texto) async {
    if (_libroId == null) return;

    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      await _repository.crearResena(_libroId!, texto);
      final libro = await _repository.getLibroDetalle(_libroId!);
      if (libro != null) {
        emit(LibroDetalleLoaded(
          libro: libro,
          estaEnBiblioteca: _estaEnBiblioteca,
          operationType: OperationType.resena,
        ));
      }
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<void> agregarABiblioteca() async {
    if (_libroId == null) return;

    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    try {
      await _bibliotecaDataSource.agregarLibro(sessionState.userId, _libroId!);
      _estaEnBiblioteca = true;
      
      final currentState = state;
      if (currentState is LibroDetalleLoaded) {
        emit(currentState.copyWith(estaEnBiblioteca: true, clearOperationType: true));
      }
    } catch (e) {
      _handleAuthError(e);
    }
  }

  void recargar() {
    if (_libroId != null) {
      cargarDetalle(_libroId!);
    }
  }

  Future<void> denunciarResena({
    required String idDenunciante,
    required String idDenunciado,
    required int idResena,
    required String motivo,
    String? comentario,
  }) async {
    if (_libroId == null) return;

    final currentState = state;
    if (currentState is! LibroDetalleLoaded) return;

    try {
      await _repository.crearDenunciaResena(
        idDenunciante: idDenunciante,
        idDenunciado: idDenunciado,
        idResena: idResena,
        motivo: motivo,
        comentario: comentario,
      );
      emit(currentState.copyWith(
        operationType: OperationType.denuncia,
        clearOperationType: false,
      ));
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<void> _handleAuthError(dynamic error) async {
    final errorStr = error.toString();
    if (errorStr.contains('401') || errorStr.toLowerCase().contains('unauthorized')) {
      await _sessionCubit.logout();
      emit(const LibroDetalleError('Sesión expirada. Inicia sesión nuevamente.'));
    } else {
      emit(LibroDetalleError(errorStr.replaceAll('Exception: ', '')));
    }
  }
}