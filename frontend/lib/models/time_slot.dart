enum ProductivityType { productive, neutral, wasted }

class TimeSlot {
  final String? id;
  final String date;
  final String timeRange; // e.g., '09:00-09:20'
  final String? taskSelected;
  final String category;
  final ProductivityType type;

  TimeSlot({
    this.id,
    required this.date,
    required this.timeRange,
    this.taskSelected,
    required this.category,
    required this.type,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['_id']?.toString(),
      date: json['date']?.toString() ?? '',
      timeRange: json['timeRange']?.toString() ?? '',
      taskSelected: json['taskSelected']?.toString(),
      category: json['category']?.toString() ?? 'Other',
      type: ProductivityType.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() ==
              (json['productivityType']?.toString() ?? 'neutral').toLowerCase(),
          orElse: () => ProductivityType.neutral),
    );
  }

  Map<String, dynamic> toJson() {
    final typeName = type.toString().split('.').last;
    final capitalizedType = typeName[0].toUpperCase() + typeName.substring(1);
    return {
      'date': date,
      'timeRange': timeRange,
      'taskSelected': taskSelected ?? category,
      'category': category,
      'productivityType': capitalizedType,
    };
  }
}

