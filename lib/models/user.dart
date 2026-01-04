class User {
  final String id;
  final String name;
  final String email;
  final UserPreferences preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences.toJson(),
    };
  }
}

class UserPreferences {
  final int pomodoroLength;
  final int shortBreakLength;
  final int longBreakLength;
  final int dailyGoal;

  UserPreferences({
    this.pomodoroLength = 25,
    this.shortBreakLength = 5,
    this.longBreakLength = 15,
    this.dailyGoal = 240,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      pomodoroLength: json['pomodoroLength'] ?? 25,
      shortBreakLength: json['shortBreakLength'] ?? 5,
      longBreakLength: json['longBreakLength'] ?? 15,
      dailyGoal: json['dailyGoal'] ?? 240,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pomodoroLength': pomodoroLength,
      'shortBreakLength': shortBreakLength,
      'longBreakLength': longBreakLength,
      'dailyGoal': dailyGoal,
    };
  }
}
