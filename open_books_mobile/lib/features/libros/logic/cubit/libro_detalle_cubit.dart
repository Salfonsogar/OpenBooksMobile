import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/models.dart';
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
  final String? portadaBase64;
  final bool estaEnBiblioteca;
  final OperationType? operationType;

  const LibroDetalleLoaded({
    required this.libro,
    this.portadaBase64,
    this.estaEnBiblioteca = false,
    this.operationType,
  });

  @override
  List<Object?> get props => [libro, portadaBase64, estaEnBiblioteca, operationType];

  bool get isValoracionSuccess => operationType == OperationType.valoracion;
  bool get isResenaSuccess => operationType == OperationType.resena;
  bool get isDenunciaSuccess => operationType == OperationType.denuncia;

  LibroDetalleLoaded copyWith({
    LibroDetalle? libro,
    String? portadaBase64,
    bool? estaEnBiblioteca,
    OperationType? operationType,
    bool clearOperationType = false,
  }) {
    return LibroDetalleLoaded(
      libro: libro ?? this.libro,
      portadaBase64: portadaBase64 ?? this.portadaBase64,
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
  String? _portadaBase64;
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
      final libro = await _repository.getLibroDetalle(libroId);
      
      String? portada;
      bool enBiblioteca = false;
      
      try {
        portada = await _repository.getPortada(libroId);
      } catch (_) {
        portada = null;
      }
      
      _portadaBase64 = portada;
      
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
        libro: libro,
        portadaBase64: portada,
        estaEnBiblioteca: enBiblioteca,
      ));
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
      emit(LibroDetalleLoaded(
        libro: libroActualizado,
        portadaBase64: _portadaBase64,
        estaEnBiblioteca: _estaEnBiblioteca,
      ));
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
      emit(LibroDetalleLoaded(
        libro: libro,
        portadaBase64: _portadaBase64,
        estaEnBiblioteca: _estaEnBiblioteca,
        operationType: OperationType.valoracion,
      ));
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
      emit(LibroDetalleLoaded(
        libro: libro,
        portadaBase64: _portadaBase64,
        estaEnBiblioteca: _estaEnBiblioteca,
        operationType: OperationType.valoracion,
      ));
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
      emit(LibroDetalleLoaded(
        libro: libro,
        portadaBase64: _portadaBase64,
        estaEnBiblioteca: _estaEnBiblioteca,
        operationType: OperationType.valoracion,
      ));
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
      emit(LibroDetalleLoaded(
        libro: libro,
        portadaBase64: _portadaBase64,
        estaEnBiblioteca: _estaEnBiblioteca,
        operationType: OperationType.resena,
      ));
    } catch (e) {
      emit(LibroDetalleError(e.toString().replaceAll('Exception: ', '')));
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
      emit(LibroDetalleError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void recargar() {
    if (_libroId != null) {
      cargarDetalle(_libroId!);
    }
  }

  Future<void> denunciarResena({
    required int idDenunciante,
    required int idDenunciado,
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
      emit(LibroDetalleError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
