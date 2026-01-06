import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Request notification permission for Android 13+
    await _requestPermission();

    _initialized = true;
  }

  Future<void> _requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  // Show timer notification (persistent in notification area)
  // Show timer notification (persistent in notification area)
  Future<void> showTimerNotification({
    required String title,
    required String body,
    required int seconds,
    int? endTimeMs, // New: End time in milliseconds for chronometer
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Study Timer',
      channelDescription: 'Ongoing study timer notification',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      when: endTimeMs, // Set the end time
      usesChronometer: true, // Enable native countdown
      chronometerCountDown: true, // Count down instead of up
      silent: true,
      playSound: false,
      enableVibration: false,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      title,
      body,
      notificationDetails,
    );
  }

  // Update timer notification
  Future<void> updateTimerNotification({
    required String title,
    required String timeRemaining,
  }) async {
    await showTimerNotification(
      title: title,
      body: timeRemaining,
      seconds: 0,
    );
  }

  // Cancel timer notification
  Future<void> cancelTimerNotification() async {
    await _notifications.cancel(1);
  }

  // Show instant notification (for badges, achievements, etc.)
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
    );
  }

  // Schedule notification for study task
  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'task_reminder_channel',
      'Task Reminders',
      channelDescription: 'Notifications for scheduled study tasks',
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // For scheduling, we need to use zonedSchedule but it requires timezone setup
    // For now, show immediate notification as reminder
    final difference = scheduledTime.difference(DateTime.now());
    if (difference.isNegative) return;

    // Simple delay-based notification (basic implementation)
    Future.delayed(difference, () {
      _notifications.show(id, title, body, notificationDetails);
    });
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
