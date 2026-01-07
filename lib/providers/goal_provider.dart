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
    // Optimistic Update
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticGoal = goal.copyWith(id: tempId);
    _goals.insert(0, optimisticGoal);
    notifyListeners();

    try {
      final newGoal = await _goalService.createGoal(goal);
      // Replace temp with real
      final index = _goals.indexWhere((g) => g.id == tempId);
      if (index != -1) {
        _goals[index] = newGoal;
        notifyListeners();
      }
    } catch (e) {
      // Revert
      _goals.removeWhere((g) => g.id == tempId);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGoal(String id, Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final originalGoal = _goals[index];

    // Optimistic Update
    _goals[index] = goal;
    notifyListeners();

    try {
      final updatedGoal = await _goalService.updateGoal(id, goal);
      final newIndex = _goals.indexWhere((g) => g.id == id);
      if (newIndex != -1) {
        _goals[newIndex] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      // Revert
      _goals[index] = originalGoal;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final originalGoal = _goals[index];

    // Optimistic Update
    _goals.removeAt(index);
    notifyListeners();

    try {
      await _goalService.deleteGoal(id);
    } catch (e) {
      // Revert
      _goals.insert(index, originalGoal);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProgress(String id, int progress) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final originalGoal = _goals[index];
    final optimisticGoal = originalGoal.copyWith(progress: progress);

    // Optimistic Update
    _goals[index] = optimisticGoal;
    notifyListeners();

    try {
      final updatedGoal = await _goalService.updateProgress(id, progress);
      final newIndex = _goals.indexWhere((g) => g.id == id);
      if (newIndex != -1) {
        _goals[newIndex] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      // Revert
      _goals[index] = originalGoal;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final originalGoal = _goals[index];

    // We can't easily create an optimistic milestone update without knowing internal structure
    // So we'll just update after server response for complex nested objects

    try {
      final updatedGoal = await _goalService.toggleMilestone(goalId, milestoneId);
      final newIndex = _goals.indexWhere((g) => g.id == goalId);
      if (newIndex != -1) {
        _goals[newIndex] = updatedGoal;
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
