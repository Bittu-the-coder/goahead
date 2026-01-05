import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../config/theme.dart';
import '../../utils/date_helpers.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              context.read<TaskProvider>().setFilter(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Tasks')),
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = taskProvider.tasks;

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet. Tap + to create one!',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _TaskCard(task: task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, [Task? task]) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleController = TextEditingController(text: task?.title);
    final descController = TextEditingController(text: task?.description);
    String priority = task?.priority ?? 'medium';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: screenWidth * 0.9,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task == null ? 'New Task' : 'Edit Task',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) => priority = value!,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final newTask = Task(
                          id: task?.id,
                          title: titleController.text,
                          description: descController.text,
                          priority: priority,
                        );
                        if (task == null) {
                          context.read<TaskProvider>().createTask(newTask);
                        } else {
                          context.read<TaskProvider>().updateTask(task.id!, newTask);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(task == null ? 'Create' : 'Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'high':
        return AppTheme.errorColor;
      case 'medium':
        return AppTheme.warningColor;
      default:
        return AppTheme.infoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) {
            context.read<TaskProvider>().toggleComplete(task.id!);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? AppTheme.textMuted : AppTheme.textPrimary,
          ),
        ),
        subtitle: task.description != null
            ? Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getPriorityColor().withOpacity(0.3)),
              ),
              child: Text(
                task.priority.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getPriorityColor(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () {
                context.read<TaskProvider>().deleteTask(task.id!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
