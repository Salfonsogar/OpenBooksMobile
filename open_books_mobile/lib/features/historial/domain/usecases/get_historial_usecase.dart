import '../entities/historial_entry_entity.dart';
import '../repositories/i_historial_repository.dart';

class GetHistorialUseCase {
  final IHistorialRepository repository;

  GetHistorialUseCase(this.repository);

  Future<List<HistorialEntryEntity>> call(int usuarioId) async {
    final isConnected = await repository.isConnected;

    if (isConnected) {
      try {
        await repository.syncNow();
      } catch (_) {}
    }

    return repository.getHistorial(usuarioId);
  }
}
