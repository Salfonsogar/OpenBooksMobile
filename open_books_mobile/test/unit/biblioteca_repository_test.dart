import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/biblioteca/domain/repositories/i_biblioteca_repository.dart';
import 'package:open_books_mobile/shared/core/errors/failures.dart';

class MockBibliotecaRepository extends Mock implements IBibliotecaRepository {}

void main() {
  group('BibliotecaRepository Either<Failure, T> pattern', () {
    late MockBibliotecaRepository repository;

    setUp(() {
      repository = MockBibliotecaRepository();
    });

    test('getBiblioteca returns Right with data on success', () async {
      when(() => repository.getBiblioteca(any()))
          .thenAnswer((_) async => const Right([]));

      final result = await repository.getBiblioteca(1);

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not be left'),
        (data) => expect(data, isA<List>()),
      );
    });

    test('getBiblioteca returns Left with Failure on error', () async {
      when(() => repository.getBiblioteca(any()))
          .thenAnswer((_) async => Left(CacheFailure(message: 'Error')));

      final result = await repository.getBiblioteca(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should not be right'),
      );
    });
  });
}
