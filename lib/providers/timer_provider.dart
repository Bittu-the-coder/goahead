import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // For WidgetsBinding
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/alarm_service.dart';
import '../utils/date_helpers.dart';

class TimerProvider with ChangeNotifier, WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();
  final AlarmService _alarmService = AlarmService();
  static const int _timerAlarmId = 999;

  Timer? _timer;
  int _seconds = 25 * 60;
  int _selectedDuration = 25; // minutes
  bool _isRunning = false;
  bool _isBreak = false;
  DateTime? _startTime;
  String _subject = '';
  String _topic = '';

  // Track completed session minutes for stats
  int _lastCompletedMinutes = 0;
  bool _sessionJustCompleted = false;

  // Getters
  int get seconds => _seconds;
  int get selectedDuration => _selectedDuration;
  bool get isRunning => _isRunning;
  bool get isBreak => _isBreak;
  DateTime? get startTime => _startTime;
  String get subject => _subject;
  String get topic => _topic;
  String get formattedTime => DateHelpers.formatSeconds(_seconds);
  double get progress => 1 - (_seconds / (_isBreak ? 5 * 60 : _selectedDuration * 60));

  // For stats tracking
  int get lastCompletedMinutes => _lastCompletedMinutes;
  bool get sessionJustCompleted => _sessionJustCompleted;

  TimerProvider() {
    WidgetsBinding.instance.addObserver(this);
    _restoreTimerState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('DEBUG: App resumed. Syncing timer...');
      _syncTimerWithStorage();
    }
  }

  Future<void> _syncTimerWithStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool('timer_is_running') ?? false;

    if (isRunning) {
      final endTime = prefs.getInt('timer_end_time') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (endTime > now) {
        final remainingSeconds = ((endTime - now) / 1000).round();
        print('DEBUG: Syncing timer. Old: $_seconds, New: $remainingSeconds');
        _seconds = remainingSeconds;

        if (!_isRunning) {
           _isRunning = true;
           _startPeriodicTimer();
        }
        notifyListeners();
      } else {
        // Timer finished while backgrounded
        _handleTimerComplete();
      }
    }
  }

  void clearSessionCompleted() {
    _sessionJustCompleted = false;
    _lastCompletedMinutes = 0;
  }

  static const List<int> durationOptions = [15, 25, 45, 60, 90, 120];

  void setDuration(int minutes) {
    if (!_isRunning) {
      _selectedDuration = minutes;
      _seconds = minutes * 60;
      notifyListeners();
    }
  }

  void setSubject(String subject) {
    _subject = subject;
    notifyListeners();
  }

  void setTopic(String topic) {
    _topic = topic;
    notifyListeners();
  }

  Future<void> startTimer() async {
    if (_subject.isEmpty && !_isBreak) return;

    _isRunning = true;
    if (_startTime == null) {
      _startTime = DateTime.now();
    }

    // Keep device awake while timer is running
    WakelockPlus.enable();

    // Save state for persistence
    await _saveTimerState();

    // Schedule background alarm for completion
    _alarmService.scheduleTimerAlarm(
      alarmId: _timerAlarmId,
      duration: Duration(seconds: _seconds),
      subject: _isBreak ? 'Break' : _subject,
    );

    // Show notification immediately when starting
    _notificationService.showTimerNotification(
      title: _isBreak ? 'Break Time' : 'Studying: $_subject',
      body: 'Time Remaining', // Body is static, chronometer shows time
      seconds: _seconds,
      endTimeMs: DateTime.now().millisecondsSinceEpoch + (_seconds * 1000),
    );

    _startPeriodicTimer();
    notifyListeners();
  }

  void _startPeriodicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        _seconds--;
        // Update notification every second to sync with app
        // Note: This might pause when app is backgrounded
        _notificationService.showTimerNotification(
          title: _isBreak ? 'Break Time' : 'Studying: $_subject',
          body: 'Time Remaining',
          seconds: _seconds,
          endTimeMs: DateTime.now().millisecondsSinceEpoch + (_seconds * 1000),
        );
        notifyListeners();
      } else {
        _handleTimerComplete();
      }
    });
  }

  Future<void> pauseTimer() async {
    _timer?.cancel();
    _isRunning = false;
    WakelockPlus.disable();
    _notificationService.cancelTimerNotification();
    _alarmService.cancelAlarm(_timerAlarmId);
    await _clearTimerState(); // Clear persistence on pause
    notifyListeners();
  }

  Future<void> resetTimer() async {
    _timer?.cancel();
    _isRunning = false;
    _seconds = _isBreak ? 5 * 60 : _selectedDuration * 60;
    _startTime = null;
    WakelockPlus.disable();
    _notificationService.cancelTimerNotification();
    _alarmService.cancelAlarm(_timerAlarmId);
    await _clearTimerState();
    notifyListeners();
  }

  // Skip break and start new study session
  Future<void> skipBreak() async {
    if (_isBreak) {
      _timer?.cancel();
      _isRunning = false;
      _isBreak = false;
      _seconds = _selectedDuration * 60;
      _startTime = null;
      _notificationService.cancelTimerNotification();
      _alarmService.cancelAlarm(_timerAlarmId);
      await _clearTimerState();
      notifyListeners();
    }
  }

  Future<void> _handleTimerComplete() async {
    _timer?.cancel();
    _isRunning = false;
    _notificationService.cancelTimerNotification();
    _alarmService.cancelAlarm(_timerAlarmId);
    await _clearTimerState();

    // Track completed study session (not break) for stats
    if (!_isBreak) {
      _lastCompletedMinutes = _selectedDuration;
      _sessionJustCompleted = true;
    }

    // Show completion notification
    _notificationService.showNotification(
      title: _isBreak ? 'Break Over!' : '🎉 Study Session Complete!',
      body: _isBreak ? 'Time to get back to $_subject' : 'Great job! $_selectedDuration minutes logged.',
    );

    // Toggle break mode
    _isBreak = !_isBreak;
    _seconds = _isBreak ? 5 * 60 : _selectedDuration * 60;
    _startTime = null;

    notifyListeners();
  }

  // Persistence Methods
  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final endTime = now + (_seconds * 1000);

    await prefs.setInt('timer_end_time', endTime);
    await prefs.setInt('timer_duration', _selectedDuration);
    await prefs.setString('timer_subject', _subject);
    await prefs.setBool('timer_is_break', _isBreak);
    await prefs.setBool('timer_is_running', true);
  }

  Future<void> _restoreTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isRunning = prefs.getBool('timer_is_running') ?? false;

      print('DEBUG: Restoring timer state. isRunning: $isRunning');

      if (isRunning) {
        final endTime = prefs.getInt('timer_end_time') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (endTime > now) {
          // Timer is still running
          final remainingSeconds = ((endTime - now) / 1000).round();
          print('DEBUG: Timer still running. Remaining: $remainingSeconds');

          _seconds = remainingSeconds;
          _selectedDuration = prefs.getInt('timer_duration') ?? 25;
          _subject = prefs.getString('timer_subject') ?? '';
          _isBreak = prefs.getBool('timer_is_break') ?? false;
          _isRunning = true;

          WakelockPlus.enable();
          _startPeriodicTimer();

          // Ensure we don't trigger build errors during initialization
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        } else {
          // Timer finished while app was closed
          print('DEBUG: Timer finished while closed.');
          _selectedDuration = prefs.getInt('timer_duration') ?? 25;
          _subject = prefs.getString('timer_subject') ?? '';
          _isBreak = prefs.getBool('timer_is_break') ?? false;

          // Handle completion
          _handleTimerComplete();
        }
      }
    } catch (e) {
      print('DEBUG: Error restoring timer state: $e');
    }
  }

  Future<void> _clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('timer_end_time');
    await prefs.remove('timer_duration');
    await prefs.remove('timer_subject');
    await prefs.remove('timer_is_break');
    await prefs.remove('timer_is_running');
  }

  // Get minutes studied for stats tracking
  int get minutesStudied {
    if (_startTime == null) return 0;
    return _selectedDuration - (_seconds ~/ 60);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _notificationService.cancelTimerNotification();
    super.dispose();
  }
}
