class AppConstants {
  // API Configuration - Updated for physical device (use your computer's local IP)
  static const String apiBaseUrl = 'http://10.60.176.64:5000/api';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Pomodoro Settings (in minutes)
  static const int pomodoroLength = 25;
  static const int shortBreakLength = 5;
  static const int longBreakLength = 15;

  // App Info
  static const String appName = 'FocusFlow';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String tasksBox = 'tasks';
  static const String sessionsBox = 'sessions';
  static const String goalsBox = 'goals';

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}
