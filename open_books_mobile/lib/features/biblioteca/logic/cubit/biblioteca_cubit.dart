import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../../../shared/core/enums/download_status.dart';
import '../../../../shared/services/epub_local_storage_service.dart';
import '../../data/models/libro_biblioteca.dart';
import '../../domain/usecases/get_biblioteca_usecase.dart';
import '../../domain/usecases/add_libro_biblioteca_usecase.dart';
import '../../domain/usecases/remove_libro_biblioteca_usecase.dart';

abstract class BibliotecaState extends Equatable {
  const BibliotecaState();

  @override
  List<Object?> get props => [];
}

class BibliotecaInitial extends BibliotecaState {}

class BibliotecaLoading extends BibliotecaState {}

class BibliotecaLoaded extends BibliotecaState {
  final List<LibroBiblioteca> libros;
  final Map<int, bool> downloadedStatus;
  final Map<int, DownloadStatus> downloadStatuses;

  const BibliotecaLoaded({
    required this.libros,
    this.downloadedStatus = const {},
    this.downloadStatuses = const {},
  });

  @override
  List<Object> get props => [libros, downloadedStatus, downloadStatuses];

  BibliotecaLoaded copyWith({
    List<LibroBiblioteca>? libros,
    Map<int, bool>? downloadedStatus,
    Map<int, DownloadStatus>? downloadStatuses,
  }) {
    return BibliotecaLoaded(
      libros: libros ?? this.libros,
      downloadedStatus: downloadedStatus ?? this.downloadedStatus,
      downloadStatuses: downloadStatuses ?? this.downloadStatuses,
    );
  }

  bool tieneLibro(int libroId) {
    return libros.any((l) => l.id == libroId);
  }

  bool isDownloaded(int libroId) {
    return downloadedStatus[libroId] ?? false;
  }

  DownloadStatus getDownloadStatus(int libroId) {
    return downloadStatuses[libroId] ?? DownloadStatus.notDownloaded;
  }
}

class BibliotecaError extends BibliotecaState {
  final String message;

  const BibliotecaError(this.message);

  @override
  List<Object> get props => [message];
}

class BibliotecaCubit extends Cubit<BibliotecaState> {
  final GetBibliotecaUseCase getBibliotecaUseCase;
  final AddLibroBibliotecaUseCase addLibroBibliotecaUseCase;
  final RemoveLibroBibliotecaUseCase removeLibroBibliotecaUseCase;
  final EpubLocalStorageService epubLocalStorageService;
  final SessionCubit _sessionCubit;
  bool _isLoading = false;

  BibliotecaCubit({
    required this.getBibliotecaUseCase,
    required this.addLibroBibliotecaUseCase,
    required this.removeLibroBibliotecaUseCase,
    required this.epubLocalStorageService,
    required SessionCubit sessionCubit,
  })  : _sessionCubit = sessionCubit,
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
      final entities = await getBibliotecaUseCase(sessionState.userId);
      final libros = entities
          .map((e) => LibroBiblioteca(
                id: e.libroId,
                titulo: e.titulo,
                autor: e.autor,
                descripcion: e.descripcion,
                portadaBase64: e.portadaBase64,
                categorias: e.categorias,
                progreso: e.progreso,
                page: e.page,
                syncStatus: e.syncStatus,
                lastReadAt: e.lastReadAt?.millisecondsSinceEpoch,
                readingStreak: e.readingStreak,
              ))
          .toList();

      final downloadedIds = await epubLocalStorageService.getAllDownloadedIds();
      final downloadedStatus = <int, bool>{};
      for (final libro in libros) {
        downloadedStatus[libro.id] = downloadedIds.contains(libro.id);
      }

      emit(BibliotecaLoaded(libros: libros, downloadedStatus: downloadedStatus));
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
      await addLibroBibliotecaUseCase(sessionState.userId, libroId);
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
      await epubLocalStorageService.deleteEpub(libroId);
      await removeLibroBibliotecaUseCase(sessionState.userId, libroId);
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

  bool isDownloaded(int libroId) {
    final currentState = state;
    if (currentState is BibliotecaLoaded) {
      return currentState.isDownloaded(libroId);
    }
    return false;
  }

  Future<void> refresh() async {
    await cargarBiblioteca();
  }

  Future<void> descargarLibro(int libroId) async {
    await epubLocalStorageService.queueDownload(libroId);
    await cargarBiblioteca();
  }

  Future<void> eliminarDescarga(int libroId) async {
    await epubLocalStorageService.deleteEpub(libroId);
    await cargarBiblioteca();
  }
}
