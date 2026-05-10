import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/historial/data/mappers/historial_mapper.dart';
import 'package:open_books_mobile/features/historial/domain/entities/historial_entry_entity.dart';
import 'package:open_books_mobile/shared/services/models/historial_local_model.dart';
import 'package:open_books_mobile/features/libros/data/models/libro.dart';

void main() {
  group('HistorialMapper', () {
    final now = DateTime(2026, 5, 10, 12, 0, 0);
    final epoch = now.millisecondsSinceEpoch;

    group('fromLocalModelList', () {
      test('maps list of local models to entities', () {
        final models = [
          HistorialLocalModel(
            id: 1, libroId: 42, usuarioId: 100, titulo: 'Libro A',
            autor: 'Author', portadaBase64: 'img',
            ultimaLectura: epoch, status: 'synced', createdAt: epoch,
          ),
          HistorialLocalModel(
            id: 2, libroId: 43, usuarioId: 100, titulo: 'Libro B',
            ultimaLectura: epoch, createdAt: epoch,
          ),
        ];

        final entities = HistorialMapper.fromLocalModelList(models);

        expect(entities.length, 2);
        expect(entities[0].titulo, 'Libro A');
        expect(entities[1].titulo, 'Libro B');
      });

      test('returns empty list when input is empty', () {
        final entities = HistorialMapper.fromLocalModelList([]);

        expect(entities, isEmpty);
      });
    });

    group('fromLocalModel', () {
      test('maps all fields correctly', () {
        final model = HistorialLocalModel(
          id: 1, libroId: 42, usuarioId: 100, titulo: 'Test Libro',
          autor: 'Test Author', portadaBase64: 'base64img',
          ultimaLectura: epoch, status: 'synced', createdAt: epoch,
        );

        final entity = HistorialMapper.fromLocalModel(model);

        expect(entity.id, 1);
        expect(entity.libroId, 42);
        expect(entity.usuarioId, 100);
        expect(entity.titulo, 'Test Libro');
        expect(entity.autor, 'Test Author');
        expect(entity.portadaBase64, 'base64img');
        expect(entity.ultimaLectura, now);
        expect(entity.status, 'synced');
        expect(entity.createdAt, now);
        expect(entity.progreso, 0.0);
        expect(entity.page, isNull);
      });

      test('uses 0 for id when model.id is null', () {
        final model = HistorialLocalModel(
          libroId: 42, usuarioId: 100, titulo: 'Test',
          ultimaLectura: epoch, createdAt: epoch,
        );

        final entity = HistorialMapper.fromLocalModel(model);

        expect(entity.id, 0);
      });

      test('handles null author and portada', () {
        final model = HistorialLocalModel(
          id: 1, libroId: 42, usuarioId: 100, titulo: 'Test',
          ultimaLectura: epoch, createdAt: epoch,
        );

        final entity = HistorialMapper.fromLocalModel(model);

        expect(entity.autor, isNull);
        expect(entity.portadaBase64, isNull);
      });
    });

    group('toLocalModel', () {
      test('maps entity to local model correctly', () {
        final entity = HistorialEntryEntity(
          id: 1, libroId: 42, usuarioId: 100, titulo: 'Test Libro',
          autor: 'Author', portadaBase64: 'img',
          ultimaLectura: now, status: 'synced', createdAt: now,
          progreso: 0.5, page: 100,
        );

        final model = HistorialMapper.toLocalModel(entity);

        expect(model.id, 1);
        expect(model.libroId, 42);
        expect(model.usuarioId, 100);
        expect(model.titulo, 'Test Libro');
        expect(model.autor, 'Author');
        expect(model.portadaBase64, 'img');
        expect(model.ultimaLectura, epoch);
        expect(model.status, 'synced');
        expect(model.createdAt, epoch);
      });

      test('sets id to null when entity.id is 0', () {
        final entity = HistorialEntryEntity(
          id: 0, libroId: 42, usuarioId: 100, titulo: 'Test',
          ultimaLectura: now, createdAt: now,
        );

        final model = HistorialMapper.toLocalModel(entity);

        expect(model.id, isNull);
      });

      test('handles entity with null autor and portada', () {
        final entity = HistorialEntryEntity(
          id: 1, libroId: 42, usuarioId: 100, titulo: 'Test',
          ultimaLectura: now, createdAt: now,
        );

        final model = HistorialMapper.toLocalModel(entity);

        expect(model.autor, isNull);
        expect(model.portadaBase64, isNull);
      });
    });

    group('fromLibroToLocalModel', () {
      test('creates local model from Libro with pending_add status', () {
        final libro = Libro(
          id: 42, titulo: 'Test Book', autor: 'Test Author',
          descripcion: 'Description', portadaBase64: 'img', categorias: ['cat1'],
        );

        final model = HistorialMapper.fromLibroToLocalModel(libro, 100);

        expect(model.id, isNull);
        expect(model.libroId, 42);
        expect(model.usuarioId, 100);
        expect(model.titulo, 'Test Book');
        expect(model.autor, 'Test Author');
        expect(model.portadaBase64, 'img');
        expect(model.status, 'pending_add');
        expect(model.ultimaLectura, greaterThan(0));
        expect(model.createdAt, greaterThan(0));
      });

      test('uses current timestamp for ultimaLectura and createdAt', () {
        final libro = Libro(
          id: 1, titulo: 'Book', autor: 'Author',
          descripcion: 'Desc', categorias: [],
        );

        final model = HistorialMapper.fromLibroToLocalModel(libro, 100);

        expect(model.ultimaLectura, closeTo(
          DateTime.now().millisecondsSinceEpoch, 1000,
        ));
        expect(model.createdAt, closeTo(
          DateTime.now().millisecondsSinceEpoch, 1000,
        ));
      });
    });

    group('fromApiModelList / fromApiModel', () {
      test('maps list of Libro to entities', () {
        final libros = [
          Libro(id: 1, titulo: 'Book A', autor: 'Author A',
                descripcion: 'Desc', categorias: []),
          Libro(id: 2, titulo: 'Book B', autor: 'Author B',
                descripcion: 'Desc', categorias: []),
        ];

        final entities = HistorialMapper.fromApiModelList(libros);

        expect(entities.length, 2);
        expect(entities[0].titulo, 'Book A');
        expect(entities[1].titulo, 'Book B');
      });

      test('fromApiModel sets default values', () {
        final libro = Libro(
          id: 42, titulo: 'API Book', autor: 'API Author',
          descripcion: 'Desc', portadaBase64: 'apiimg', categorias: ['cat'],
        );

        final entity = HistorialMapper.fromApiModel(libro);

        expect(entity.id, 0);
        expect(entity.libroId, 42);
        expect(entity.usuarioId, 0);
        expect(entity.titulo, 'API Book');
        expect(entity.autor, 'API Author');
        expect(entity.portadaBase64, 'apiimg');
        expect(entity.status, 'synced');
      });
    });
  });
}
