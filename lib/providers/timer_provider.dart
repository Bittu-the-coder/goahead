import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
import '../utils/date_helpers.dart';

class TimerProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

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

  void startTimer() {
    if (_subject.isEmpty) return;

    _isRunning = true;
    if (_startTime == null) {
      _startTime = DateTime.now();
    }

    // Show notification immediately when starting
    _notificationService.showTimerNotification(
      title: _isBreak ? 'Break Time' : 'Studying: $_subject',
      body: formattedTime,
      seconds: _seconds,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        _seconds--;
        // Update notification every second to sync with app
        _notificationService.showTimerNotification(
          title: _isBreak ? 'Break Time' : 'Studying: $_subject',
          body: formattedTime,
          seconds: _seconds,
        );
        notifyListeners();
      } else {
        _handleTimerComplete();
      }
    });

    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    _notificationService.cancelTimerNotification();
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _seconds = _isBreak ? 5 * 60 : _selectedDuration * 60;
    _startTime = null;
    _notificationService.cancelTimerNotification();
    notifyListeners();
  }

  // Skip break and start new study session
  void skipBreak() {
    if (_isBreak) {
      _timer?.cancel();
      _isRunning = false;
      _isBreak = false;
      _seconds = _selectedDuration * 60;
      _startTime = null;
      _notificationService.cancelTimerNotification();
      notifyListeners();
    }
  }

  void _handleTimerComplete() {
    _timer?.cancel();
    _isRunning = false;
    _notificationService.cancelTimerNotification();

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

  // Get minutes studied for stats tracking
  int get minutesStudied {
    if (_startTime == null) return 0;
    return _selectedDuration - (_seconds ~/ 60);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationService.cancelTimerNotification();
    super.dispose();
  }
}
