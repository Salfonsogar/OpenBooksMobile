import '../entities/libro_biblioteca_entity.dart';
import '../repositories/i_biblioteca_repository.dart';
import '../../../../shared/services/network_info.dart';

class GetBibliotecaUseCase {
  final IBibliotecaRepository repository;
  final NetworkInfo networkInfo;

  GetBibliotecaUseCase(this.repository, this.networkInfo);

  Future<List<LibroBibliotecaEntity>> call(int usuarioId) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        return await repository.getRemoto(usuarioId);
      } catch (_) {}
    }

    return repository.getBiblioteca(usuarioId);
  }
}