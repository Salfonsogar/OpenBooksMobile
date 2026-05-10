import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/biblioteca/domain/entities/libro_biblioteca_entity.dart';
import 'package:open_books_mobile/features/biblioteca/domain/repositories/i_biblioteca_repository.dart';
import 'package:open_books_mobile/features/biblioteca/domain/usecases/get_biblioteca_usecase.dart';
import 'package:open_books_mobile/shared/core/errors/failures.dart';

class MockIBibliotecaRepository extends Mock implements IBibliotecaRepository {}

void main() {
  late MockIBibliotecaRepository repository;
  late GetBibliotecaUseCase useCase;

  setUp(() {
    repository = MockIBibliotecaRepository();
    useCase = GetBibliotecaUseCase(repository);
  });

  final testBiblioteca = [
    const LibroBibliotecaEntity(
      id: 1,
      libroId: 100,
      usuarioId: 1,
      titulo: 'Test Book',
      autor: 'Author',
      descripcion: 'Desc',
      categorias: ['Ficción'],
    ),
  ];

  group('GetBibliotecaUseCase', () {
    test('syncs from remote then returns local biblioteca when connected', () async {
      when(() => repository.isConnected).thenAnswer((_) async => true);
      when(() => repository.syncFromRemote(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => repository.getBiblioteca(any()))
          .thenAnswer((_) async => Right(testBiblioteca));

      final result = await useCase(1);

      expect(result.isRight(), isTrue);
      verify(() => repository.syncFromRemote(1)).called(1);
      verify(() => repository.getBiblioteca(1)).called(1);
    });

    test('syncs from remote even when sync fails, then returns local biblioteca', () async {
      when(() => repository.isConnected).thenAnswer((_) async => true);
      when(() => repository.syncFromRemote(any()))
          .thenAnswer((_) async => Left(ServerFailure(message: 'Sync error')));
      when(() => repository.getBiblioteca(any()))
          .thenAnswer((_) async => Right(testBiblioteca));

      final result = await useCase(1);

      expect(result.isRight(), isTrue);
      verify(() => repository.syncFromRemote(1)).called(1);
      verify(() => repository.getBiblioteca(1)).called(1);
    });

    test('returns local biblioteca when not connected', () async {
      when(() => repository.isConnected).thenAnswer((_) async => false);
      when(() => repository.getBiblioteca(any()))
          .thenAnswer((_) async => Right(testBiblioteca));

      final result = await useCase(1);

      expect(result.isRight(), isTrue);
      verifyNever(() => repository.syncFromRemote(any()));
      verify(() => repository.getBiblioteca(1)).called(1);
    });
  });
}
