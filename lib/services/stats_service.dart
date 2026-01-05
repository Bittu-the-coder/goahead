import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/constants.dart';
import 'api_service.dart';

class StatsService {
  final ApiService _apiService = ApiService();

  // Get overall stats summary
  Future<Map<String, dynamic>> getStatsSummary() async {
    final response = await _apiService.get('/stats/summary');
    if (response['success'] == true) {
      return response['stats'];
    }
    throw Exception(response['message'] ?? 'Failed to get stats');
  }

  // Get all badges with earned status
  Future<Map<String, dynamic>> getBadges() async {
    final response = await _apiService.get('/stats/badges');
    if (response['success'] == true) {
      return {
        'badges': response['badges'] as List,
        'earnedCount': response['earnedCount'],
        'totalCount': response['totalCount'],
      };
    }
    throw Exception(response['message'] ?? 'Failed to get badges');
  }

  // Get streak calendar (last 30 days)
  Future<Map<String, dynamic>> getStreakCalendar() async {
    final response = await _apiService.get('/stats/calendar');
    if (response['success'] == true) {
      return {
        'calendar': response['calendar'] as List,
        'currentStreak': response['currentStreak'],
        'longestStreak': response['longestStreak'],
      };
    }
    throw Exception(response['message'] ?? 'Failed to get calendar');
  }

  // Update stats after study session
  Future<Map<String, dynamic>> updateStats({
    required int minutes,
    bool sessionCompleted = true,
  }) async {
    final response = await _apiService.post('/stats/update', {
      'minutes': minutes,
      'sessionCompleted': sessionCompleted,
    });
    if (response['success'] == true) {
      return {
        'stats': response['stats'],
        'newBadges': response['newBadges'] as List? ?? [],
        'message': response['message'],
      };
    }
    throw Exception(response['message'] ?? 'Failed to update stats');
  }
}
