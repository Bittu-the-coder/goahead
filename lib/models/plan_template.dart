import 'study_plan.dart';

class PlanTemplate {
  final String? id;
  final String name;
  final String type;
  final String description;
  final TemplateDuration duration;
  final String difficulty;
  final List<DaySchedule> weeklySchedule;
  final List<SubjectInfo> subjects;
  final List<String> features;
  final List<String> tips;
  final bool isActive;

  PlanTemplate({
    this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.duration,
    this.difficulty = 'intermediate',
    required this.weeklySchedule,
    required this.subjects,
    this.features = const [],
    this.tips = const [],
    this.isActive = true,
  });

  factory PlanTemplate.fromJson(Map<String, dynamic> json) {
    return PlanTemplate(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      duration: TemplateDuration.fromJson(json['duration'] ?? {}),
      difficulty: json['difficulty'] ?? 'intermediate',
      weeklySchedule: json['weeklySchedule'] != null
          ? (json['weeklySchedule'] as List).map((d) => DaySchedule.fromJson(d)).toList()
          : [],
      subjects: json['subjects'] != null
          ? (json['subjects'] as List).map((s) => SubjectInfo.fromJson(s)).toList()
          : [],
      features: json['features'] != null ? List<String>.from(json['features']) : [],
      tips: json['tips'] != null ? List<String>.from(json['tips']) : [],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'type': type,
      'description': description,
      'duration': duration.toJson(),
      'difficulty': difficulty,
      'weeklySchedule': weeklySchedule.map((d) => d.toJson()).toList(),
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'features': features,
      'tips': tips,
      'isActive': isActive,
    };
  }
}

class TemplateDuration {
  final int weeks;
  final int? months;

  TemplateDuration({
    required this.weeks,
    this.months,
  });

  factory TemplateDuration.fromJson(Map<String, dynamic> json) {
    return TemplateDuration(
      weeks: json['weeks'] ?? 0,
      months: json['months'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeks': weeks,
      if (months != null) 'months': months,
    };
  }
}

class SubjectInfo {
  final String name;
  final double weeklyHours;
  final String importance;

  SubjectInfo({
    required this.name,
    required this.weeklyHours,
    this.importance = 'medium',
  });

  factory SubjectInfo.fromJson(Map<String, dynamic> json) {
    return SubjectInfo(
      name: json['name'] ?? '',
      weeklyHours: (json['weeklyHours'] ?? 0).toDouble(),
      importance: json['importance'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weeklyHours': weeklyHours,
      'importance': importance,
    };
  }
}
