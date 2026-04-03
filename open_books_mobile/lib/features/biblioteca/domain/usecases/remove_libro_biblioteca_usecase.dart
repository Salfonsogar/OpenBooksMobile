import '../repositories/i_biblioteca_repository.dart';

class RemoveLibroBibliotecaUseCase {
  final IBibliotecaRepository repository;

  RemoveLibroBibliotecaUseCase(this.repository);

  Future<void> call(int usuarioId, int libroId) async {
    await repository.removeLibro(usuarioId, libroId);

    final isConnected = await repository.isConnected;
    if (isConnected) {
      await repository.syncNow();
    }
  }
}
