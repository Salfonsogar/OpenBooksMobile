import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/historial/domain/usecases/add_to_historial_usecase.dart';
import 'package:open_books_mobile/features/historial/domain/repositories/i_historial_repository.dart';
import 'package:open_books_mobile/features/libros/data/models/libro.dart';

class MockHistorialRepository extends Mock implements IHistorialRepository {}

void main() {
  group('AddToHistorialUseCase', () {
    late IHistorialRepository repository;
    late AddToHistorialUseCase useCase;

    final libro = Libro(
      id: 42, titulo: 'Test Book', autor: 'Test Author',
      descripcion: 'Description', categorias: ['fiction'],
    );

    setUp(() {
      repository = MockHistorialRepository();
      useCase = AddToHistorialUseCase(repository);
    });

    test('calls repository.addToHistorial and syncs when connected', () async {
      when(() => repository.addToHistorial(100, libro)).thenAnswer((_) async {});
      when(() => repository.isConnected).thenAnswer((_) async => true);
      when(() => repository.syncNow()).thenAnswer((_) async {});

      await useCase(100, libro);

      verify(() => repository.addToHistorial(100, libro)).called(1);
      verify(() => repository.isConnected).called(1);
      verify(() => repository.syncNow()).called(1);
    });

    test('calls addToHistorial but does not sync when not connected', () async {
      when(() => repository.addToHistorial(100, libro)).thenAnswer((_) async {});
      when(() => repository.isConnected).thenAnswer((_) async => false);

      await useCase(100, libro);

      verify(() => repository.addToHistorial(100, libro)).called(1);
      verify(() => repository.isConnected).called(1);
      verifyNever(() => repository.syncNow());
    });

    test('does not throw when addToHistorial fails', () async {
      when(() => repository.addToHistorial(100, libro))
          .thenThrow(Exception('DB error'));
      when(() => repository.isConnected).thenAnswer((_) async => false);

      expect(() => useCase(100, libro), throwsA(isA<Exception>()));
    });
  });
}
