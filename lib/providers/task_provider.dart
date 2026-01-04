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
    try {
      final newTask = await _taskService.createTask(task);
      _tasks.insert(0, newTask);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(String id, Task task) async {
    try {
      final updatedTask = await _taskService.updateTask(id, task);
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _taskService.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String id) async {
    try {
      final updatedTask = await _taskService.toggleComplete(id);
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
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
