import '../../../libros/data/models/libro.dart';
import '../repositories/i_historial_repository.dart';

class AddToHistorialUseCase {
  final IHistorialRepository repository;

  AddToHistorialUseCase(this.repository);

  Future<void> call(int usuarioId, Libro libro) async {
    await repository.addToHistorial(usuarioId, libro);

    final isConnected = await repository.isConnected;
    if (isConnected) {
      await repository.syncNow();
    }
  }
}
