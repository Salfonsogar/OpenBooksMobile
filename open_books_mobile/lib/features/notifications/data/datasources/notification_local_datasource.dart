import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/app_notification.dart';

class NotificationLocalDataSource {
  final Database database;

  NotificationLocalDataSource(this.database);

  static const String tableNotifications = 'notifications';

  static String get createTableQuery => '''
    CREATE TABLE IF NOT EXISTS $tableNotifications (
      id TEXT PRIMARY KEY,
      titulo TEXT NOT NULL,
      mensaje TEXT NOT NULL,
      tipo TEXT NOT NULL,
      data TEXT,
      leida INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL
    )
  ''';

  static String get createIndexQuery => '''
    CREATE INDEX IF NOT EXISTS idx_notifications_created_at 
    ON $tableNotifications(created_at DESC)
  ''';

  Future<void> insertNotification(AppNotification notification) async {
    await database.insert(
      tableNotifications,
      {
        'id': notification.id,
        'titulo': notification.titulo,
        'mensaje': notification.mensaje,
        'tipo': notification.tipo,
        'data': notification.data != null ? jsonEncode(notification.data) : null,
        'leida': notification.leida ? 1 : 0,
        'created_at': notification.createdAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AppNotification>> getAllNotifications() async {
    final result = await database.query(
      tableNotifications,
      orderBy: 'created_at DESC',
    );

    return result.map((map) {
      final dataString = map['data'] as String?;
      return AppNotification(
        id: map['id'] as String,
        titulo: map['titulo'] as String,
        mensaje: map['mensaje'] as String,
        tipo: map['tipo'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        leida: (map['leida'] as int) == 1,
        data: dataString != null ? jsonDecode(dataString) as Map<String, dynamic> : null,
      );
    }).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await database.update(
      tableNotifications,
      {'leida': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> markAllAsRead() async {
    await database.update(
      tableNotifications,
      {'leida': 1},
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    await database.delete(
      tableNotifications,
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> clearAll() async {
    await database.delete(tableNotifications);
  }

  Future<int> getUnreadCount() async {
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM $tableNotifications WHERE leida = 0',
    );
    return result.first['count'] as int;
  }
}
