import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/historial/domain/usecases/get_historial_usecase.dart';
import 'package:open_books_mobile/features/historial/domain/entities/historial_entry_entity.dart';
import 'package:open_books_mobile/features/historial/domain/repositories/i_historial_repository.dart';

class MockHistorialRepository extends Mock implements IHistorialRepository {}

void main() {
  const testUserId = '550e8400-e29b-41d4-a716-446655440000';

  group('GetHistorialUseCase', () {
    late IHistorialRepository repository;
    late GetHistorialUseCase useCase;

    final now = DateTime(2026, 5, 10);
    final entities = [
      HistorialEntryEntity(
        id: 1, libroId: 42, usuarioId: testUserId, titulo: 'Libro A',
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
      when(() => repository.getHistorial(any())).thenAnswer((_) async => entities);

      final result = await useCase(testUserId);

      expect(result, entities);
      verify(() => repository.isConnected).called(1);
      verify(() => repository.syncNow()).called(1);
      verify(() => repository.getHistorial(testUserId)).called(1);
    });

    test('does not sync when not connected', () async {
      when(() => repository.isConnected).thenAnswer((_) async => false);
      when(() => repository.getHistorial(any())).thenAnswer((_) async => entities);

      final result = await useCase(testUserId);

      expect(result, entities);
      verify(() => repository.isConnected).called(1);
      verifyNever(() => repository.syncNow());
      verify(() => repository.getHistorial(testUserId)).called(1);
    });

    test('sync failure does not prevent returning historial', () async {
      when(() => repository.isConnected).thenAnswer((_) async => true);
      when(() => repository.syncNow()).thenThrow(Exception('Sync error'));
      when(() => repository.getHistorial(any())).thenAnswer((_) async => entities);

      final result = await useCase(testUserId);

      expect(result, entities);
      verify(() => repository.isConnected).called(1);
      verify(() => repository.syncNow()).called(1);
      verify(() => repository.getHistorial(testUserId)).called(1);
    });

    test('returns empty list when no historial entries exist', () async {
      when(() => repository.isConnected).thenAnswer((_) async => false);
      when(() => repository.getHistorial(any())).thenAnswer((_) async => []);

      final result = await useCase(testUserId);

      expect(result, isEmpty);
    });
  });
}