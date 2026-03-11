import 'package:taskflow_ai/domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.category,
    required super.status,
    required super.priority,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    TaskPriority parsePriority(String? value) {
      switch (value) {
        case 'high':
          return TaskPriority.high;
        case 'low':
          return TaskPriority.low;
        default:
          return TaskPriority.medium;
      }
    }

    TaskStatus parseStatus(String? value) {
      return value == 'completed' ? TaskStatus.completed : TaskStatus.active;
    }

    return TaskModel(
      id: json['id'] as String,
      title: json['text'] as String? ?? json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      status: parseStatus(json['status'] as String?),
      priority: parsePriority(json['priority'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'text': title,
      'status': status.name,
      'priority': priority.name,
      'category': category,
    };
  }
}
