import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'all'; // 'all', 'active', 'completed'

  List<Task> get tasks {
    if (_filter == 'active') {
      return _tasks.where((task) => !task.completed).toList();
    } else if (_filter == 'completed') {
      return _tasks.where((task) => task.completed).toList();
    }
    return _tasks;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createTask(Task task) async {
    // Optimistic Update
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticTask = task.copyWith(id: tempId);
    _tasks.insert(0, optimisticTask);
    notifyListeners();

    try {
      final newTask = await _taskService.createTask(task);
      // Replace temp task with real one
      final index = _tasks.indexWhere((t) => t.id == tempId);
      if (index != -1) {
        _tasks[index] = newTask;
        notifyListeners();
      }
    } catch (e) {
      // Revert on failure
      _tasks.removeWhere((t) => t.id == tempId);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(String id, Task task) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final originalTask = _tasks[index];

    // Optimistic Update
    _tasks[index] = task;
    notifyListeners();

    try {
      final updatedTask = await _taskService.updateTask(id, task);
      // Update with server response (in case of server-side changes)
      final newIndex = _tasks.indexWhere((t) => t.id == id);
      if (newIndex != -1) {
        _tasks[newIndex] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      // Revert on failure
      _tasks[index] = originalTask;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final originalTask = _tasks[index];

    // Optimistic Update
    _tasks.removeAt(index);
    notifyListeners();

    try {
      await _taskService.deleteTask(id);
    } catch (e) {
      // Revert on failure
      _tasks.insert(index, originalTask);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final originalTask = _tasks[index];
    final updatedTask = originalTask.copyWith(completed: !originalTask.completed);

    // Optimistic Update
    _tasks[index] = updatedTask;
    notifyListeners();

    try {
      final serverTask = await _taskService.toggleComplete(id);
      final newIndex = _tasks.indexWhere((t) => t.id == id);
      if (newIndex != -1) {
        _tasks[newIndex] = serverTask;
        notifyListeners();
      }
    } catch (e) {
      // Revert on failure
      _tasks[index] = originalTask;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
