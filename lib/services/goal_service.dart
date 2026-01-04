import '../models/goal.dart';
import 'api_service.dart';

class GoalService {
  final ApiService _api = ApiService();

  Future<List<Goal>> getGoals({
    String? category,
    bool? completed,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (completed != null) queryParams['completed'] = completed.toString();

    final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    final endpoint = '/goals${query.isNotEmpty ? '?$query' : ''}';

    final response = await _api.get(endpoint);
    if (response['success']) {
      final goals = (response['goals'] as List)
          .map((goal) => Goal.fromJson(goal))
          .toList();
      return goals;
    }
    return [];
  }

  Future<Goal?> getGoal(String id) async {
    final response = await _api.get('/goals/$id');
    if (response['success']) {
      return Goal.fromJson(response['goal']);
    }
    return null;
  }

  Future<Goal> createGoal(Goal goal) async {
    final response = await _api.post('/goals', goal.toJson());
    return Goal.fromJson(response['goal']);
  }

  Future<Goal> updateGoal(String id, Goal goal) async {
    final response = await _api.put('/goals/$id', goal.toJson());
    return Goal.fromJson(response['goal']);
  }

  Future<void> deleteGoal(String id) async {
    await _api.delete('/goals/$id');
  }

  Future<Goal> updateProgress(String id, int progress) async {
    final response = await _api.patch('/goals/$id/progress', {'progress': progress});
    return Goal.fromJson(response['goal']);
  }

  Future<Goal> toggleMilestone(String goalId, String milestoneId) async {
    final response = await _api.patch('/goals/$goalId/milestones/$milestoneId');
    return Goal.fromJson(response['goal']);
  }
}
