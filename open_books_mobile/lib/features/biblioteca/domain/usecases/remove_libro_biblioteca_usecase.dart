import 'package:dartz/dartz.dart';

import '../repositories/i_biblioteca_repository.dart';
import '../../../../shared/core/utils/either.dart';

class RemoveLibroBibliotecaUseCase {
  final IBibliotecaRepository repository;

  RemoveLibroBibliotecaUseCase(this.repository);

  Future<Result<void>> call(int usuarioId, int libroId) async {
    final result = await repository.removeLibro(usuarioId, libroId);
    if (result.isLeft()) {
      return result;
    }

    final isConnected = await repository.isConnected;
    if (isConnected) {
      return repository.syncNow();
    }

    return const Right(null);
  }
}
