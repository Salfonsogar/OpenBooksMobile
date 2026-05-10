import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/libros/data/models/resena.dart';

void main() {
  group('Resena', () {
    group('fromJson', () {
      test('parses valid JSON with all fields correctly', () {
        final json = {
          'id': 1,
          'usuarioId': 42,
          'nombreUsuario': 'Juan Pérez',
          'fotoPerfil': 'base64avatar',
          'texto': 'Excelente libro, muy recomendado',
          'fecha': '2024-01-15T10:30:00.000',
        };

        final resena = Resena.fromJson(json);

        expect(resena.id, equals(1));
        expect(resena.usuarioId, equals(42));
        expect(resena.nombreUsuario, equals('Juan Pérez'));
        expect(resena.fotoPerfilBase64, equals('base64avatar'));
        expect(resena.texto, equals('Excelente libro, muy recomendado'));
        expect(
          resena.fecha,
          equals(DateTime.parse('2024-01-15T10:30:00.000')),
        );
      });

      test('handles missing optional fields with defaults', () {
        final json = {'id': 1};

        final resena = Resena.fromJson(json);

        expect(resena.id, equals(1));
        expect(resena.usuarioId, equals(0));
        expect(resena.nombreUsuario, equals('Usuario'));
        expect(resena.fotoPerfilBase64, isNull);
        expect(resena.texto, equals(''));
      });

      test('handles null values with defaults', () {
        final json = {
          'id': 1,
          'usuarioId': null,
          'nombreUsuario': null,
          'texto': null,
          'fecha': null,
        };

        final resena = Resena.fromJson(json);

        expect(resena.usuarioId, equals(0));
        expect(resena.nombreUsuario, equals('Usuario'));
        expect(resena.texto, equals(''));
        expect(resena.fecha, isA<DateTime>());
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        final fecha = DateTime.parse('2024-01-15T10:30:00.000');
        final resena = Resena(
          id: 1,
          usuarioId: 42,
          nombreUsuario: 'Juan Pérez',
          fotoPerfilBase64: 'base64avatar',
          texto: 'Excelente libro',
          fecha: fecha,
        );

        final json = resena.toJson();

        expect(json['id'], equals(1));
        expect(json['usuarioId'], equals(42));
        expect(json['nombreUsuario'], equals('Juan Pérez'));
        expect(json['fotoPerfil'], equals('base64avatar'));
        expect(json['texto'], equals('Excelente libro'));
        expect(json['fecha'], equals('2024-01-15T10:30:00.000'));
      });

      test('serializes without optional fotoPerfil', () {
        final resena = Resena(
          id: 2,
          usuarioId: 10,
          nombreUsuario: 'Ana',
          texto: 'Bueno',
          fecha: DateTime(2024, 1, 1),
        );

        final json = resena.toJson();

        expect(json['fotoPerfil'], isNull);
      });
    });
  });
}
