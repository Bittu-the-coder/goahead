import 'package:flutter/foundation.dart';
import '../models/study_plan.dart';
import '../models/plan_template.dart';
import '../services/plan_service.dart';
import '../services/notification_service.dart';
import '../services/alarm_service.dart';

class PlanProvider with ChangeNotifier {
  final PlanService _planService = PlanService();
  final NotificationService _notificationService = NotificationService();
  final AlarmService _alarmService = AlarmService();

  List<PlanTemplate> _templates = [];
  List<StudyPlan> _plans = [];
  StudyPlan? _activePlan;
  List<SubjectSlot> _todayTasks = [];
  bool _isLoading = false;
  String? _error;

  List<PlanTemplate> get templates => _templates;
  List<StudyPlan> get plans => _plans;
  StudyPlan? get activePlan => _activePlan;
  List<SubjectSlot> get todayTasks => _todayTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _templates = await _planService.getTemplates();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await _planService.getPlans();
      if (_plans.isNotEmpty) {
        // Only set active plan if there's one explicitly marked as active
        final activePlans = _plans.where((plan) => plan.isActive && !plan.isExpired).toList();
        if (activePlans.isNotEmpty) {
          _activePlan = activePlans.first;
          await _loadTodayTasks();
        } else {
          _activePlan = null; // No auto-selection for new users
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Switch to a different plan
  void setActivePlan(StudyPlan plan) {
    _activePlan = plan;
    _loadTodayTasks();
    notifyListeners();
  }

  // Get all user plans (for plan switcher)
  List<StudyPlan> get allPlans => _plans;

  Future<void> _loadTodayTasks() async {
    if (_activePlan == null) return;

    try {
      final today = DateTime.now();
      final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][today.weekday - 1];

      final todaySchedule = _activePlan!.weeklySchedule.firstWhere(
        (schedule) => schedule.day == dayName,
        orElse: () => _activePlan!.weeklySchedule.first,
      );

      _todayTasks = todaySchedule.subjects;

      // Schedule notifications for each upcoming task
      _scheduleTaskNotifications(_todayTasks);
    } catch (e) {
      _error = e.toString();
    }
  }

  void _scheduleTaskNotifications(List<SubjectSlot> tasks) {
    final now = DateTime.now();

    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      if (task.completed) continue;

      // Parse start time (format: "09:00" or "14:30")
      final timeParts = task.startTime.split(':');
      if (timeParts.length != 2) continue;

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

      // Only schedule if time is in the future
      if (scheduledTime.isAfter(now)) {
        _alarmService.scheduleTaskNotification(
          alarmId: 1000 + i, // Unique ID for task notifications
          taskName: task.name,
          scheduledTime: scheduledTime,
        );
      }
    }
  }

  Future<void> createPlanFromTemplate({
    required String templateId,
    required String name,
    required DateTime startDate,
    Map<String, dynamic>? customizations,
  }) async {
    try {
      final newPlan = await _planService.createPlan(
        templateId: templateId,
        name: name,
        startDate: startDate,
        customizations: customizations,
      );
      _plans.insert(0, newPlan);
      _activePlan = newPlan;
      await _loadTodayTasks();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createCustomPlan(Map<String, dynamic> planData) async {
    try {
      final newPlan = await _planService.createCustomPlan(planData);
      _plans.insert(0, newPlan);
      _activePlan = newPlan;
      await _loadTodayTasks();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePlan(String id, Map<String, dynamic> data) async {
    try {
      final updatedPlan = await _planService.updatePlan(id, data);
      final index = _plans.indexWhere((p) => p.id == id);
      if (index != -1) {
        _plans[index] = updatedPlan;
        if (_activePlan?.id == id) {
          _activePlan = updatedPlan;
          await _loadTodayTasks();
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      await _planService.deletePlan(id);
      _plans.removeWhere((plan) => plan.id == id);
      if (_activePlan?.id == id) {
        _activePlan = _plans.isNotEmpty ? _plans.first : null;
        _todayTasks = [];
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProgress(String id, int progress) async {
    try {
      final updatedPlan = await _planService.updateProgress(id, progress);
      final index = _plans.indexWhere((p) => p.id == id);
      if (index != -1) {
        _plans[index] = updatedPlan;
        if (_activePlan?.id == id) {
          _activePlan = updatedPlan;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Toggle subject completion
  Future<void> toggleSubjectCompletion({
    required String planId,
    required String day,
    required int subjectIndex,
    required bool completed,
  }) async {
    try {
      final updatedPlan = await _planService.toggleSubjectCompletion(
        planId: planId,
        day: day,
        subjectIndex: subjectIndex,
        completed: completed,
      );

      final index = _plans.indexWhere((p) => p.id == planId);
      if (index != -1) {
        _plans[index] = updatedPlan;
        if (_activePlan?.id == planId) {
          _activePlan = updatedPlan;
          await _loadTodayTasks();
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update day schedule
  Future<void> updateDaySchedule({
    required String planId,
    required String day,
    required List<Map<String, dynamic>> subjects,
  }) async {
    try {
      final updatedPlan = await _planService.updateDaySchedule(
        planId: planId,
        day: day,
        subjects: subjects,
      );

      final index = _plans.indexWhere((p) => p.id == planId);
      if (index != -1) {
        _plans[index] = updatedPlan;
        if (_activePlan?.id == planId) {
          _activePlan = updatedPlan;
          await _loadTodayTasks();
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
