import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../config/theme.dart';
import '../../models/study_plan.dart';

class DayScheduleScreen extends StatefulWidget {
  final String planId;
  final String day;
  final List<SubjectSlot> subjects;

  const DayScheduleScreen({
    super.key,
    required this.planId,
    required this.day,
    required this.subjects,
  });

  @override
  State<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends State<DayScheduleScreen> {
  late List<SubjectSlot> _subjects;

  @override
  void initState() {
    super.initState();
    _subjects = List.from(widget.subjects);
  }

  void _addSubject() {
    showDialog(
      context: context,
      builder: (context) => _SubjectFormDialog(
        onSave: (subject) {
          setState(() {
            _subjects.add(subject);
          });
        },
      ),
    );
  }

  void _editSubject(int index) {
    showDialog(
      context: context,
      builder: (context) => _SubjectFormDialog(
        subject: _subjects[index],
        onSave: (subject) {
          setState(() {
            _subjects[index] = subject;
          });
        },
      ),
    );
  }

  void _deleteSubject(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${_subjects[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _subjects.removeAt(index);
              });
              Navigator.pop(context);
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

  Future<void> _saveSchedule() async {
    try {
      final planProvider = context.read<PlanProvider>();
      await planProvider.updateDaySchedule(
        planId: widget.planId,
        day: widget.day,
        subjects: _subjects.map((s) => s.toJson()).toList(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.day} Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSubject,
            tooltip: 'Add Subject',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSchedule,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: _subjects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_busy,
                    size: 64,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No subjects scheduled',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _subjects.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex--;
                  }
                  final subject = _subjects.removeAt(oldIndex);
                  _subjects.insert(newIndex, subject);
                });
              },
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                return Card(
                  key: ValueKey(subject.name + index.toString()),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Time
                        Container(
                          width: 50,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                subject.startTime,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const Text('→', style: TextStyle(fontSize: 8)),
                              Text(
                                subject.endTime,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Subject details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${subject.duration} mins',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                        // Actions
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _editSubject(index),
                          color: AppTheme.primaryColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _deleteSubject(index),
                          color: AppTheme.errorColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _SubjectFormDialog extends StatefulWidget {
  final SubjectSlot? subject;
  final Function(SubjectSlot) onSave;

  const _SubjectFormDialog({
    this.subject,
    required this.onSave,
  });

  @override
  State<_SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<_SubjectFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _durationController;
  late TextEditingController _topicsController;
  String _priority = 'medium';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _startTimeController = TextEditingController(text: widget.subject?.startTime ?? '09:00');
    _endTimeController = TextEditingController(text: widget.subject?.endTime ?? '10:00');
    _durationController = TextEditingController(text: widget.subject?.duration.toString() ?? '60');
    _topicsController = TextEditingController(
      text: widget.subject?.topics?.join(', ') ?? '',
    );
    _priority = widget.subject?.priority ?? 'medium';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _durationController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter subject name'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final subject = SubjectSlot(
      name: _nameController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      duration: int.tryParse(_durationController.text) ?? 60,
      topics: _topicsController.text.isNotEmpty
          ? _topicsController.text.split(',').map((e) => e.trim()).toList()
          : null,
      priority: _priority,
      completed: widget.subject?.completed ?? false,
      completedDate: widget.subject?.completedDate,
    );

    widget.onSave(subject);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      child: Container(
        width: screenWidth * 0.9, // 90% width for larger modal
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subject == null ? 'Add Subject' : 'Edit Subject',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                        hintText: '09:00',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                        hintText: '10:00',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _topicsController,
                decoration: const InputDecoration(
                  labelText: 'Topics (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'Topic 1, Topic 2, Topic 3',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
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
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
