import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/libros/data/models/denuncia_resena.dart';

void main() {
  group('DenunciaResena', () {
    group('fromJson', () {
      test('parses valid JSON with all fields correctly', () {
        final json = {
          'id': 1,
          'idDenunciante': 10,
          'nombreDenunciante': 'Alice',
          'idDenunciado': 20,
          'nombreDenunciado': 'Bob',
          'comentario': 'Contenido inapropiado',
          'idResena': 5,
          'motivo': 'Spam',
        };

        final denuncia = DenunciaResena.fromJson(json);

        expect(denuncia.id, equals(1));
        expect(denuncia.idDenunciante, equals(10));
        expect(denuncia.nombreDenunciante, equals('Alice'));
        expect(denuncia.idDenunciado, equals(20));
        expect(denuncia.nombreDenunciado, equals('Bob'));
        expect(denuncia.comentario, equals('Contenido inapropiado'));
        expect(denuncia.idResena, equals(5));
        expect(denuncia.motivo, equals('Spam'));
      });

      test('handles missing optional fields with defaults', () {
        final json = {'id': 1};

        final denuncia = DenunciaResena.fromJson(json);

        expect(denuncia.id, equals(1));
        expect(denuncia.idDenunciante, equals(0));
        expect(denuncia.nombreDenunciante, equals(''));
        expect(denuncia.idDenunciado, equals(0));
        expect(denuncia.nombreDenunciado, equals(''));
        expect(denuncia.comentario, equals(''));
        expect(denuncia.idResena, isNull);
        expect(denuncia.motivo, isNull);
      });

      test('handles null values with defaults', () {
        final json = {
          'id': 1,
          'idDenunciante': null,
          'nombreDenunciante': null,
          'idDenunciado': null,
          'nombreDenunciado': null,
          'comentario': null,
        };

        final denuncia = DenunciaResena.fromJson(json);

        expect(denuncia.idDenunciante, equals(0));
        expect(denuncia.nombreDenunciante, equals(''));
        expect(denuncia.idDenunciado, equals(0));
        expect(denuncia.nombreDenunciado, equals(''));
        expect(denuncia.comentario, equals(''));
      });
    });

    group('toJson', () {
      test('serializes correctly with all fields', () {
        final denuncia = DenunciaResena(
          id: 1,
          idDenunciante: 10,
          nombreDenunciante: 'Alice',
          idDenunciado: 20,
          nombreDenunciado: 'Bob',
          comentario: 'Contenido inapropiado',
          idResena: 5,
          motivo: 'Spam',
        );

        final json = denuncia.toJson();

        expect(json['id'], equals(1));
        expect(json['idDenunciante'], equals(10));
        expect(json['nombreDenunciante'], equals('Alice'));
        expect(json['idDenunciado'], equals(20));
        expect(json['nombreDenunciado'], equals('Bob'));
        expect(json['comentario'], equals('Contenido inapropiado'));
        expect(json['idResena'], equals(5));
        expect(json['motivo'], equals('Spam'));
      });

      test('serializes without optional fields', () {
        final denuncia = DenunciaResena(
          id: 1,
          idDenunciante: 10,
          nombreDenunciante: 'Alice',
          idDenunciado: 20,
          nombreDenunciado: 'Bob',
          comentario: 'Comentario',
        );

        final json = denuncia.toJson();

        expect(json['idResena'], isNull);
        expect(json['motivo'], isNull);
      });
    });
  });

  group('DenunciaCreate', () {
    group('toJson', () {
      test('serializes correctly', () {
        final denuncia = DenunciaCreate(
          idDenunciante: 10,
          idDenunciado: 20,
          comentario: 'Comentario ofensivo',
          idResena: 5,
          motivo: 'Lenguaje ofensivo o abusivo',
        );

        final json = denuncia.toJson();

        expect(json['idDenunciante'], equals(10));
        expect(json['idDenunciado'], equals(20));
        expect(json['comentario'], equals('Comentario ofensivo'));
        expect(json['idResena'], equals(5));
        expect(
          json['motivo'],
          equals('Lenguaje ofensivo o abusivo'),
        );
      });
    });
  });
}
