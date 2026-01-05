import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/stats_provider.dart';
import '../../services/api_service.dart';

class StudyGoalsScreen extends StatefulWidget {
  const StudyGoalsScreen({super.key});

  @override
  State<StudyGoalsScreen> createState() => _StudyGoalsScreenState();
}

class _StudyGoalsScreenState extends State<StudyGoalsScreen> {
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final statsProvider = context.read<StatsProvider>();
    _dailyController.text = (statsProvider.dailyGoal ~/ 60).toString();
    _weeklyController.text = (statsProvider.weeklyGoal ~/ 60).toString();
  }

  @override
  void dispose() {
    _dailyController.dispose();
    _weeklyController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    final dailyHours = int.tryParse(_dailyController.text) ?? 4;
    final weeklyHours = int.tryParse(_weeklyController.text) ?? 10;

    setState(() => _isLoading = true);

    try {
      await ApiService().post('/stats/preferences', {
        'dailyGoal': dailyHours * 60, // Convert to minutes
        'weeklyGoal': weeklyHours * 60,
      });

      // Reload stats to reflect new goals
      await context.read<StatsProvider>().loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Study goals updated!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Goals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Your Study Targets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your daily and weekly study goals to track your progress.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),

            // Daily Goal
            _buildGoalInput(
              controller: _dailyController,
              label: 'Daily Goal',
              hint: 'Hours per day',
              icon: Icons.today,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),

            // Weekly Goal
            _buildGoalInput(
              controller: _weeklyController,
              label: 'Weekly Goal',
              hint: 'Hours per week',
              icon: Icons.calendar_month,
              color: AppTheme.secondaryColor,
            ),

            const SizedBox(height: 16),
            Text(
              'Tip: These goals will be used to calculate your progress rings on the Stats page.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveGoals,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Goals'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: hint,
                    suffixText: 'hours',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
