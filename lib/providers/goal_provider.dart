import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../services/goal_service.dart';

class GoalProvider with ChangeNotifier {
  final GoalService _goalService = GoalService();

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _goalService.getGoals();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createGoal(Goal goal) async {
    try {
      final newGoal = await _goalService.createGoal(goal);
      _goals.insert(0, newGoal);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGoal(String id, Goal goal) async {
    try {
      final updatedGoal = await _goalService.updateGoal(id, goal);
      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _goalService.deleteGoal(id);
      _goals.removeWhere((goal) => goal.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProgress(String id, int progress) async {
    try {
      final updatedGoal = await _goalService.updateProgress(id, progress);
      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    try {
      final updatedGoal = await _goalService.toggleMilestone(goalId, milestoneId);
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
