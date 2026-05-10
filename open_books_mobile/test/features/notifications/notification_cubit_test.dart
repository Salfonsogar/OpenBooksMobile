import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/notifications/data/models/app_notification.dart';
import 'package:open_books_mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:open_books_mobile/features/notifications/logic/cubit/notification_cubit.dart';
import 'package:open_books_mobile/features/notifications/logic/cubit/notification_state.dart';
import 'package:open_books_mobile/shared/core/errors/failures.dart';

class MockNotificationRepository extends Mock implements NotificationRepositoryImpl {}

void main() {
  setUpAll(() {
    registerFallbackValue(AppNotification(
      id: '', titulo: '', mensaje: '', tipo: '', createdAt: DateTime(2020),
    ));
  });

  group('NotificationCubit', () {
    late NotificationRepositoryImpl repository;

    final now = DateTime(2026, 5, 10);
    final notifications = [
      AppNotification(
        id: '1', titulo: 'Notif 1', mensaje: 'Msg 1',
        tipo: 'sistema', createdAt: now, leida: false,
      ),
      AppNotification(
        id: '2', titulo: 'Notif 2', mensaje: 'Msg 2',
        tipo: 'libro', createdAt: now.subtract(const Duration(hours: 1)), leida: true,
      ),
      AppNotification(
        id: '3', titulo: 'Notif 3', mensaje: 'Msg 3',
        tipo: 'sistema', createdAt: now.subtract(const Duration(hours: 2)), leida: false,
      ),
    ];

    setUp(() {
      repository = MockNotificationRepository();
    });

    blocTest<NotificationCubit, NotificationState>(
      'initial state is NotificationInitial',
      build: () => NotificationCubit(repository: repository),
      verify: (cubit) {
        expect(cubit.state, isA<NotificationInitial>());
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'loadNotifications success emits [NotificationLoading, NotificationLoaded]',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) => cubit.loadNotifications(),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as NotificationLoaded;
        expect(state.notifications.length, 3);
        expect(state.unreadCount, 2);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'loadNotifications calculates unreadCount correctly',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) => cubit.loadNotifications(),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as NotificationLoaded;
        expect(state.unreadCount, 2);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'loadNotifications failure emits [NotificationLoading, NotificationError]',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Left(CacheFailure(message: 'Error loading')));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) => cubit.loadNotifications(),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
      verify: (cubit) {
        final state = cubit.state as NotificationError;
        expect(state.message, 'Error loading');
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'loadNotifications handles exception',
      setUp: () {
        when(() => repository.getNotifications())
            .thenThrow(Exception('Unexpected error'));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) => cubit.loadNotifications(),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'addNotification adds to list and emits NotificationReceived',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.addNotification(any()))
            .thenAnswer((_) async => const Right(null));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.addNotification(
          AppNotification(
            id: '4', titulo: 'New', mensaje: 'New msg',
            tipo: 'sistema', createdAt: now,
          ),
        );
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationLoaded>(),
        isA<NotificationReceived>(),
      ],
      verify: (cubit) {
        verify(() => repository.addNotification(any())).called(1);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'addNotification increments unreadCount',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.addNotification(any()))
            .thenAnswer((_) async => const Right(null));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.addNotification(
          AppNotification(
            id: '4', titulo: 'New', mensaje: 'New msg',
            tipo: 'sistema', createdAt: now,
          ),
        );
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationLoaded>(),
        isA<NotificationReceived>(),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAsRead marks specific notification as read and recalculates unreadCount',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.markAsRead('1'))
            .thenAnswer((_) async => const Right(null));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.markAsRead('1');
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as NotificationLoaded;
        expect(state.unreadCount, 1);
        expect(state.notifications[0].leida, isTrue);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAllAsRead marks all as read',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.markAllAsRead())
            .thenAnswer((_) async => const Right(null));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.markAllAsRead();
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as NotificationLoaded;
        expect(state.unreadCount, 0);
        expect(state.notifications.every((n) => n.leida), isTrue);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'deleteNotification removes notification and recalculates unreadCount',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.deleteNotification('1'))
            .thenAnswer((_) async => const Right(null));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.deleteNotification('1');
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as NotificationLoaded;
        expect(state.notifications.length, 2);
        expect(state.notifications.any((n) => n.id == '1'), isFalse);
        expect(state.unreadCount, 1);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'clearNotifications clears all notifications',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.clearAll())
            .thenAnswer((_) async => const Right(null));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.clearNotifications();
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as NotificationLoaded;
        expect(state.notifications, isEmpty);
        expect(state.unreadCount, 0);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAsRead failure emits NotificationError',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.markAsRead('1'))
            .thenAnswer((_) async => Left(CacheFailure(message: 'Error marking as read')));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.markAsRead('1');
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationError>(),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAllAsRead failure emits NotificationError',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.markAllAsRead())
            .thenAnswer((_) async => Left(CacheFailure(message: 'Error marking all as read')));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.markAllAsRead();
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationError>(),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'deleteNotification failure emits NotificationError',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.deleteNotification('1'))
            .thenAnswer((_) async => Left(CacheFailure(message: 'Error deleting')));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.deleteNotification('1');
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationError>(),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'clearNotifications failure emits NotificationError',
      setUp: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => Right(notifications));
        when(() => repository.clearAll())
            .thenAnswer((_) async => Left(CacheFailure(message: 'Error clearing')));
      },
      build: () => NotificationCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadNotifications();
        await cubit.clearNotifications();
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
        isA<NotificationError>(),
      ],
    );
  });
}
