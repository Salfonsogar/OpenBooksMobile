import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/biblioteca/domain/repositories/i_biblioteca_repository.dart';
import 'package:open_books_mobile/features/biblioteca/domain/usecases/remove_libro_biblioteca_usecase.dart';
import 'package:open_books_mobile/shared/core/errors/failures.dart';

class MockIBibliotecaRepository extends Mock implements IBibliotecaRepository {}

void main() {
  late MockIBibliotecaRepository repository;
  late RemoveLibroBibliotecaUseCase useCase;

  setUp(() {
    repository = MockIBibliotecaRepository();
    useCase = RemoveLibroBibliotecaUseCase(repository);
  });

  group('RemoveLibroBibliotecaUseCase', () {
    test('removes libro and syncs when connected', () async {
      when(() => repository.removeLibro(any(), any()))
          .thenAnswer((_) async => const Right(null));
      when(() => repository.isConnected).thenAnswer((_) async => true);
      when(() => repository.syncNow())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(1, 100);

      expect(result.isRight(), isTrue);
      verify(() => repository.removeLibro(1, 100)).called(1);
      verify(() => repository.syncNow()).called(1);
    });

    test('removes libro without sync when not connected', () async {
      when(() => repository.removeLibro(any(), any()))
          .thenAnswer((_) async => const Right(null));
      when(() => repository.isConnected).thenAnswer((_) async => false);

      final result = await useCase(1, 100);

      expect(result.isRight(), isTrue);
      verify(() => repository.removeLibro(1, 100)).called(1);
      verifyNever(() => repository.syncNow());
    });

    test('returns Left when repository fails', () async {
      when(() => repository.removeLibro(any(), any()))
          .thenAnswer((_) async => Left(CacheFailure(message: 'Error al eliminar')));

      final result = await useCase(1, 100);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'Error al eliminar'),
        (_) => fail('Should be Left'),
      );
      verifyNever(() => repository.syncNow());
    });
  });
}
