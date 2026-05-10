import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/historial/domain/usecases/get_historial_usecase.dart';
import 'package:open_books_mobile/features/historial/domain/entities/historial_entry_entity.dart';
import 'package:open_books_mobile/features/historial/domain/repositories/i_historial_repository.dart';

class MockHistorialRepository extends Mock implements IHistorialRepository {}

void main() {
  group('GetHistorialUseCase', () {
    late IHistorialRepository repository;
    late GetHistorialUseCase useCase;

    final now = DateTime(2026, 5, 10);
    final entities = [
      HistorialEntryEntity(
        id: 1, libroId: 42, usuarioId: 100, titulo: 'Libro A',
        ultimaLectura: now, createdAt: now,
      ),
    ];

    setUp(() {
      repository = MockHistorialRepository();
      useCase = GetHistorialUseCase(repository);
    });

    test('syncs first and then returns historial entries when connected', () async {
      when(() => repository.isConnected).thenAnswer((_) async => true);
      when(() => repository.syncNow()).thenAnswer((_) async {});
      when(() => repository.getHistorial(100)).thenAnswer((_) async => entities);

      final result = await useCase(100);

      expect(result, entities);
      verify(() => repository.isConnected).called(1);
      verify(() => repository.syncNow()).called(1);
      verify(() => repository.getHistorial(100)).called(1);
    });

    test('does not sync when not connected', () async {
      when(() => repository.isConnected).thenAnswer((_) async => false);
      when(() => repository.getHistorial(100)).thenAnswer((_) async => entities);

      final result = await useCase(100);

      expect(result, entities);
      verify(() => repository.isConnected).called(1);
      verifyNever(() => repository.syncNow());
      verify(() => repository.getHistorial(100)).called(1);
    });

    test('sync failure does not prevent returning historial', () async {
      when(() => repository.isConnected).thenAnswer((_) async => true);
      when(() => repository.syncNow()).thenThrow(Exception('Sync error'));
      when(() => repository.getHistorial(100)).thenAnswer((_) async => entities);

      final result = await useCase(100);

      expect(result, entities);
      verify(() => repository.isConnected).called(1);
      verify(() => repository.syncNow()).called(1);
      verify(() => repository.getHistorial(100)).called(1);
    });

    test('returns empty list when no historial entries exist', () async {
      when(() => repository.isConnected).thenAnswer((_) async => false);
      when(() => repository.getHistorial(100)).thenAnswer((_) async => []);

      final result = await useCase(100);

      expect(result, isEmpty);
    });
  });
}
