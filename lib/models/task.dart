class Task {
  final String? id;
  final String title;
  final String? description;
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'todo', 'in-progress', 'completed'
  final String? category;
  final DateTime? dueDate;
  final bool completed;
  final DateTime? completedAt;
  final List<String>? tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.status = 'todo',
    this.category,
    this.dueDate,
    this.completed = false,
    this.completedAt,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      category: json['category'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      if (description != null) 'description': description,
      'priority': priority,
      'status': status,
      if (category != null) 'category': category,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (tags != null) 'tags': tags,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    String? category,
    DateTime? dueDate,
    bool? completed,
    DateTime? completedAt,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isOverdue {
    if (dueDate == null || completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }
}
