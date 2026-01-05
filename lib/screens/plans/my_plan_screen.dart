import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../config/theme.dart';
import '../../utils/date_helpers.dart';
import '../../widgets/gradient_card.dart';
import 'plan_templates_screen.dart';
import 'day_schedule_screen.dart';
import 'plan_editor_screen.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadPlans();
    });
  }

  void _showDeleteDialog(BuildContext context, PlanProvider planProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text('Are you sure you want to delete this study plan? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await planProvider.deletePlan(planProvider.activePlan!.id!);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plan deleted successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanProvider>(
      builder: (context, planProvider, _) {
        final allPlans = planProvider.allPlans;
        final activePlan = planProvider.activePlan;

        return Scaffold(
          appBar: AppBar(
            title: allPlans.length > 1
                ? DropdownButton<String>(
                    value: activePlan?.id,
                    underline: const SizedBox(),
                    dropdownColor: AppTheme.surfaceColor,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: allPlans.map((plan) {
                      return DropdownMenuItem(
                        value: plan.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              plan.name.length > 15 ? '${plan.name.substring(0, 15)}...' : plan.name,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${plan.progress.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 10, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (id) {
                      final plan = allPlans.firstWhere((p) => p.id == id);
                      planProvider.setActivePlan(plan);
                    },
                  )
                : const Text('My Study Plan'),
            actions: [
              // Add another plan button
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add New Plan',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlanTemplatesScreen()),
                  );
                },
              ),
              if (activePlan != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteDialog(context, planProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppTheme.errorColor),
                          SizedBox(width: 8),
                          Text('Delete Plan'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: _buildBody(context, planProvider),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PlanProvider planProvider) {
    if (planProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activePlan = planProvider.activePlan;

    if (activePlan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No active study plan',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a plan from templates to get started',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Get today's schedule
    final today = DateTime.now();
    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][today.weekday - 1];
    final todaySchedule = activePlan.weeklySchedule.firstWhere(
      (schedule) => schedule.day == dayName,
      orElse: () => activePlan.weeklySchedule.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Header
          GradientCard(
            colors: [
              AppTheme.primaryColor.withOpacity(0.2),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activePlan.templateType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (!activePlan.isExpired)
                      Text(
                        '${activePlan.daysRemaining} days left',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  activePlan.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (activePlan.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    activePlan.description!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      '${DateHelpers.formatDate(activePlan.startDate)} - ${DateHelpers.formatDate(activePlan.endDate)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress Bar (Auto-calculated)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${activePlan.progress}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: activePlan.progress / 100,
                        minHeight: 12,
                        backgroundColor: AppTheme.borderColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Auto-calculated from completed tasks',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Schedule
          Row(
            children: [
              const Icon(Icons.today, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Today\'s Schedule - $dayName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (todaySchedule.subjects.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No classes scheduled for today. Take a rest!',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ...todaySchedule.subjects.asMap().entries.map((entry) {
              final index = entry.key;
              final subject = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Checkbox
                      Checkbox(
                        value: subject.completed,
                        onChanged: (value) async {
                          try {
                            await planProvider.toggleSubjectCompletion(
                              planId: activePlan.id!,
                              day: dayName,
                              subjectIndex: index,
                              completed: value ?? false,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value! ? 'Task completed! 🎉' : 'Task unmarked'),
                                  backgroundColor: value ? AppTheme.successColor : AppTheme.warningColor,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          }
                        },
                        activeColor: AppTheme.successColor,
                      ),
                      const SizedBox(width: 8),
                      // Time
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: subject.completed
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              subject.startTime,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: subject.completed ? AppTheme.successColor : AppTheme.primaryColor,
                                decoration: subject.completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const Text(
                              'to',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            Text(
                              subject.endTime,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: subject.completed ? AppTheme.successColor : AppTheme.primaryColor,
                                decoration: subject.completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Subject Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                decoration: subject.completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (subject.topics != null && subject.topics!.isNotEmpty)
                              Text(
                                subject.topics!.join(', '),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${subject.duration} mins',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: subject.priority == 'high'
                                        ? AppTheme.errorColor.withOpacity(0.1)
                                        : AppTheme.warningColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    subject.priority.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: subject.priority == 'high'
                                          ? AppTheme.errorColor
                                          : AppTheme.warningColor,
                                    ),
                                  ),
                                ),
                                if (subject.completed) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: AppTheme.successColor,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

          const SizedBox(height: 24),

          // Weekly Overview
          Row(
            children: [
              const Icon(Icons.view_week, color: AppTheme.secondaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlanEditorScreen(plan: activePlan),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Plan'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...activePlan.weeklySchedule.map((daySchedule) {
            final isToday = daySchedule.day == dayName;
            final completedCount = daySchedule.subjects.where((s) => s.completed).length;
            final totalCount = daySchedule.subjects.length;
            final dayProgress = totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;

            return Card(
              color: isToday ? AppTheme.primaryColor.withOpacity(0.05) : null,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DayScheduleScreen(
                        planId: activePlan.id!,
                        day: daySchedule.day,
                        subjects: daySchedule.subjects,
                      ),
                    ),
                  );
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppTheme.primaryColor
                        : AppTheme.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      daySchedule.day.substring(0, 3),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  daySchedule.day,
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalCount sessions • ${daySchedule.totalHours.toStringAsFixed(1)}h',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: dayProgress / 100,
                              minHeight: 4,
                              backgroundColor: AppTheme.borderColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                dayProgress == 100 ? AppTheme.successColor : AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$completedCount/$totalCount',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isToday ? AppTheme.primaryColor : AppTheme.textMuted,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
