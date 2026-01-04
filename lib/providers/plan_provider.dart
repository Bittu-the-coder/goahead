import 'package:flutter/foundation.dart';
import '../models/study_plan.dart';
import '../models/plan_template.dart';
import '../services/plan_service.dart';

class PlanProvider with ChangeNotifier {
  final PlanService _planService = PlanService();

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
        _activePlan = _plans.firstWhere(
          (plan) => plan.isActive && !plan.isExpired,
          orElse: () => _plans.first,
        );
        // Load today's tasks if there's an active plan
        if (_activePlan != null) {
          await _loadTodayTasks();
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

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
    } catch (e) {
      _error = e.toString();
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
