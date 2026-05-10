import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/historial/domain/entities/historial_entry_entity.dart';

void main() {
  group('HistorialEntryEntity', () {
    final now = DateTime(2026, 5, 10, 12, 0, 0);
    final entity = HistorialEntryEntity(
      id: 1,
      libroId: 42,
      usuarioId: 100,
      titulo: 'Test Libro',
      autor: 'Test Author',
      portadaBase64: 'base64data',
      ultimaLectura: now,
      status: 'synced',
      createdAt: now,
      progreso: 0.75,
      page: 150,
    );

    test('constructor creates instance with all fields', () {
      expect(entity.id, 1);
      expect(entity.libroId, 42);
      expect(entity.usuarioId, 100);
      expect(entity.titulo, 'Test Libro');
      expect(entity.autor, 'Test Author');
      expect(entity.portadaBase64, 'base64data');
      expect(entity.ultimaLectura, now);
      expect(entity.status, 'synced');
      expect(entity.createdAt, now);
      expect(entity.progreso, 0.75);
      expect(entity.page, 150);
    });

    test('constructor uses default values for optional fields', () {
      final defaultEntity = HistorialEntryEntity(
        id: 1,
        libroId: 42,
        usuarioId: 100,
        titulo: 'Test',
        ultimaLectura: now,
        createdAt: now,
      );

      expect(defaultEntity.autor, isNull);
      expect(defaultEntity.portadaBase64, isNull);
      expect(defaultEntity.status, 'synced');
      expect(defaultEntity.progreso, 0.0);
      expect(defaultEntity.page, isNull);
    });

    test('copyWith creates new instance with changed values', () {
      final copied = entity.copyWith(titulo: 'Updated Title', progreso: 1.0);

      expect(copied.id, 1);
      expect(copied.titulo, 'Updated Title');
      expect(copied.progreso, 1.0);
      expect(copied.autor, entity.autor);
    });

    test('copyWith with no arguments returns equal instance', () {
      final copied = entity.copyWith();

      expect(copied, equals(entity));
      expect(copied.hashCode, equals(entity.hashCode));
    });

    test('copyWith preserves id when id is null (null is default)', () {
      final copied = entity.copyWith(id: null);

      expect(copied.id, 1);
    });

    test('Equatable value equality', () {
      final a = HistorialEntryEntity(
        id: 1, libroId: 42, usuarioId: 100, titulo: 'Test',
        autor: 'Author', portadaBase64: 'img', ultimaLectura: now,
        status: 'synced', createdAt: now, progreso: 0.5, page: 10,
      );
      final b = HistorialEntryEntity(
        id: 1, libroId: 42, usuarioId: 100, titulo: 'Test',
        autor: 'Author', portadaBase64: 'img', ultimaLectura: now,
        status: 'synced', createdAt: now, progreso: 0.5, page: 10,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('Equatable inequality when fields differ', () {
      final a = HistorialEntryEntity(
        id: 1, libroId: 42, usuarioId: 100, titulo: 'Test',
        ultimaLectura: now, createdAt: now,
      );
      final b = HistorialEntryEntity(
        id: 2, libroId: 42, usuarioId: 100, titulo: 'Test',
        ultimaLectura: now, createdAt: now,
      );

      expect(a, isNot(equals(b)));
    });

    test('props returns correct list', () {
      expect(entity.props, [
        1, 42, 100, 'Test Libro', 'Test Author', 'base64data',
        now, 'synced', now, 0.75, 150,
      ]);
    });
  });
}
