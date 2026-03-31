class Task {
  final String? id;
  final String taskName;
  final String date;
  final bool isCompleted;

  Task({
    this.id,
    required this.taskName,
    required this.date,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      taskName: json['taskName'],
      date: json['date'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'date': date,
      'isCompleted': isCompleted,
    };
  }
}
