import '../config/constants.dart';
import '../models/study_plan.dart';
import '../models/plan_template.dart';
import 'api_service.dart';

class PlanService {
  final ApiService _apiService = ApiService();

  // Get all templates
  Future<List<PlanTemplate>> getTemplates() async {
    final response = await _apiService.get('/plans/templates');
    if (response['success']) {
      return (response['templates'] as List)
          .map((json) => PlanTemplate.fromJson(json))
          .toList();
    }
    throw Exception(response['message'] ?? 'Failed to load templates');
  }

  // Get user's plans
  Future<List<StudyPlan>> getPlans() async {
    final response = await _apiService.get('/plans');
    if (response['success']) {
      return (response['plans'] as List)
          .map((json) => StudyPlan.fromJson(json))
          .toList();
    }
    throw Exception(response['message'] ?? 'Failed to load plans');
  }

  // Create plan from template
  Future<StudyPlan> createPlan({
    required String templateId,
    required String name,
    required DateTime startDate,
    Map<String, dynamic>? customizations,
  }) async {
    final response = await _apiService.post('/plans', {
      'templateId': templateId,
      'name': name,
      'startDate': startDate.toIso8601String(),
      if (customizations != null) 'customizations': customizations,
    });

    if (response['success']) {
      return StudyPlan.fromJson(response['plan']);
    }
    throw Exception(response['message'] ?? 'Failed to create plan');
  }

  // Update plan
  Future<StudyPlan> updatePlan(String planId, Map<String, dynamic> data) async {
    final response = await _apiService.put('/plans/$planId', data);
    if (response['success']) {
      return StudyPlan.fromJson(response['plan']);
    }
    throw Exception(response['message'] ?? 'Failed to update plan');
  }

  // Delete plan
  Future<void> deletePlan(String planId) async {
    final response = await _apiService.delete('/plans/$planId');
    if (!response['success']) {
      throw Exception(response['message'] ?? 'Failed to delete plan');
    }
  }

  // Update progress (manual)
  Future<StudyPlan> updateProgress(String planId, int progress) async {
    final response = await _apiService.patch('/plans/$planId/progress', {
      'progress': progress,
    });
    if (response['success']) {
      return StudyPlan.fromJson(response['plan']);
    }
    throw Exception(response['message'] ?? 'Failed to update progress');
  }

  // Toggle subject completion
  Future<StudyPlan> toggleSubjectCompletion({
    required String planId,
    required String day,
    required int subjectIndex,
    required bool completed,
  }) async {
    final response = await _apiService.patch('/plans/$planId/subject/complete', {
      'day': day,
      'subjectIndex': subjectIndex,
      'completed': completed,
    });
    if (response['success']) {
      return StudyPlan.fromJson(response['plan']);
    }
    throw Exception(response['message'] ?? 'Failed to toggle completion');
  }

  // Update day schedule
  Future<StudyPlan> updateDaySchedule({
    required String planId,
    required String day,
    required List<Map<String, dynamic>> subjects,
  }) async {
    final response = await _apiService.patch('/plans/$planId/schedule/$day', {
      'subjects': subjects,
    });
    if (response['success']) {
      return StudyPlan.fromJson(response['plan']);
    }
    throw Exception(response['message'] ?? 'Failed to update schedule');
  }

  // Get today's tasks
  Future<List<SubjectSlot>> getTodayTasks(String planId) async {
    try {
      final plan = await getPlans();
      final activePlan = plan.firstWhere((p) => p.id == planId);

      final today = DateTime.now();
      final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][today.weekday - 1];

      final todaySchedule = activePlan.weeklySchedule.firstWhere(
        (schedule) => schedule.day == dayName,
        orElse: () => activePlan.weeklySchedule.first,
      );

      return todaySchedule.subjects;
    } catch (e) {
      throw Exception('Failed to get today\'s tasks: $e');
    }
  }
}
