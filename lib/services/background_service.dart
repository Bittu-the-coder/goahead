import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundTimerService {
  static final BackgroundTimerService _instance = BackgroundTimerService._internal();
  factory BackgroundTimerService() => _instance;
  BackgroundTimerService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'study_timer_channel',
        initialNotificationTitle: 'GoAhead Study Timer',
        initialNotificationContent: 'Timer is running...',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.specialUse],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    _initialized = true;
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    final notifications = FlutterLocalNotificationsPlugin();

    int seconds = 0;
    String subject = '';
    bool isBreak = false;

    // Listen for timer commands
    service.on('start_timer').listen((event) {
      if (event != null) {
        seconds = event['seconds'] as int? ?? 0;
        subject = event['subject'] as String? ?? '';
        isBreak = event['isBreak'] as bool? ?? false;
      }
    });

    service.on('update_seconds').listen((event) {
      if (event != null) {
        seconds = event['seconds'] as int? ?? seconds;
      }
    });

    service.on('stop').listen((event) {
      service.stopSelf();
    });

    // Timer loop
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (seconds > 0) {
        seconds--;

        final mins = seconds ~/ 60;
        final secs = seconds % 60;
        final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

        // Update notification
        final androidDetails = AndroidNotificationDetails(
          'study_timer_channel',
          'Study Timer',
          channelDescription: 'Ongoing study timer notification',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          silent: true,
        );

        await notifications.show(
          888,
          isBreak ? 'Break Time' : 'Studying: $subject',
          timeStr,
          NotificationDetails(android: androidDetails),
        );

        // Send update to app
        service.invoke('update', {'seconds': seconds});
      } else if (seconds == 0) {
        service.invoke('completed', {});
        seconds = -1; // Prevent multiple completions
      }
    });
  }

  Future<void> startTimer({
    required int seconds,
    required String subject,
    required bool isBreak,
  }) async {
    await _service.startService();
    _service.invoke('start_timer', {
      'seconds': seconds,
      'subject': subject,
      'isBreak': isBreak,
    });
  }

  void updateSeconds(int seconds) {
    _service.invoke('update_seconds', {'seconds': seconds});
  }

  Future<void> stopTimer() async {
    _service.invoke('stop');
  }

  Stream<Map<String, dynamic>?> get updates => _service.on('update');
  Stream<Map<String, dynamic>?> get onCompleted => _service.on('completed');
}
