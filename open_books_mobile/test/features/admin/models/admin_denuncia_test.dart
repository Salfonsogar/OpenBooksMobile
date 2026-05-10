import 'package:flutter_test/flutter_test.dart';

import 'package:open_books_mobile/features/admin/moderacion/data/models/admin_denuncia.dart';

void main() {
  group('AdminDenuncia', () {
    test('fromJson creates AdminDenuncia correctly', () {
      final json = {
        'id': 1,
        'usuarioDenuncianteId': 10,
        'nombreUsuarioDenunciante': 'UserA',
        'usuarioDenunciadoId': 20,
        'nombreUsuarioDenunciado': 'UserB',
        'motivo': 'Spam',
        'descripcion': 'Descripción de la denuncia',
        'fechaCreacion': '2024-01-15T00:00:00.000',
        'estado': 'Pendiente',
      };

      final denuncia = AdminDenuncia.fromJson(json);

      expect(denuncia.id, 1);
      expect(denuncia.usuarioDenuncianteId, 10);
      expect(denuncia.nombreUsuarioDenunciante, 'UserA');
      expect(denuncia.usuarioDenunciadoId, 20);
      expect(denuncia.nombreUsuarioDenunciado, 'UserB');
      expect(denuncia.motivo, 'Spam');
      expect(denuncia.descripcion, 'Descripción de la denuncia');
      expect(denuncia.fechaCreacion, DateTime(2024, 1, 15));
      expect(denuncia.estado, 'Pendiente');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {
        'id': 2,
        'fechaCreacion': '2024-02-01T00:00:00.000',
      };

      final denuncia = AdminDenuncia.fromJson(json);

      expect(denuncia.usuarioDenuncianteId, 0);
      expect(denuncia.nombreUsuarioDenunciante, '');
      expect(denuncia.usuarioDenunciadoId, 0);
      expect(denuncia.nombreUsuarioDenunciado, '');
      expect(denuncia.motivo, '');
      expect(denuncia.descripcion, isNull);
      expect(denuncia.estado, 'Pendiente');
    });

    test('supports value equality', () {
      final d1 = AdminDenuncia(
        id: 1,
        usuarioDenuncianteId: 10,
        nombreUsuarioDenunciante: 'A',
        usuarioDenunciadoId: 20,
        nombreUsuarioDenunciado: 'B',
        motivo: 'Spam',
        descripcion: 'Desc',
        fechaCreacion: DateTime(2024, 1, 1),
        estado: 'Pendiente',
      );
      final d2 = AdminDenuncia(
        id: 1,
        usuarioDenuncianteId: 10,
        nombreUsuarioDenunciante: 'A',
        usuarioDenunciadoId: 20,
        nombreUsuarioDenunciado: 'B',
        motivo: 'Spam',
        descripcion: 'Desc',
        fechaCreacion: DateTime(2024, 1, 1),
        estado: 'Pendiente',
      );

      expect(d1, equals(d2));
    });
  });
}
