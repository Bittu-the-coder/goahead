class Goal {
  final String? id;
  final String title;
  final String? description;
  final String category; // 'daily', 'weekly', 'monthly', 'exam', 'custom'
  final DateTime targetDate;
  final int progress; // 0-100
  final List<Milestone>? milestones;
  final bool completed;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Goal({
    this.id,
    required this.title,
    this.description,
    this.category = 'custom',
    required this.targetDate,
    this.progress = 0,
    this.milestones,
    this.completed = false,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'custom',
      targetDate: DateTime.parse(json['targetDate']),
      progress: json['progress'] ?? 0,
      milestones: json['milestones'] != null
          ? (json['milestones'] as List).map((m) => Milestone.fromJson(m)).toList()
          : null,
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      if (description != null) 'description': description,
      'category': category,
      'targetDate': targetDate.toIso8601String(),
      'progress': progress,
      if (milestones != null) 'milestones': milestones!.map((m) => m.toJson()).toList(),
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? targetDate,
    int? progress,
    List<Milestone>? milestones,
    bool? completed,
    DateTime? completedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      milestones: milestones ?? this.milestones,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isOverdue {
    if (completed) return false;
    return targetDate.isBefore(DateTime.now());
  }

  int get daysLeft {
    if (completed) return 0;
    return targetDate.difference(DateTime.now()).inDays;
  }
}

class Milestone {
  final String? id;
  final String title;
  final bool completed;
  final DateTime? completedAt;

  Milestone({
    this.id,
    required this.title,
    this.completed = false,
    this.completedAt,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }

  Milestone copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? completedAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
