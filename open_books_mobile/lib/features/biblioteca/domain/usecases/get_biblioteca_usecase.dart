import '../entities/libro_biblioteca_entity.dart';
import '../repositories/i_biblioteca_repository.dart';

class GetBibliotecaUseCase {
  final IBibliotecaRepository repository;

  GetBibliotecaUseCase(this.repository);

  Future<List<LibroBibliotecaEntity>> call(int usuarioId) async {
    final isConnected = await repository.isConnected;

    if (isConnected) {
      try {
        // Sincroniza desde el endpoint de biblioteca del usuario, no el catálogo
        await repository.syncFromRemote(usuarioId);
      } catch (_) {}
    }

    return repository.getBiblioteca(usuarioId);
  }
}
