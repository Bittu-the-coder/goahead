import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/goal_provider.dart';
import '../../models/goal.dart';
import '../../config/theme.dart';
import '../../utils/date_helpers.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, _) {
          if (goalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = goalProvider.goals;

          if (goals.isEmpty) {
            return const Center(
              child: Text(
                'No goals yet. Tap + to create one!',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _GoalCard(goal: goal);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, [Goal? goal]) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleController = TextEditingController(text: goal?.title);
    final descController = TextEditingController(text: goal?.description);
    String category = goal?.category ?? 'custom';
    DateTime targetDate = goal?.targetDate ?? DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: screenWidth * 0.9, // 90% width
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal == null ? 'New Goal' : 'Edit Goal',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'exam', child: Text('Exam')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom')),
                  ],
                  onChanged: (value) => category = value!,
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
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a title'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }

                        final newGoal = Goal(
                          id: goal?.id,
                          title: titleController.text,
                          description: descController.text.isEmpty ? null : descController.text,
                          category: category,
                          targetDate: targetDate,
                          progress: goal?.progress ?? 0,
                        );

                        if (goal == null) {
                          context.read<GoalProvider>().createGoal(newGoal);
                        } else {
                          context.read<GoalProvider>().updateGoal(goal.id!, newGoal);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(goal == null ? 'Create' : 'Update'),
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

class _GoalCard extends StatelessWidget {
  final Goal goal;

  const _GoalCard({required this.goal});

  Color _getCategoryColor() {
    switch (goal.category) {
      case 'daily':
        return AppTheme.infoColor;
      case 'weekly':
        return AppTheme.warningColor;
      case 'monthly':
        return AppTheme.secondaryColor;
      case 'exam':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  void _showProgressDialog(BuildContext context) {
    double currentProgress = goal.progress.toDouble();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Progress'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentProgress.toInt()}%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: currentProgress,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${currentProgress.toInt()}%',
                  onChanged: (value) {
                    setState(() {
                      currentProgress = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Slide to update your goal progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedGoal = Goal(
                    id: goal.id,
                    title: goal.title,
                    description: goal.description,
                    category: goal.category,
                    targetDate: goal.targetDate,
                    progress: currentProgress.toInt(),
                  );

                  await context.read<GoalProvider>().updateGoal(goal.id!, updatedGoal);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Progress updated!'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getCategoryColor().withOpacity(0.3)),
                  ),
                  child: Text(
                    goal.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(),
                    ),
                  ),
                ),
              ],
            ),
            if (goal.description != null) ...[
              const SizedBox(height: 8),
              Text(
                goal.description!,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            // Progress with tap to edit
            InkWell(
              onTap: () => _showProgressDialog(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${goal.progress}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.progress / 100,
                      minHeight: 8,
                      backgroundColor: AppTheme.borderColor,
                      valueColor: AlwaysStoppedAnimation(
                        goal.completed ? AppTheme.successColor : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to update progress',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target: ${DateHelpers.formatDate(goal.targetDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: goal.isOverdue ? AppTheme.errorColor : AppTheme.textMuted,
                  ),
                ),
                if (!goal.completed)
                  Text(
                    goal.isOverdue ? 'Overdue' : '${goal.daysLeft} days left',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: goal.isOverdue ? AppTheme.errorColor : AppTheme.textMuted,
                    ),
                  ),
                if (goal.completed)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
