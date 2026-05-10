import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/libros/data/models/valoracion.dart';

void main() {
  group('Valoracion', () {
    group('fromJson', () {
      test('parses valid JSON with all fields correctly', () {
        final json = {
          'libroId': 1,
          'puntuacion': 4,
          'usuarioId': 42,
        };

        final valoracion = Valoracion.fromJson(json);

        expect(valoracion.libroId, equals(1));
        expect(valoracion.puntuacion, equals(4));
        expect(valoracion.usuarioId, equals(42));
      });

      test('handles missing optional fields with defaults', () {
        final Map<String, dynamic> json = {};

        final valoracion = Valoracion.fromJson(json);

        expect(valoracion.libroId, equals(0));
        expect(valoracion.puntuacion, equals(0));
        expect(valoracion.usuarioId, isNull);
      });

      test('handles null values with defaults', () {
        final Map<String, dynamic> json = {
          'libroId': null,
          'puntuacion': null,
          'usuarioId': null,
        };

        final valoracion = Valoracion.fromJson(json);

        expect(valoracion.libroId, equals(0));
        expect(valoracion.puntuacion, equals(0));
        expect(valoracion.usuarioId, isNull);
      });
    });

    group('toJson', () {
      test('serializes with usuarioId when present', () {
        final valoracion = Valoracion(
          libroId: 1,
          puntuacion: 4,
          usuarioId: 42,
        );

        final json = valoracion.toJson();

        expect(json['libroId'], equals(1));
        expect(json['puntuacion'], equals(4));
        expect(json['usuarioId'], equals(42));
      });

      test('serializes without usuarioId when null', () {
        final valoracion = Valoracion(
          libroId: 1,
          puntuacion: 4,
        );

        final json = valoracion.toJson();

        expect(json['libroId'], equals(1));
        expect(json['puntuacion'], equals(4));
        expect(json.containsKey('usuarioId'), isFalse);
      });
    });
  });
}
