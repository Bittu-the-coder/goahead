import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../config/theme.dart';
import '../../models/study_plan.dart';
import '../home/dashboard_screen.dart';

class CreateCustomPlanScreen extends StatefulWidget {
  const CreateCustomPlanScreen({super.key});

  @override
  State<CreateCustomPlanScreen> createState() => _CreateCustomPlanScreenState();
}

class _CreateCustomPlanScreenState extends State<CreateCustomPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int _currentStep = 0;

  // Schedule for each day
  final Map<String, List<Map<String, dynamic>>> _weeklySchedule = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  String _selectedDay = 'Monday';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addSubject(String day) {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        onSave: (subject) {
          setState(() {
            _weeklySchedule[day]!.add(subject);
          });
        },
      ),
    );
  }

  void _editSubject(String day, int index) {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        subject: _weeklySchedule[day]![index],
        onSave: (subject) {
          setState(() {
            _weeklySchedule[day]![index] = subject;
          });
        },
      ),
    );
  }

  void _deleteSubject(String day, int index) {
    setState(() {
      _weeklySchedule[day]!.removeAt(index);
    });
  }

  Future<void> _createPlan() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if at least one subject is added
    bool hasSubjects = _weeklySchedule.values.any((list) => list.isNotEmpty);
    if (!hasSubjects) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one subject to your schedule'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final planProvider = context.read<PlanProvider>();

    // Create plan data
    final planData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'templateType': 'Custom',
      'isCustom': true,
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate.toIso8601String(),
      'weeklySchedule': _days.map((day) => {
        'day': day,
        'subjects': _weeklySchedule[day],
        'totalHours': _weeklySchedule[day]!.fold<double>(0, (sum, s) => sum + (s['duration'] as int) / 60),
      }).toList(),
    };

    try {
      await planProvider.createCustomPlan(planData);

      if (mounted && planProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom plan created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
        title: const Text('Create Custom Plan'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _createPlan();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            // Step 1: Basic Info
            Step(
              title: const Text('Plan Details'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Plan Name *',
                      hintText: 'e.g., My Study Plan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Optional description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePicker(
                          label: 'Start Date',
                          date: _startDate,
                          onChanged: (date) => setState(() => _startDate = date),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DatePicker(
                          label: 'End Date',
                          date: _endDate,
                          onChanged: (date) => setState(() => _endDate = date),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Step 2: Weekly Schedule
            Step(
              title: const Text('Weekly Schedule'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  // Day selector
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      itemBuilder: (context, index) {
                        final day = _days[index];
                        final isSelected = day == _selectedDay;
                        final hasSubjects = _weeklySchedule[day]!.isNotEmpty;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(day.substring(0, 3)),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedDay = day),
                            avatar: hasSubjects ? const Icon(Icons.check, size: 16) : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subjects for selected day
                  ..._weeklySchedule[_selectedDay]!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final subject = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(subject['startTime'] ?? '09:00', style: const TextStyle(fontSize: 11)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(subject['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${subject['duration']} mins', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () => _editSubject(_selectedDay, index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                              onPressed: () => _deleteSubject(_selectedDay, index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _addSubject(_selectedDay),
                    icon: const Icon(Icons.add),
                    label: Text('Add Subject to $_selectedDay'),
                  ),
                ],
              ),
            ),
            // Step 3: Review
            Step(
              title: const Text('Review'),
              isActive: _currentStep >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan: ${_nameController.text}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Duration: ${_endDate.difference(_startDate).inDays} days'),
                  const SizedBox(height: 16),
                  const Text('Schedule Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._days.map((day) {
                    final subjects = _weeklySchedule[day]!;
                    final totalMins = subjects.fold<int>(0, (sum, s) => sum + (s['duration'] as int? ?? 0));
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(day),
                          Text('${subjects.length} subjects • ${(totalMins/60).toStringAsFixed(1)}h'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DatePicker({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Text('${date.day}/${date.month}/${date.year}'),
          ],
        ),
      ),
    );
  }
}

class _SubjectDialog extends StatefulWidget {
  final Map<String, dynamic>? subject;
  final Function(Map<String, dynamic>) onSave;

  const _SubjectDialog({this.subject, required this.onSave});

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  late TextEditingController _nameController;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _priority = 'medium';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?['name'] ?? '');

    // Parse existing times
    if (widget.subject?['startTime'] != null) {
      final parts = widget.subject!['startTime'].split(':');
      if (parts.length == 2) {
        _startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    if (widget.subject?['endTime'] != null) {
      final parts = widget.subject!['endTime'].split(':');
      if (parts.length == 2) {
        _endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    _priority = widget.subject?['priority'] ?? 'medium';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatTime24(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  int _calculateDuration() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    var duration = endMinutes - startMinutes;
    if (duration < 0) duration += 24 * 60; // Handle overnight
    return duration;
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = _calculateDuration();

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.subject == null ? 'Add Subject' : 'Edit Subject',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Subject Name *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text(_formatTime(_startTime), style: const TextStyle(fontSize: 13))),
                            const Icon(Icons.access_time, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text(_formatTime(_endTime), style: const TextStyle(fontSize: 13))),
                            const Icon(Icons.access_time, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text('Duration: $duration mins',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        )),
                  ],
                ),
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isEmpty) return;
                      widget.onSave({
                        'name': _nameController.text,
                        'startTime': _formatTime24(_startTime),
                        'endTime': _formatTime24(_endTime),
                        'duration': _calculateDuration(),
                        'priority': _priority,
                        'completed': false,
                      });
                      Navigator.pop(context);
                    },
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
