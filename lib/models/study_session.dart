class StudySession {
  final String? id;
  final String subject;
  final String? topic;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // in minutes
  final List<Break>? breaks;
  final int focusScore;
  final String? notes;
  final bool completed;
  final DateTime? createdAt;

  StudySession({
    this.id,
    required this.subject,
    this.topic,
    required this.startTime,
    this.endTime,
    this.duration = 0,
    this.breaks,
    this.focusScore = 100,
    this.notes,
    this.completed = false,
    this.createdAt,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['_id'] ?? json['id'],
      subject: json['subject'] ?? '',
      topic: json['topic'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['duration'] ?? 0,
      breaks: json['breaks'] != null
          ? (json['breaks'] as List).map((b) => Break.fromJson(b)).toList()
          : null,
      focusScore: json['focusScore'] ?? 100,
      notes: json['notes'],
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'subject': subject,
      if (topic != null) 'topic': topic,
      'startTime': startTime.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      'duration': duration,
      if (breaks != null) 'breaks': breaks!.map((b) => b.toJson()).toList(),
      'focusScore': focusScore,
      if (notes != null) 'notes': notes,
      'completed': completed,
    };
  }
}

class Break {
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // in minutes

  Break({
    required this.startTime,
    this.endTime,
    this.duration = 0,
  });

  factory Break.fromJson(Map<String, dynamic> json) {
    return Break(
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      'duration': duration,
    };
  }
}
