import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/notifications/data/models/app_notification.dart';

void main() {
  group('AppNotification', () {
    final now = DateTime(2026, 5, 10, 12, 0, 0);

    group('fromJson', () {
      test('creates instance with all fields', () {
        final json = {
          'id': 'notif_1',
          'titulo': 'Test Title',
          'mensaje': 'Test message',
          'tipo': 'sistema',
          'createdAt': '2026-05-10T12:00:00.000',
          'leida': true,
          'data': {'key': 'value'},
        };

        final notification = AppNotification.fromJson(json);

        expect(notification.id, 'notif_1');
        expect(notification.titulo, 'Test Title');
        expect(notification.mensaje, 'Test message');
        expect(notification.tipo, 'sistema');
        expect(notification.createdAt, now);
        expect(notification.leida, isTrue);
        expect(notification.data, {'key': 'value'});
      });

      test('uses default values for missing fields', () {
        final json = <String, dynamic>{};

        final notification = AppNotification.fromJson(json);

        expect(notification.id, isNotEmpty);
        expect(notification.titulo, 'Notificación');
        expect(notification.mensaje, '');
        expect(notification.tipo, 'sistema');
        expect(notification.leida, isFalse);
        expect(notification.data, isNull);
      });

      test('handles missing createdAt by using current time', () {
        final json = {'id': '1', 'titulo': 'T', 'mensaje': 'M', 'tipo': 'sistema'};

        final notification = AppNotification.fromJson(json);

        expect(notification.createdAt, isA<DateTime>());
      });

      test('handles null leida', () {
        final json = {
          'id': '1', 'titulo': 'T', 'mensaje': 'M',
          'tipo': 'sistema', 'createdAt': '2026-05-10T12:00:00.000',
          'leida': null,
        };

        final notification = AppNotification.fromJson(json);

        expect(notification.leida, isFalse);
      });

      test('handles null data', () {
        final json = {
          'id': '1', 'titulo': 'T', 'mensaje': 'M',
          'tipo': 'sistema', 'createdAt': '2026-05-10T12:00:00.000',
          'data': null,
        };

        final notification = AppNotification.fromJson(json);

        expect(notification.data, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final notification = AppNotification(
          id: 'notif_1',
          titulo: 'Test Title',
          mensaje: 'Test message',
          tipo: 'sistema',
          createdAt: now,
          leida: true,
          data: const {'key': 'value'},
        );

        final json = notification.toJson();

        expect(json['id'], 'notif_1');
        expect(json['titulo'], 'Test Title');
        expect(json['mensaje'], 'Test message');
        expect(json['tipo'], 'sistema');
        expect(json['createdAt'], '2026-05-10T12:00:00.000');
        expect(json['leida'], isTrue);
        expect(json['data'], {'key': 'value'});
      });

      test('handles null data in toJson', () {
        final notification = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M',
          tipo: 'sistema', createdAt: now,
        );

        final json = notification.toJson();

        expect(json['data'], isNull);
      });

      test('roundtrip fromJson to toJson preserves values', () {
        final original = AppNotification(
          id: 'roundtrip_1', titulo: 'Title', mensaje: 'Msg',
          tipo: 'libro', createdAt: now, leida: false,
          data: const {'url': 'http://example.com'},
        );

        final json = original.toJson();
        final restored = AppNotification.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.titulo, original.titulo);
        expect(restored.mensaje, original.mensaje);
        expect(restored.tipo, original.tipo);
        expect(restored.leida, original.leida);
        expect(restored.data, original.data);
      });
    });

    group('Equatable', () {
      test('value equality', () {
        final a = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'sistema',
          createdAt: now, leida: false,
        );
        final b = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'sistema',
          createdAt: now, leida: false,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('inequality when fields differ', () {
        final a = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'sistema',
          createdAt: now,
        );
        final b = AppNotification(
          id: '2', titulo: 'T', mensaje: 'M', tipo: 'sistema',
          createdAt: now,
        );

        expect(a, isNot(equals(b)));
      });

      test('props returns correct list', () {
        final notification = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'sistema',
          createdAt: now, leida: true, data: null,
        );

        expect(notification.props, ['1', 'T', 'M', 'sistema', now, true, null]);
      });
    });

    group('icon', () {
      test('returns warning icon for sancion', () {
        final n = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'sancion',
          createdAt: now,
        );

        expect(n.icon, Icons.warning_rounded);
      });

      test('returns lightbulb icon for sugerencia', () {
        final n = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'sugerencia',
          createdAt: now,
        );

        expect(n.icon, Icons.lightbulb_rounded);
      });

      test('returns book icon for libro', () {
        final n = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'libro',
          createdAt: now,
        );

        expect(n.icon, Icons.menu_book_rounded);
      });

      test('returns settings icon for sistema', () {
        final n = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'sistema',
          createdAt: now,
        );

        expect(n.icon, Icons.settings_rounded);
      });

      test('returns default notifications icon for unknown tipo', () {
        final n = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'otro',
          createdAt: now,
        );

        expect(n.icon, Icons.notifications_rounded);
      });
    });

    group('copyWith', () {
      test('creates new instance with changed values', () {
        final original = AppNotification(
          id: '1', titulo: 'Old Title', mensaje: 'Old msg',
          tipo: 'sistema', createdAt: now, leida: false,
        );

        final copied = original.copyWith(
          titulo: 'New Title',
          leida: true,
        );

        expect(copied.id, '1');
        expect(copied.titulo, 'New Title');
        expect(copied.mensaje, 'Old msg');
        expect(copied.leida, isTrue);
      });

      test('copyWith with no arguments returns equal instance', () {
        final original = AppNotification(
          id: '1', titulo: 'T', mensaje: 'M', tipo: 'sistema',
          createdAt: now, leida: false,
        );

        final copied = original.copyWith();

        expect(copied, equals(original));
      });
    });
  });
}
