import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../config/theme.dart';
import '../../models/study_plan.dart';

class PlanEditorScreen extends StatefulWidget {
  final StudyPlan plan;

  const PlanEditorScreen({super.key, required this.plan});

  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<DaySchedule> _weeklySchedule;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    // Deep copy the schedule
    _weeklySchedule = widget.plan.weeklySchedule.map((day) => DaySchedule(
      day: day.day,
      subjects: day.subjects.map((s) => SubjectSlot(
        name: s.name,
        startTime: s.startTime,
        endTime: s.endTime,
        duration: s.duration,
        topics: s.topics,
        priority: s.priority,
        completed: s.completed,
        completedDate: s.completedDate,
      )).toList(),
      totalHours: day.totalHours,
    )).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addSubject(int dayIndex) {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        onSave: (subject) {
          setState(() {
            _weeklySchedule[dayIndex].subjects.add(subject);
            _hasChanges = true;
          });
        },
      ),
    );
  }

  void _editSubject(int dayIndex, int subjectIndex) {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        subject: _weeklySchedule[dayIndex].subjects[subjectIndex],
        onSave: (subject) {
          setState(() {
            _weeklySchedule[dayIndex].subjects[subjectIndex] = subject;
            _hasChanges = true;
          });
        },
      ),
    );
  }

  void _deleteSubject(int dayIndex, int subjectIndex) {
    setState(() {
      _weeklySchedule[dayIndex].subjects.removeAt(subjectIndex);
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    final planProvider = context.read<PlanProvider>();

    try {
      final scheduleData = _weeklySchedule.map((day) => {
        'day': day.day,
        'subjects': day.subjects.map((s) => {
          'name': s.name,
          'startTime': s.startTime,
          'endTime': s.endTime,
          'duration': s.duration,
          'topics': s.topics,
          'priority': s.priority,
          'completed': s.completed,
        }).toList(),
      }).toList();

      await planProvider.updatePlan(widget.plan.id!, {'weeklySchedule': scheduleData});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan saved successfully!'), backgroundColor: AppTheme.successColor),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.plan.name}'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _days.map((day) {
            final daySchedule = _weeklySchedule.firstWhere((d) => d.day == day);
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(day.substring(0, 3)),
                  if (daySchedule.subjects.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${daySchedule.subjects.length}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.asMap().entries.map((entry) {
          final dayIndex = entry.key;
          final day = entry.value;
          final daySchedule = _weeklySchedule.firstWhere((d) => d.day == day);

          return _buildDayEditor(dayIndex, daySchedule);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSubject(_tabController.index),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDayEditor(int dayIndex, DaySchedule daySchedule) {
    if (daySchedule.subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No subjects for ${daySchedule.day}', style: TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _addSubject(dayIndex),
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daySchedule.subjects.length,
      itemBuilder: (context, index) {
        final subject = daySchedule.subjects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Time badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subject.startTime,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                // Subject info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${subject.duration} mins • ${subject.priority}', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                // Actions
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _editSubject(dayIndex, index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                  onPressed: () => _deleteSubject(dayIndex, index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubjectDialog extends StatefulWidget {
  final SubjectSlot? subject;
  final Function(SubjectSlot) onSave;

  const _SubjectDialog({this.subject, required this.onSave});

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _durationController;
  String _priority = 'medium';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _startTimeController = TextEditingController(text: widget.subject?.startTime ?? '09:00');
    _endTimeController = TextEditingController(text: widget.subject?.endTime ?? '10:00');
    _durationController = TextEditingController(text: (widget.subject?.duration ?? 60).toString());
    _priority = widget.subject?.priority ?? 'medium';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.subject == null ? 'Add Subject' : 'Edit Subject', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Subject Name *', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextField(controller: _startTimeController, decoration: const InputDecoration(labelText: 'Start', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _endTimeController, decoration: const InputDecoration(labelText: 'End', border: OutlineInputBorder()))),
              ]),
              const SizedBox(height: 16),
              TextField(controller: _durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (mins)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty) return;
                    widget.onSave(SubjectSlot(
                      name: _nameController.text,
                      startTime: _startTimeController.text,
                      endTime: _endTimeController.text,
                      duration: int.tryParse(_durationController.text) ?? 60,
                      priority: _priority,
                      completed: widget.subject?.completed ?? false,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
