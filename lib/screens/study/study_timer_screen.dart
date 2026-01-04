import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../utils/date_helpers.dart';
import '../../models/study_session.dart';
import '../../services/session_service.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  final SessionService _sessionService = SessionService();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();

  Timer? _timer;
  int _seconds = AppConstants.pomodoroLength * 60;
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
      _seconds = _isBreak ? AppConstants.shortBreakLength * 60 : AppConstants.pomodoroLength * 60;
      _startTime = null;
    });
  }

  Future<void> _handleTimerComplete() async {
    _timer?.cancel();

    if (!_isBreak && _startTime != null) {
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
      } catch (e) {
        print('Error saving session: $e');
      }
    }

    setState(() {
      _isRunning = false;
      _isBreak = !_isBreak;
      _seconds = _isBreak ? AppConstants.shortBreakLength * 60 : AppConstants.pomodoroLength * 60;
      _startTime = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBreak ? 'Time for a break!' : 'Break over! Back to work!'),
          backgroundColor: _isBreak ? AppTheme.warningColor : AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_seconds / (_isBreak ? AppConstants.shortBreakLength * 60 : AppConstants.pomodoroLength * 60));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isBreak ? 'Break Time' : 'Study Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
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
