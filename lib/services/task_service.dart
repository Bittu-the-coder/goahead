import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _api = ApiService();

  Future<List<Task>> getTasks({
    String? status,
    String? priority,
    String? category,
    bool? completed,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (priority != null) queryParams['priority'] = priority;
    if (category != null) queryParams['category'] = category;
    if (completed != null) queryParams['completed'] = completed.toString();

    final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    final endpoint = '/tasks${query.isNotEmpty ? '?$query' : ''}';

    final response = await _api.get(endpoint);
    if (response['success']) {
      final tasks = (response['tasks'] as List)
          .map((task) => Task.fromJson(task))
          .toList();
      return tasks;
    }
    return [];
  }

  Future<Task?> getTask(String id) async {
    final response = await _api.get('/tasks/$id');
    if (response['success']) {
      return Task.fromJson(response['task']);
    }
    return null;
  }

  Future<Task> createTask(Task task) async {
    final response = await _api.post('/tasks', task.toJson());
    return Task.fromJson(response['task']);
  }

  Future<Task> updateTask(String id, Task task) async {
    final response = await _api.put('/tasks/$id', task.toJson());
    return Task.fromJson(response['task']);
  }

  Future<void> deleteTask(String id) async {
    await _api.delete('/tasks/$id');
  }

  Future<Task> toggleComplete(String id) async {
    final response = await _api.patch('/tasks/$id/complete');
    return Task.fromJson(response['task']);
  }
}
