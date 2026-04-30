import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../../../shared/services/local_database.dart';
import '../../../libros/data/models/libro.dart';
import '../../domain/entities/historial_entry_entity.dart';
import '../../domain/usecases/get_historial_usecase.dart';
import '../../domain/usecases/add_to_historial_usecase.dart';

abstract class HistorialState extends Equatable {
  const HistorialState();

  @override
  List<Object?> get props => [];
}

class HistorialInitial extends HistorialState {}

class HistorialLoading extends HistorialState {}

class HistorialLoaded extends HistorialState {
  final List<HistorialEntryEntity> libros;

  const HistorialLoaded({required this.libros});

  @override
  List<Object> get props => [libros];
}

class HistorialError extends HistorialState {
  final String message;

  const HistorialError(this.message);

  @override
  List<Object> get props => [message];
}

class HistorialCubit extends Cubit<HistorialState> {
  final GetHistorialUseCase getHistorialUseCase;
  final AddToHistorialUseCase addToHistorialUseCase;
  final SessionCubit sessionCubit;
  final LocalDatabase localDatabase;

  HistorialCubit({
    required this.getHistorialUseCase,
    required this.addToHistorialUseCase,
    required this.sessionCubit,
    required this.localDatabase,
  }) : super(HistorialInitial());

  Future<void> cargarHistorial({int cantidad = 10}) async {
    final sessionState = sessionCubit.state;
    if (sessionState is! SessionAuthenticated) {
      emit(const HistorialLoaded(libros: []));
      return;
    }

    emit(HistorialLoading());
    try {
      final entities = await getHistorialUseCase(sessionState.userId);
      
      final librosConProgreso = <HistorialEntryEntity>[];
      for (final entity in entities) {
        final libroLocal = await localDatabase.bibliotecaLocalDataSource.getByLibroId(
          entity.libroId, 
          sessionState.userId,
        );
        
        librosConProgreso.add(entity.copyWith(
          progreso: libroLocal?.progreso ?? 0.0,
          page: libroLocal?.page,
        ));
      }
      
      librosConProgreso.sort((a, b) => b.ultimaLectura.compareTo(a.ultimaLectura));
      
      emit(HistorialLoaded(libros: librosConProgreso));
    } catch (e) {
      emit(HistorialError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addToHistorial(Libro libro) async {
    final sessionState = sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    try {
      await addToHistorialUseCase(sessionState.userId, libro);
    } catch (_) {
      // Fire-and-forget: el sync puede fallar silenciosamente
    }
  }

  Future<void> refresh() async {
    await cargarHistorial();
  }
}
