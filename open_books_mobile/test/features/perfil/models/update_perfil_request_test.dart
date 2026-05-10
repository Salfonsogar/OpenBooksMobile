import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/perfil/data/models/update_perfil_request.dart';

void main() {
  group('UpdatePerfilRequest', () {
    group('toJson', () {
      test('includes only non-null fields', () {
        final request = UpdatePerfilRequest(userName: 'newuser');

        final json = request.toJson();

        expect(json['userName'], 'newuser');
        expect(json.containsKey('email'), isFalse);
        expect(json.containsKey('nombreCompleto'), isFalse);
        expect(json.containsKey('fotoPerfil'), isFalse);
      });

      test('includes all fields when all are provided', () {
        final request = UpdatePerfilRequest(
          userName: 'newuser',
          email: 'new@example.com',
          nombreCompleto: 'New User',
          fotoPerfilBase64: 'base64string',
        );

        final json = request.toJson();

        expect(json['userName'], 'newuser');
        expect(json['email'], 'new@example.com');
        expect(json['nombreCompleto'], 'New User');
        expect(json['fotoPerfil'], 'base64string');
      });

      test('excludes null email and nombreCompleto', () {
        final request = UpdatePerfilRequest(
          userName: 'partial',
          fotoPerfilBase64: 'img',
        );

        final json = request.toJson();

        expect(json['userName'], 'partial');
        expect(json['fotoPerfil'], 'img');
        expect(json.containsKey('email'), isFalse);
        expect(json.containsKey('nombreCompleto'), isFalse);
      });
    });
  });
}
