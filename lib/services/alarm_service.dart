import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for scheduling alarms that fire even when app is closed
class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  bool _initialized = false;

  /// Initialize the alarm manager
  Future<void> initialize() async {
    if (_initialized) return;
    await AndroidAlarmManager.initialize();
    _initialized = true;
  }

  /// Schedule a one-time alarm for timer completion
  Future<void> scheduleTimerAlarm({
    required int alarmId,
    required Duration duration,
    required String subject,
  }) async {
    // Store alarm data in shared preferences for callback to access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarm_$alarmId', subject);

    await AndroidAlarmManager.oneShot(
      duration,
      alarmId,
      _timerAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: false,
    );
  }

  /// Schedule a task notification at a specific time
  Future<void> scheduleTaskNotification({
    required int alarmId,
    required DateTime scheduledTime,
    required String taskName,
  }) async {
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return;

    final duration = scheduledTime.difference(now);

    // Store task data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('task_$alarmId', taskName);

    await AndroidAlarmManager.oneShot(
      duration,
      alarmId,
      _taskAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: false,
    );
  }

  /// Cancel a scheduled alarm
  Future<void> cancelAlarm(int alarmId) async {
    await AndroidAlarmManager.cancel(alarmId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alarm_$alarmId');
    await prefs.remove('task_$alarmId');
  }
}

/// Callback for timer completion - runs in isolate
@pragma('vm:entry-point')
Future<void> _timerAlarmCallback(int alarmId) async {
  final prefs = await SharedPreferences.getInstance();
  final subject = prefs.getString('alarm_$alarmId') ?? 'Study Session';

  await _showNotification(
    id: alarmId,
    title: '⏰ Timer Complete!',
    body: '$subject session finished. Take a break!',
  );

  await prefs.remove('alarm_$alarmId');
}

/// Callback for task notification - runs in isolate
@pragma('vm:entry-point')
Future<void> _taskAlarmCallback(int alarmId) async {
  final prefs = await SharedPreferences.getInstance();
  final taskName = prefs.getString('task_$alarmId') ?? 'Study Time';

  await _showNotification(
    id: alarmId,
    title: '📚 Time to Study!',
    body: 'Start your session: $taskName',
  );

  await prefs.remove('task_$alarmId');
}

/// Show a notification from isolate
Future<void> _showNotification({
  required int id,
  required String title,
  required String body,
}) async {
  final notifications = FlutterLocalNotificationsPlugin();

  // Initialize in case we're in isolate
  await notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  const androidDetails = AndroidNotificationDetails(
    'study_alarm_channel',
    'Study Alarms',
    channelDescription: 'Notifications for study timers and tasks',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  await notifications.show(
    id,
    title,
    body,
    const NotificationDetails(android: androidDetails),
  );
}
