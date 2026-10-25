import 'package:material_ui/material_ui.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract interface class LocalNotificationService {
  Future<void> initialize();
  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
  });
  Future<void> cancelDailyReminder();
  Future<void> showNotification({required String title, required String body});
}

class FlutterLocalNotificationService implements LocalNotificationService {
  FlutterLocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const int dailyReminderNotificationId = 1001;
  static const String channelId = 'habit_reminders_channel';
  static const String channelName = 'Habit Reminders';
  static const String channelDescription =
      'Daily reminders to complete scheduled habits';

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(settings: initSettings);
    } catch (_) {
      // Platform channels may not be bound in test environments
    }
    _initialized = true;
  }

  NotificationDetails _buildNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    await initialize();

    try {
      await _plugin.zonedSchedule(
        id: dailyReminderNotificationId,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfTime(time),
        notificationDetails: _buildNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Platform channels may not be bound in test environments
    }
  }

  @override
  Future<void> cancelDailyReminder() async {
    try {
      await _plugin.cancel(id: dailyReminderNotificationId);
    } catch (_) {
      // Platform channels may not be bound in test environments
    }
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await initialize();
    try {
      await _plugin.show(
        id: 0,
        title: title,
        body: body,
        notificationDetails: _buildNotificationDetails(),
      );
    } catch (_) {
      // Platform channels may not be bound in test environments
    }
  }
}

class FakeLocalNotificationService implements LocalNotificationService {
  bool initialized = false;
  TimeOfDay? scheduledTime;
  String? scheduledTitle;
  String? scheduledBody;
  bool canceled = false;
  List<Map<String, String>> shownNotifications = [];

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    scheduledTime = time;
    scheduledTitle = title;
    scheduledBody = body;
    canceled = false;
  }

  @override
  Future<void> cancelDailyReminder() async {
    scheduledTime = null;
    scheduledTitle = null;
    scheduledBody = null;
    canceled = true;
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    shownNotifications.add({'title': title, 'body': body});
  }
}

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return FlutterLocalNotificationService();
});
