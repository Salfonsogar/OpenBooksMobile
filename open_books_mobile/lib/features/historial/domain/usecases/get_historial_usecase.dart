import '../entities/historial_entry_entity.dart';
import '../repositories/i_historial_repository.dart';
import '../../../../shared/services/network_info.dart';

class GetHistorialUseCase {
  final IHistorialRepository repository;
  final NetworkInfo networkInfo;

  GetHistorialUseCase(this.repository, this.networkInfo);

  Future<List<HistorialEntryEntity>> call(int usuarioId) async {
    final localHistorial = await repository.getHistorial(usuarioId);
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteHistorial = await repository.getRemoto(usuarioId);
        if (remoteHistorial.isNotEmpty) {
          return remoteHistorial;
        }
      } catch (_) {}
    }

    return localHistorial;
  }
}