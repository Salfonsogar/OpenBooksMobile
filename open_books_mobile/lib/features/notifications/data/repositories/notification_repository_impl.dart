import 'package:dartz/dartz.dart';

import '../../../../shared/core/errors/failures.dart';
import '../datasources/notification_local_datasource.dart';
import '../models/app_notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
  Future<Either<Failure, void>> addNotification(AppNotification notification);
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Future<Either<Failure, void>> clearAll();
  Future<Either<Failure, int>> getUnreadCount();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    try {
      final notifications = await localDataSource.getAllNotifications();
      return Right(notifications);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al cargar notificaciones: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addNotification(AppNotification notification) async {
    try {
      await localDataSource.insertNotification(notification);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al guardar notificación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await localDataSource.markAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al marcar como leída: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await localDataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al marcar todas como leídas: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await localDataSource.deleteNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al eliminar notificación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al limpiar notificaciones: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await localDataSource.getUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al obtener conteo: $e'));
    }
  }
}
