import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/timer_provider.dart';
import '../../providers/stats_provider.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for session completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().addListener(_checkSessionComplete);
    });
  }

  @override
  void dispose() {
    // Note: Provider listener is automatically cleaned up
    super.dispose();
  }

  void _checkSessionComplete() async {
    final timerProvider = context.read<TimerProvider>();
    if (timerProvider.sessionJustCompleted && timerProvider.lastCompletedMinutes > 0) {
      // Save the minutes before clearing
      final completedMinutes = timerProvider.lastCompletedMinutes;

      try {
        // Update stats with the completed minutes
        final newBadges = await context.read<StatsProvider>().updateStudyStats(
          minutes: completedMinutes,
        );

        // Clear the flag
        timerProvider.clearSessionCompleted();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $completedMinutes minutes logged!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Show badge notification if earned
        if (newBadges.isNotEmpty && mounted) {
          _showBadgeDialog(newBadges);
        }
      } catch (e) {
        timerProvider.clearSessionCompleted();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Stats update failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showBadgeDialog(List<dynamic> badges) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🎉 '),
            Text('New Badge!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: badges.map((badge) => ListTile(
            leading: Text(badge['icon'] ?? '🏆', style: const TextStyle(fontSize: 32)),
            title: Text(badge['name'] ?? 'Badge'),
            subtitle: Text(badge['description'] ?? ''),
          )).toList(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(timerProvider.isBreak ? 'Break Time' : 'Study Timer'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Subject Input
                if (!timerProvider.isRunning && timerProvider.subject.isEmpty)
                  _buildSubjectInput(context, timerProvider),

                // Current Subject Display
                if (timerProvider.subject.isNotEmpty)
                  _buildCurrentSubject(timerProvider),

                const SizedBox(height: 32),

                // Duration Selector (only when not running)
                if (!timerProvider.isRunning && !timerProvider.isBreak)
                  _buildDurationSelector(timerProvider),

                const SizedBox(height: 32),

                // Timer Display
                _buildTimerDisplay(timerProvider),

                const SizedBox(height: 48),

                // Control Buttons
                _buildControlButtons(context, timerProvider),

                // Skip break button (shows only during break)
                _buildBreakControls(timerProvider),

                const SizedBox(height: 24),

                // Status indicator
                if (timerProvider.isRunning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.successColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Timer running in notification bar',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectInput(BuildContext context, TimerProvider timerProvider) {
    final subjectController = TextEditingController();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What are you studying?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                hintText: 'e.g. Mathematics',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  timerProvider.setSubject(value);
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (subjectController.text.isNotEmpty) {
                    timerProvider.setSubject(subjectController.text);
                  }
                },
                child: const Text('Set Subject'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubject(TimerProvider timerProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(
            timerProvider.isBreak ? Icons.coffee : Icons.book,
            color: timerProvider.isBreak ? AppTheme.warningColor : AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              timerProvider.isBreak ? 'Break Time' : timerProvider.subject,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!timerProvider.isRunning)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                timerProvider.setSubject('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector(TimerProvider timerProvider) {
    final customController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session Duration',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...TimerProvider.durationOptions.map((duration) {
              final isSelected = timerProvider.selectedDuration == duration;
              return ChoiceChip(
                label: Text('$duration min'),
                selected: isSelected,
                onSelected: (_) => timerProvider.setDuration(duration),
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              );
            }),
            // Custom duration chip
            ActionChip(
              label: const Text('Custom'),
              onPressed: () => _showCustomDurationDialog(timerProvider),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomDurationDialog(TimerProvider timerProvider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom Duration'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            hintText: 'Enter duration in minutes',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final mins = int.tryParse(controller.text);
              if (mins != null && mins > 0 && mins <= 180) {
                timerProvider.setDuration(mins);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakControls(TimerProvider timerProvider) {
    if (!timerProvider.isBreak) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: OutlinedButton.icon(
        onPressed: timerProvider.skipBreak,
        icon: const Icon(Icons.skip_next),
        label: const Text('Skip Break'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.warningColor,
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(TimerProvider timerProvider) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: CircularProgressIndicator(
            value: timerProvider.progress,
            strokeWidth: 12,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              timerProvider.isBreak ? AppTheme.secondaryColor : AppTheme.primaryColor,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timerProvider.formattedTime,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              timerProvider.isBreak ? 'Break' : 'Focus',
              style: TextStyle(
                fontSize: 16,
                color: timerProvider.isBreak
                    ? AppTheme.secondaryColor
                    : AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context, TimerProvider timerProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset Button
        IconButton(
          onPressed: timerProvider.subject.isNotEmpty ? timerProvider.resetTimer : null,
          icon: const Icon(Icons.refresh),
          iconSize: 32,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 24),
        // Play/Pause Button
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: timerProvider.isBreak
                  ? [AppTheme.secondaryColor, AppTheme.secondaryColor.withOpacity(0.7)]
                  : [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: (timerProvider.isBreak ? AppTheme.secondaryColor : AppTheme.primaryColor)
                    .withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            onPressed: timerProvider.subject.isEmpty
                ? null
                : (timerProvider.isRunning
                    ? timerProvider.pauseTimer
                    : timerProvider.startTimer),
            icon: Icon(
              timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 48,
            padding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(width: 24),
        // Stop Button (complete session early)
        IconButton(
          onPressed: timerProvider.isRunning
              ? () => _completeSession(context, timerProvider)
              : null,
          icon: const Icon(Icons.stop),
          iconSize: 32,
          color: AppTheme.errorColor,
        ),
      ],
    );
  }

  void _completeSession(BuildContext context, TimerProvider timerProvider) async {
    if (timerProvider.minutesStudied > 0 && !timerProvider.isBreak) {
      // Update stats
      await context.read<StatsProvider>().updateStudyStats(minutes: timerProvider.minutesStudied);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session completed! ${timerProvider.minutesStudied} minutes logged.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
    timerProvider.resetTimer();
  }
}
