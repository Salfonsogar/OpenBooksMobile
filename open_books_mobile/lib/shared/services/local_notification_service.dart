import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static const String _channelId = 'openbooks_local';
  static const String _channelName = 'Recordatorios';
  static const String _channelDescription = 'Notificaciones locales de OpenBooks';
  
  static const String _prefsKey = 'notification_settings';
  static const String _lastReadKey = 'last_read_date';

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.requestNotificationsPermission();
    }
    if (iOS != null) {
      await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    return true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.reminder,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      type == NotificationType.reminder ? _channelName : 'Alertas',
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF2563EB),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleReadingReminder({
    required int daysSinceLastRead,
  }) async {
    final settings = await _getSettings();
    if (!settings['remindersEnabled']) return;

    final title = daysSinceLastRead == 1
        ? '¡Te extraño!'
        : '¿Dónde estás?';
    
    final body = daysSinceLastRead == 1
        ? 'Última vez leíste ayer. ¡Hoy hay más historias esperándote!'
        : 'No has leído en $daysSinceLastRead días. ¡Vuelve a la aventura!';

    await showNotification(
      id: 1,
      title: title,
      body: body,
      payload: 'reading_reminder',
      type: NotificationType.reminder,
    );
  }

  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    final settings = await _getSettings();
    if (!settings['remindersEnabled']) return;

    final androidDetails = const AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    await _notifications.zonedSchedule(
      1,
      '¡Es hora de leer!',
      'Tu próximo capítulo te espera. ¡No pierdas tu racha!',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelScheduled(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<Map<String, dynamic>> _getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsKey);
    if (data == null) {
      return {
        'remindersEnabled': true,
        'dailyReminder': false,
        'reminderHour': 9,
        'reminderMinute': 0,
      };
    }
    return jsonDecode(data);
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(settings));
  }

  Future<void> updateLastReadDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReadKey, DateTime.now().toIso8601String());
  }

  Future<int> getDaysSinceLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRead = prefs.getString(_lastReadKey);
    if (lastRead == null) return 0;
    
    final lastReadDate = DateTime.parse(lastRead);
    return DateTime.now().difference(lastReadDate).inDays;
  }
}

enum NotificationType { reminder, alert }