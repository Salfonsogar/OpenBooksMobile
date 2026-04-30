import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../entities/libro_biblioteca_entity.dart';
import '../repositories/i_biblioteca_repository.dart';
import '../../../../shared/core/utils/either.dart';

class GetBibliotecaUseCase {
  final IBibliotecaRepository repository;

  GetBibliotecaUseCase(this.repository);

  Future<Result<List<LibroBibliotecaEntity>>> call(int usuarioId) async {
    final isConnected = await repository.isConnected;

    if (isConnected) {
      final syncResult = await repository.syncFromRemote(usuarioId);
      if (syncResult.isLeft()) {
        // Log error but continue with local data
        debugPrint('Sync warning: ${(syncResult as Left).value.message}');
      }
    }

    return repository.getBiblioteca(usuarioId);
  }
}
