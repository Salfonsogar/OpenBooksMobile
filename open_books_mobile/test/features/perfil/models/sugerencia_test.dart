import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/perfil/data/models/sugerencia.dart';

void main() {
  group('Sugerencia', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 1,
          'idUsuario': 42,
          'nombreUsuario': 'johndoe',
          'comentario': 'Excelente aplicación',
        };

        final sugerencia = Sugerencia.fromJson(json);

        expect(sugerencia.id, 1);
        expect(sugerencia.idUsuario, 42);
        expect(sugerencia.nombreUsuario, 'johndoe');
        expect(sugerencia.comentario, 'Excelente aplicación');
      });

      test('uses defaults for missing fields', () {
        final json = <String, dynamic>{
          'id': 1,
        };

        final sugerencia = Sugerencia.fromJson(json);

        expect(sugerencia.id, 1);
        expect(sugerencia.idUsuario, 0);
        expect(sugerencia.nombreUsuario, '');
        expect(sugerencia.comentario, '');
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        final sugerencia = Sugerencia(
          id: 1,
          idUsuario: 42,
          nombreUsuario: 'johndoe',
          comentario: 'Excelente aplicación',
        );

        final json = sugerencia.toJson();

        expect(json['id'], 1);
        expect(json['idUsuario'], 42);
        expect(json['nombreUsuario'], 'johndoe');
        expect(json['comentario'], 'Excelente aplicación');
      });
    });
  });
}
