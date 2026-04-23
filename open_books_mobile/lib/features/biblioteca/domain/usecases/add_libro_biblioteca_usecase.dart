import '../entities/libro_biblioteca_entity.dart';
import '../repositories/i_biblioteca_repository.dart';

class AddLibroBibliotecaUseCase {
  final IBibliotecaRepository repository;

  AddLibroBibliotecaUseCase(this.repository);

  Future<LibroBibliotecaEntity> call(int usuarioId, int libroId) async {
    return repository.addLibro(usuarioId, libroId);
  }
}