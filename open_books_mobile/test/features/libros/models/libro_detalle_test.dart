import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/libros/data/models/libro_detalle.dart';
import 'package:open_books_mobile/features/libros/data/models/resena.dart';

void main() {
  group('LibroDetalle', () {
    final resenaJson = {
      'id': 1,
      'usuarioId': 42,
      'nombreUsuario': 'Juan',
      'texto': 'Buen libro',
      'fecha': '2024-01-15T10:30:00.000',
    };
    final resena = Resena(
      id: 1,
      usuarioId: 42,
      nombreUsuario: 'Juan',
      texto: 'Buen libro',
      fecha: DateTime.parse('2024-01-15T10:30:00.000'),
    );

    group('fromJson', () {
      test('parses valid JSON with all fields correctly', () {
        final json = {
          'id': 1,
          'titulo': 'Cien Años de Soledad',
          'autor': 'Gabriel García Márquez',
          'descripcion': 'Una obra maestra del realismo mágico',
          'promedioValoraciones': 4.5,
          'cantidadValoraciones': 100,
          'resenas': [resenaJson],
          'totalResenas': 1,
          'imagen': 'base64portada',
          'categorias': ['Realismo Mágico', 'Clásico'],
          'numeroPaginas': 432,
        };

        final detalle = LibroDetalle.fromJson(json);

        expect(detalle.id, equals(1));
        expect(detalle.titulo, equals('Cien Años de Soledad'));
        expect(
          detalle.autor,
          equals('Gabriel García Márquez'),
        );
        expect(
          detalle.descripcion,
          equals('Una obra maestra del realismo mágico'),
        );
        expect(detalle.promedioValoraciones, equals(4.5));
        expect(detalle.cantidadValoraciones, equals(100));
        expect(detalle.resenas.length, equals(1));
        expect(detalle.resenas.first.id, equals(1));
        expect(detalle.totalResenas, equals(1));
        expect(detalle.portadaBase64, equals('base64portada'));
        expect(detalle.categorias, equals(['Realismo Mágico', 'Clásico']));
        expect(detalle.numeroPaginas, equals(432));
      });

      test('handles missing optional fields with defaults', () {
        final json = {'id': 1};

        final detalle = LibroDetalle.fromJson(json);

        expect(detalle.id, equals(1));
        expect(detalle.titulo, equals(''));
        expect(detalle.autor, equals(''));
        expect(detalle.descripcion, equals(''));
        expect(detalle.promedioValoraciones, equals(0.0));
        expect(detalle.cantidadValoraciones, equals(0));
        expect(detalle.resenas, isEmpty);
        expect(detalle.totalResenas, equals(0));
        expect(detalle.portadaBase64, isNull);
        expect(detalle.categorias, isEmpty);
        expect(detalle.numeroPaginas, isNull);
      });

      test('handles null values with defaults', () {
        final json = {
          'id': 1,
          'titulo': null,
          'autor': null,
          'descripcion': null,
          'promedioValoraciones': null,
          'cantidadValoraciones': null,
          'resenas': null,
          'totalResenas': null,
          'categorias': null,
          'numeroPaginas': null,
        };

        final detalle = LibroDetalle.fromJson(json);

        expect(detalle.titulo, equals(''));
        expect(detalle.autor, equals(''));
        expect(detalle.descripcion, equals(''));
        expect(detalle.promedioValoraciones, equals(0.0));
        expect(detalle.cantidadValoraciones, equals(0));
        expect(detalle.resenas, isEmpty);
        expect(detalle.totalResenas, equals(0));
        expect(detalle.categorias, isEmpty);
        expect(detalle.numeroPaginas, isNull);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        final detalle = LibroDetalle(
          id: 1,
          titulo: 'Cien Años de Soledad',
          autor: 'Gabriel García Márquez',
          descripcion: 'Una obra maestra',
          promedioValoraciones: 4.5,
          cantidadValoraciones: 100,
          resenas: [resena],
          totalResenas: 1,
          portadaBase64: 'base64portada',
          categorias: ['Realismo Mágico'],
          numeroPaginas: 432,
        );

        final json = detalle.toJson();

        expect(json['id'], equals(1));
        expect(json['titulo'], equals('Cien Años de Soledad'));
        expect(json['autor'], equals('Gabriel García Márquez'));
        expect(json['descripcion'], equals('Una obra maestra'));
        expect(json['promedioValoraciones'], equals(4.5));
        expect(json['cantidadValoraciones'], equals(100));
        expect(json['resenas'], isA<List>());
        expect(json['resenas'].length, equals(1));
        expect(json['totalResenas'], equals(1));
        expect(json['imagen'], equals('base64portada'));
        expect(json['categorias'], equals(['Realismo Mágico']));
        expect(json['numeroPaginas'], equals(432));
      });

      test('serializes without optional fields', () {
        final detalle = LibroDetalle(
          id: 1,
          titulo: 'Test',
          autor: 'Author',
          descripcion: 'Desc',
          promedioValoraciones: 0.0,
          cantidadValoraciones: 0,
          resenas: [],
          totalResenas: 0,
          categorias: [],
        );

        final json = detalle.toJson();

        expect(json['imagen'], isNull);
        expect(json['numeroPaginas'], isNull);
        expect(json['categorias'], isEmpty);
      });
    });

    group('copyWith', () {
      test('creates new instance with same values when no arguments', () {
        final detalle = LibroDetalle(
          id: 1,
          titulo: 'Test',
          autor: 'Author',
          descripcion: 'Desc',
          promedioValoraciones: 3.0,
          cantidadValoraciones: 10,
          resenas: [],
          totalResenas: 0,
          categorias: [],
        );

        final copy = detalle.copyWith();

        expect(copy.id, equals(1));
        expect(copy.titulo, equals('Test'));
        expect(copy.autor, equals('Author'));
      });

      test('updates specified fields', () {
        final detalle = LibroDetalle(
          id: 1,
          titulo: 'Original',
          autor: 'Author',
          descripcion: 'Desc',
          promedioValoraciones: 3.0,
          cantidadValoraciones: 10,
          resenas: [resena],
          totalResenas: 1,
          categorias: ['Ficción'],
        );

        final copy = detalle.copyWith(
          titulo: 'Updated',
          numeroPaginas: 200,
        );

        expect(copy.titulo, equals('Updated'));
        expect(copy.numeroPaginas, equals(200));
        expect(copy.autor, equals('Author'));
        expect(copy.categorias, equals(['Ficción']));
        expect(copy.resenas.length, equals(1));
      });

      test('updates resenas list', () {
        final detalle = LibroDetalle(
          id: 1,
          titulo: 'Test',
          autor: 'Author',
          descripcion: 'Desc',
          promedioValoraciones: 3.0,
          cantidadValoraciones: 10,
          resenas: [],
          totalResenas: 0,
          categorias: [],
        );

        final copy = detalle.copyWith(
          resenas: [resena],
          totalResenas: 1,
        );

        expect(copy.resenas.length, equals(1));
        expect(copy.totalResenas, equals(1));
        expect(copy.resenas.first.id, equals(1));
      });
    });
  });
}
