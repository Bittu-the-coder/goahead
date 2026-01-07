class DaySchedule {
  final String day;
  final List<SubjectSlot> subjects;
  final double totalHours;
  final int breakTime;

  DaySchedule({
    required this.day,
    required this.subjects,
    this.totalHours = 0,
    this.breakTime = 0,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      day: json['day'] ?? '',
      subjects: json['subjects'] != null
          ? (json['subjects'] as List).map((s) => SubjectSlot.fromJson(s)).toList()
          : [],
      totalHours: (json['totalHours'] ?? 0).toDouble(),
      breakTime: json['breakTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'totalHours': totalHours,
      'breakTime': breakTime,
    };
  }
}

class SubjectSlot {
  final String name;
  final String startTime;
  final String endTime;
  final int duration;
  final List<String>? topics;
  final String priority;
  final bool completed;
  final DateTime? completedDate;

  SubjectSlot({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.topics,
    this.priority = 'medium',
    this.completed = false,
    this.completedDate,
  });

  factory SubjectSlot.fromJson(Map<String, dynamic> json) {
    return SubjectSlot(
      name: json['name'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      duration: json['duration'] ?? 0,
      topics: json['topics'] != null ? List<String>.from(json['topics']) : null,
      priority: json['priority'] ?? 'medium',
      completed: json['completed'] ?? false,
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      if (topics != null) 'topics': topics,
      'priority': priority,
      'completed': completed,
      if (completedDate != null) 'completedDate': completedDate!.toIso8601String(),
    };
  }
}

class StudyPlan {
  final String? id;
  final String name;
  final String templateType;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<DaySchedule> weeklySchedule;
  final int? totalWeeks;
  final bool isActive;
  final int progress;
  final Map<String, dynamic>? customizations;
  final DateTime? createdAt;

  StudyPlan({
    this.id,
    required this.name,
    required this.templateType,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.weeklySchedule,
    this.totalWeeks,
    this.isActive = true,
    this.progress = 0,
    this.customizations,
    this.createdAt,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      templateType: json['templateType'] ?? 'Custom',
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      weeklySchedule: json['weeklySchedule'] != null
          ? (json['weeklySchedule'] as List).map((d) => DaySchedule.fromJson(d)).toList()
          : [],
      totalWeeks: json['totalWeeks'],
      isActive: json['isActive'] ?? true,
      progress: json['progress'] ?? 0,
      customizations: json['customizations'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'templateType': templateType,
      if (description != null) 'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'weeklySchedule': weeklySchedule.map((d) => d.toJson()).toList(),
      if (totalWeeks != null) 'totalWeeks': totalWeeks,
      'isActive': isActive,
      'progress': progress,
      if (customizations != null) 'customizations': customizations,
    };
  }

  int get daysRemaining {
    return endDate.difference(DateTime.now()).inDays;
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  StudyPlan copyWith({
    String? id,
    String? name,
    String? templateType,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<DaySchedule>? weeklySchedule,
    int? totalWeeks,
    bool? isActive,
    int? progress,
    Map<String, dynamic>? customizations,
    DateTime? createdAt,
  }) {
    return StudyPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      templateType: templateType ?? this.templateType,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      isActive: isActive ?? this.isActive,
      progress: progress ?? this.progress,
      customizations: customizations ?? this.customizations,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
