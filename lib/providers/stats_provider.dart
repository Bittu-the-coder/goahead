import 'package:flutter/foundation.dart';
import '../services/stats_service.dart';

class StatsProvider with ChangeNotifier {
  final StatsService _statsService = StatsService();

  Map<String, dynamic>? _stats;
  List<dynamic> _badges = [];
  List<dynamic> _calendar = [];
  int _earnedBadgeCount = 0;
  int _totalBadgeCount = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get stats => _stats;
  List<dynamic> get badges => _badges;
  List<dynamic> get calendar => _calendar;
  int get earnedBadgeCount => _earnedBadgeCount;
  int get totalBadgeCount => _totalBadgeCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Quick stat getters
  int get dailyMinutes => _stats?['daily']?['minutes'] ?? 0;
  int get weeklyMinutes => _stats?['weekly']?['minutes'] ?? 0;
  int get monthlyMinutes => _stats?['monthly']?['minutes'] ?? 0;
  int get lifetimeMinutes => _stats?['lifetime']?['minutes'] ?? 0;
  int get currentStreak => _stats?['streak']?['current'] ?? 0;
  int get longestStreak => _stats?['streak']?['longest'] ?? 0;
  int get dailyGoal => _stats?['daily']?['goal'] ?? 240;
  int get weeklyGoal => _stats?['weekly']?['goal'] ?? 600;

  // Load all stats
  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _statsService.getStatsSummary(),
        _statsService.getBadges(),
        _statsService.getStreakCalendar(),
      ]);

      _stats = results[0];

      final badgeData = results[1];
      _badges = badgeData['badges'] ?? [];
      _earnedBadgeCount = badgeData['earnedCount'] ?? 0;
      _totalBadgeCount = badgeData['totalCount'] ?? 0;

      final calendarData = results[2];
      _calendar = calendarData['calendar'] ?? [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update stats after study session
  Future<List<dynamic>> updateStudyStats({
    required int minutes,
    bool sessionCompleted = true,
  }) async {
    try {
      final result = await _statsService.updateStats(
        minutes: minutes,
        sessionCompleted: sessionCompleted,
      );

      // Reload stats to get updated values
      await loadStats();

      // Return new badges earned
      return result['newBadges'] ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get formatted time string
  String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }

  // Get progress percentage
  double getDailyProgress() {
    if (dailyGoal <= 0) return 0;
    return (dailyMinutes / dailyGoal).clamp(0.0, 1.0);
  }

  double getWeeklyProgress() {
    if (weeklyGoal <= 0) return 0;
    return (weeklyMinutes / weeklyGoal).clamp(0.0, 1.0);
  }
}
