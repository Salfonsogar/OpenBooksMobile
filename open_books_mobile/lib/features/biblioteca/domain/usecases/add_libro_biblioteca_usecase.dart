import '../repositories/i_biblioteca_repository.dart';

class AddLibroBibliotecaUseCase {
  final IBibliotecaRepository repository;

  AddLibroBibliotecaUseCase(this.repository);

  Future<void> call(int usuarioId, int libroId) async {
    await repository.addLibro(usuarioId, libroId);

    final isConnected = await repository.isConnected;
    if (isConnected) {
      await repository.syncNow();
    }
  }
}
