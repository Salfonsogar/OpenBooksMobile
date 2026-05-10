import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:open_books_mobile/features/notifications/data/models/app_notification.dart';
import 'package:open_books_mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:open_books_mobile/shared/core/errors/failures.dart';

class MockNotificationLocalDataSource extends Mock implements NotificationLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(AppNotification(
      id: '', titulo: '', mensaje: '', tipo: '', createdAt: DateTime(2020),
    ));
  });

  group('NotificationRepositoryImpl', () {
    late NotificationLocalDataSource dataSource;
    late NotificationRepositoryImpl repository;

    final now = DateTime(2026, 5, 10);
    final notifications = [
      AppNotification(
        id: '1', titulo: 'Notif 1', mensaje: 'Msg 1',
        tipo: 'sistema', createdAt: now, leida: false,
      ),
      AppNotification(
        id: '2', titulo: 'Notif 2', mensaje: 'Msg 2',
        tipo: 'libro', createdAt: now, leida: true,
      ),
    ];

    setUp(() {
      dataSource = MockNotificationLocalDataSource();
      repository = NotificationRepositoryImpl(localDataSource: dataSource);
    });

    group('getNotifications', () {
      test('returns Right with list of notifications on success', () async {
        when(() => dataSource.getAllNotifications())
            .thenAnswer((_) async => notifications);

        final result = await repository.getNotifications();

        expect(result, isA<Right<Failure, List<AppNotification>>>());
        result.fold(
          (_) => fail('Expected Right'),
          (list) {
            expect(list.length, 2);
            expect(list[0].id, '1');
            expect(list[1].id, '2');
          },
        );
      });

      test('returns Left with CacheFailure on error', () async {
        when(() => dataSource.getAllNotifications())
            .thenThrow(Exception('DB error'));

        final result = await repository.getNotifications();

        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('DB error'));
          },
          (_) => fail('Expected Left'),
        );
      });
    });

    group('addNotification', () {
      test('returns Right on success', () async {
        when(() => dataSource.insertNotification(any()))
            .thenAnswer((_) async {});

        final result = await repository.addNotification(notifications[0]);

        expect(result, isA<Right<Failure, void>>());
        verify(() => dataSource.insertNotification(notifications[0])).called(1);
      });

      test('returns Left with CacheFailure on error', () async {
        when(() => dataSource.insertNotification(any()))
            .thenThrow(Exception('Insert failed'));

        final result = await repository.addNotification(notifications[0]);

        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Insert failed'));
          },
          (_) => fail('Expected Left'),
        );
      });
    });

    group('markAsRead', () {
      test('returns Right on success', () async {
        when(() => dataSource.markAsRead('1'))
            .thenAnswer((_) async {});

        final result = await repository.markAsRead('1');

        expect(result, isA<Right<Failure, void>>());
        verify(() => dataSource.markAsRead('1')).called(1);
      });

      test('returns Left with CacheFailure on error', () async {
        when(() => dataSource.markAsRead('1'))
            .thenThrow(Exception('Update failed'));

        final result = await repository.markAsRead('1');

        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Update failed'));
          },
          (_) => fail('Expected Left'),
        );
      });
    });

    group('markAllAsRead', () {
      test('returns Right on success', () async {
        when(() => dataSource.markAllAsRead())
            .thenAnswer((_) async {});

        final result = await repository.markAllAsRead();

        expect(result, isA<Right<Failure, void>>());
        verify(() => dataSource.markAllAsRead()).called(1);
      });

      test('returns Left with CacheFailure on error', () async {
        when(() => dataSource.markAllAsRead())
            .thenThrow(Exception('Mass update failed'));

        final result = await repository.markAllAsRead();

        expect(result, isA<Left<Failure, void>>());
      });
    });

    group('deleteNotification', () {
      test('returns Right on success', () async {
        when(() => dataSource.deleteNotification('1'))
            .thenAnswer((_) async {});

        final result = await repository.deleteNotification('1');

        expect(result, isA<Right<Failure, void>>());
        verify(() => dataSource.deleteNotification('1')).called(1);
      });

      test('returns Left with CacheFailure on error', () async {
        when(() => dataSource.deleteNotification('1'))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteNotification('1');

        expect(result, isA<Left<Failure, void>>());
      });
    });

    group('clearAll', () {
      test('returns Right on success', () async {
        when(() => dataSource.clearAll())
            .thenAnswer((_) async {});

        final result = await repository.clearAll();

        expect(result, isA<Right<Failure, void>>());
        verify(() => dataSource.clearAll()).called(1);
      });

      test('returns Left with CacheFailure on error', () async {
        when(() => dataSource.clearAll())
            .thenThrow(Exception('Clear failed'));

        final result = await repository.clearAll();

        expect(result, isA<Left<Failure, void>>());
      });
    });

    group('getUnreadCount', () {
      test('returns Right with count on success', () async {
        when(() => dataSource.getUnreadCount())
            .thenAnswer((_) async => 3);

        final result = await repository.getUnreadCount();

        expect(result, isA<Right<Failure, int>>());
        result.fold(
          (_) => fail('Expected Right'),
          (count) => expect(count, 3),
        );
      });

      test('returns Left with CacheFailure on error', () async {
        when(() => dataSource.getUnreadCount())
            .thenThrow(Exception('Count failed'));

        final result = await repository.getUnreadCount();

        expect(result, isA<Left<Failure, int>>());
      });
    });
  });
}
