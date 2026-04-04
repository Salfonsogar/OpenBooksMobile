import '../entities/libro_biblioteca_entity.dart';
import '../repositories/i_biblioteca_repository.dart';
import '../../data/repositories/biblioteca_repository_impl.dart';
import '../../../libros/data/repositories/libros_repository.dart';

class GetBibliotecaUseCase {
  final IBibliotecaRepository repository;
  final BibliotecaRepositoryImpl bibliotecaRepository;
  final LibrosRepository librosRepository;

  GetBibliotecaUseCase(
    this.repository,
    this.bibliotecaRepository,
    this.librosRepository,
  );

  Future<List<LibroBibliotecaEntity>> call(int usuarioId) async {
    final isConnected = await repository.isConnected;

    if (isConnected) {
      try {
        await _syncCatalogoFromRemote(usuarioId);
        await repository.syncNow();
      } catch (_) {}
    }

    return repository.getBiblioteca(usuarioId);
  }

  Future<void> _syncCatalogoFromRemote(int usuarioId) async {
    try {
      final result = await librosRepository.getLibros(page: 1, pageSize: 100);
      final libros = result.data;

      for (final libro in libros) {
        try {
          await bibliotecaRepository.addLibroFromRemote(usuarioId, libro);
        } catch (_) {}
      }
    } catch (_) {}
  }
}
