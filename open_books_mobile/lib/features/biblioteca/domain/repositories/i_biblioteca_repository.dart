import 'package:dartz/dartz.dart';

import '../../../../shared/core/errors/failures.dart';
import '../entities/libro_biblioteca_entity.dart';
import 'package:open_books_mobile/features/libros/data/models/libro.dart';

enum SyncStatus { synced, pending, failed }

abstract class IBibliotecaRepository {
  Future<Either<Failure, List<LibroBibliotecaEntity>>> getBiblioteca(String usuarioId);
  Future<Either<Failure, void>> addLibro(String usuarioId, int libroId);
  Future<Either<Failure, void>> addLibroFromRemote(String usuarioId, Libro libro);
  Future<Either<Failure, void>> removeLibro(String usuarioId, int libroId);
  Future<Either<Failure, void>> syncNow();
  Future<Either<Failure, void>> syncFromRemote(String usuarioId);
  Future<bool> get isConnected;
}
