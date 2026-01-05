import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../utils/date_helpers.dart';
import '../../models/study_session.dart';
import '../../services/session_service.dart';
import '../../providers/stats_provider.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  final SessionService _sessionService = SessionService();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();

  // Duration options in minutes
  static const List<int> _durationOptions = [15, 25, 45, 60, 90, 120];
  int _selectedDuration = 25; // Default pomodoro length

  Timer? _timer;
  int _seconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  DateTime? _startTime;

  @override
  void dispose() {
    _timer?.cancel();
    _subjectController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject')),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      if (_startTime == null) {
        _startTime = DateTime.now();
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _handleTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _seconds = _isBreak ? 5 * 60 : _selectedDuration * 60;
      _startTime = null;
    });
  }

  Future<void> _handleTimerComplete() async {
    _timer?.cancel();

    if (!_isBreak && _startTime != null) {
      final sessionDuration = _selectedDuration; // Use selected duration

      // Save study session
      try {
        await _sessionService.createSession(
          StudySession(
            subject: _subjectController.text,
            topic: _topicController.text.isNotEmpty ? _topicController.text : null,
            startTime: _startTime!,
            endTime: DateTime.now(),
            completed: true,
          ),
        );

        // Update stats for gamification
        final statsProvider = context.read<StatsProvider>();
        final newBadges = await statsProvider.updateStudyStats(
          minutes: sessionDuration,
          sessionCompleted: true,
        );

        // Show badge notification if earned new badges
        if (mounted && newBadges.isNotEmpty) {
          _showBadgeNotification(newBadges);
        }
      } catch (e) {
        debugPrint('Error saving session: $e');
      }
    }

    setState(() {
      _isRunning = false;
      _isBreak = !_isBreak;
      _seconds = _isBreak ? 5 * 60 : _selectedDuration * 60;
      _startTime = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBreak ? '🎉 Great work! Time for a break!' : 'Break over! Back to work!'),
          backgroundColor: _isBreak ? AppTheme.successColor : AppTheme.primaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showBadgeNotification(List<dynamic> newBadges) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 New Badge!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: newBadges.map<Widget>((badge) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(badge['icon'] ?? '🏆', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(badge['name'] ?? 'Badge', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(badge['description'] ?? '', style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            );
          }).toList(),
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
    final totalSeconds = _isBreak ? 5 * 60 : _selectedDuration * 60;
    final progress = 1 - (_seconds / totalSeconds);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isBreak ? 'Break Time' : 'Study Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Duration Selector
            if (!_isRunning && !_isBreak) ...[
              const Text('Select Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _durationOptions.map((mins) {
                  final isSelected = mins == _selectedDuration;
                  return ChoiceChip(
                    label: Text('$mins min'),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedDuration = mins;
                        _seconds = mins * 60;
                      });
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            // Timer Circle
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: AppTheme.borderColor,
                      valueColor: AlwaysStoppedAnimation(
                        _isBreak ? AppTheme.warningColor : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    DateHelpers.formatSeconds(_seconds),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Subject Input
            if (!_isBreak) ...[
              TextField(
                controller: _subjectController,
                enabled: !_isRunning,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g., Mathematics',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _topicController,
                enabled: !_isRunning,
                decoration: const InputDecoration(
                  labelText: 'Topic (optional)',
                  hintText: 'e.g., Calculus',
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
