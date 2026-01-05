import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/stats_provider.dart';
import '../../config/theme.dart';
import '../../models/study_plan.dart';
import '../auth/login_screen.dart';
import '../tasks/tasks_screen.dart';
import '../study/study_timer_screen.dart';
import '../goals/goals_screen.dart';
import '../stats/stats_screen.dart';
import '../plans/plan_templates_screen.dart';
import '../plans/my_plan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  Widget _getScreen(int index, PlanProvider planProvider) {
    if (index == 5) {
      return planProvider.activePlan != null
          ? const MyPlanScreen()
          : const PlanTemplatesScreen();
    }

    final screens = [
      const DashboardHome(),
      const TasksScreen(),
      const StudyTimerScreen(),
      const GoalsScreen(),
      const StatsScreen(),
    ];
    return screens[index];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      context.read<GoalProvider>().loadGoals();
      context.read<PlanProvider>().loadPlans();
      context.read<StatsProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanProvider>(
      builder: (context, planProvider, _) {
        return Scaffold(
          body: _getScreen(_selectedIndex, planProvider),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textMuted,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_box_outlined),
                activeIcon: Icon(Icons.check_box),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined),
                activeIcon: Icon(Icons.timer),
                label: 'Study',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flag_outlined),
                activeIcon: Icon(Icons.flag),
                label: 'Goals',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Stats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'Plans',
              ),
            ],
          ),
        );
      },
    );
  }
}

// Enhanced Dashboard Home with Today's Tasks
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final planProvider = context.watch<PlanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            Text(
              'Welcome, ${authProvider.user?.name ?? "User"}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            taskProvider.loadTasks(),
            goalProvider.loadGoals(),
            planProvider.loadPlans(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Stats
              const Text(
                'Today\'s Progress',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTodayStats(taskProvider, planProvider),

              const SizedBox(height: 24),

              // Today's Study Tasks (from plan)
              if (planProvider.activePlan != null) ...[
                _buildTodayTasksWidget(context, planProvider),
                const SizedBox(height: 24),
              ],

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context),

              const SizedBox(height: 24),

              // Active Tasks
              _buildActiveTasksSection(taskProvider),

              const SizedBox(height: 24),

              // Active Goals
              _buildActiveGoalsSection(goalProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStats(TaskProvider taskProvider, PlanProvider planProvider) {
    final todayTasks = taskProvider.tasks.where((t) {
      if (t.createdAt == null) return false;
      return t.createdAt!.day == DateTime.now().day &&
          t.createdAt!.month == DateTime.now().month;
    }).toList();

    final todayCompletedTasks = todayTasks.where((t) => t.completed).length;

    final todayStudyTasks = planProvider.todayTasks;
    final todayCompletedStudy = todayStudyTasks.where((s) => s.completed).length;

    // Calculate study time
    final todayStudyMinutes = todayStudyTasks.fold<int>(0, (sum, task) => sum + task.duration);
    final todayStudyHours = (todayStudyMinutes / 60).toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tasks Today',
            '$todayCompletedTasks/${todayTasks.length}',
            Icons.check_circle_outline,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Study Time',
            '${todayStudyHours}h',
            Icons.timer_outlined,
            AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLifetimeStats(PlanProvider planProvider) {
    // Calculate lifetime study time from all plans
    final allPlans = planProvider.plans;
    int totalMinutes = 0;

    for (var plan in allPlans) {
      for (var day in plan.weeklySchedule) {
        for (var subject in day.subjects) {
          if (subject.completed) {
            totalMinutes += subject.duration;
          }
        }
      }
    }

    final lifetimeHours = (totalMinutes / 60).toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Lifetime Study',
            '${lifetimeHours}h',
            Icons.school_outlined,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active Plans',
            '${allPlans.where((p) => p.isActive).length}',
            Icons.assignment_outlined,
            AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTasksWidget(BuildContext context, PlanProvider planProvider) {
    final todayTasks = planProvider.todayTasks;
    final today = DateTime.now();
    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][today.weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.today, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Today\'s Study Schedule - $dayName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (todayTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_available, color: AppTheme.textMuted),
                SizedBox(width: 12),
                Text(
                  'No study sessions today. Take a rest!',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          )
        else
          ...todayTasks.take(3).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final subject = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: subject.completed
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: subject.completed
                      ? AppTheme.successColor.withOpacity(0.3)
                      : AppTheme.borderColor,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: subject.completed,
                    onChanged: (value) async {
                      try {
                        await planProvider.toggleSubjectCompletion(
                          planId: planProvider.activePlan!.id!,
                          day: dayName,
                          subjectIndex: todayTasks.indexOf(subject),
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
                        // Handle error
                      }
                    },
                    activeColor: AppTheme.successColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            decoration: subject.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${subject.startTime} - ${subject.endTime}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: subject.priority == 'high'
                                    ? AppTheme.errorColor.withOpacity(0.1)
                                    : AppTheme.warningColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                subject.priority.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: subject.priority == 'high'
                                      ? AppTheme.errorColor
                                      : AppTheme.warningColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (subject.completed)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                ],
              ),
            );
          }).toList(),
        if (todayTasks.length > 3)
          TextButton(
            onPressed: () {
              // Navigate to plans tab
            },
            child: const Text('View all sessions →'),
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Add Task',
            Icons.add_task,
            AppTheme.primaryColor,
            () {
              // Navigate to tasks tab (index 1)
              final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
              if (dashboardState != null) {
                dashboardState.setState(() {
                  dashboardState._selectedIndex = 1;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Start Timer',
            Icons.timer,
            AppTheme.secondaryColor,
            () {
              // Navigate to study timer tab (index 2)
              final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
              if (dashboardState != null) {
                dashboardState.setState(() {
                  dashboardState._selectedIndex = 2;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTasksSection(TaskProvider taskProvider) {
    final activeTasks = taskProvider.tasks.where((t) => !t.completed).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (activeTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No active tasks',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          )
        else
          ...activeTasks.map((task) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    task.priority == 'high' ? Icons.priority_high : Icons.circle,
                    color: task.priority == 'high' ? AppTheme.errorColor : AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildActiveGoalsSection(GoalProvider goalProvider) {
    final activeGoals = goalProvider.goals.where((g) => !g.completed).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Goals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (activeGoals.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No active goals',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          )
        else
          ...activeGoals.map((goal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.progress / 100,
                      minHeight: 6,
                      backgroundColor: AppTheme.borderColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${goal.progress}% complete',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}
