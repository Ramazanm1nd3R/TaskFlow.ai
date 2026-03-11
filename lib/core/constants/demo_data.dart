import 'package:taskflow_ai/domain/entities/session.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/domain/entities/user.dart';

final demoUser = User(
  id: '1',
  email: 'demo@taskflow.ai',
  firstName: 'Demo',
  lastName: 'User',
  createdAt: DateTime(2026, 3, 1, 9),
);

final demoSession = Session(
  user: demoUser,
  expiresAt: DateTime(2030, 1, 1),
);

List<Task> buildDemoTasks() {
  final now = DateTime.now();
  return [
    Task(
      id: 'demo-1',
      title: 'Review sprint priorities for TaskFlow AI',
      category: 'work',
      status: TaskStatus.active,
      priority: TaskPriority.high,
      createdAt: now.subtract(const Duration(days: 3, hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    ),
    Task(
      id: 'demo-2',
      title: 'Ship iOS dashboard hero section',
      category: 'work',
      status: TaskStatus.completed,
      priority: TaskPriority.high,
      createdAt: now.subtract(const Duration(days: 2, hours: 6)),
      updatedAt: now.subtract(const Duration(days: 1, hours: 1)),
    ),
    Task(
      id: 'demo-3',
      title: 'Refine analytics chart labels',
      category: 'work',
      status: TaskStatus.active,
      priority: TaskPriority.medium,
      createdAt: now.subtract(const Duration(days: 4)),
      updatedAt: now.subtract(const Duration(hours: 5)),
    ),
    Task(
      id: 'demo-4',
      title: 'Plan weekly grocery run',
      category: 'personal',
      status: TaskStatus.completed,
      priority: TaskPriority.low,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    Task(
      id: 'demo-5',
      title: 'Book dentist appointment',
      category: 'health',
      status: TaskStatus.active,
      priority: TaskPriority.medium,
      createdAt: now.subtract(const Duration(days: 1, hours: 8)),
      updatedAt: now.subtract(const Duration(days: 1, hours: 3)),
    ),
    Task(
      id: 'demo-6',
      title: 'Write release notes for demo build',
      category: 'work',
      status: TaskStatus.completed,
      priority: TaskPriority.medium,
      createdAt: now.subtract(const Duration(days: 6)),
      updatedAt: now.subtract(const Duration(days: 4)),
    ),
    Task(
      id: 'demo-7',
      title: 'Morning workout session',
      category: 'fitness',
      status: TaskStatus.completed,
      priority: TaskPriority.low,
      createdAt: now.subtract(const Duration(days: 1, hours: 12)),
      updatedAt: now.subtract(const Duration(days: 1, hours: 10)),
    ),
    Task(
      id: 'demo-8',
      title: 'Prepare AI insights presentation',
      category: 'study',
      status: TaskStatus.active,
      priority: TaskPriority.high,
      createdAt: now.subtract(const Duration(hours: 18)),
      updatedAt: now.subtract(const Duration(hours: 3)),
    ),
    Task(
      id: 'demo-9',
      title: 'Call design partner about onboarding flow',
      category: 'communication',
      status: TaskStatus.active,
      priority: TaskPriority.medium,
      createdAt: now.subtract(const Duration(days: 2, hours: 4)),
      updatedAt: now.subtract(const Duration(days: 1, hours: 6)),
    ),
    Task(
      id: 'demo-10',
      title: 'Clean up downloads folder',
      category: 'personal',
      status: TaskStatus.completed,
      priority: TaskPriority.low,
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now.subtract(const Duration(days: 6, hours: 5)),
    ),
    Task(
      id: 'demo-11',
      title: 'Research local notifications edge cases',
      category: 'research',
      status: TaskStatus.active,
      priority: TaskPriority.high,
      createdAt: now.subtract(const Duration(hours: 30)),
      updatedAt: now.subtract(const Duration(hours: 7)),
    ),
    Task(
      id: 'demo-12',
      title: 'Update weekly budget sheet',
      category: 'finance',
      status: TaskStatus.completed,
      priority: TaskPriority.medium,
      createdAt: now.subtract(const Duration(days: 8)),
      updatedAt: now.subtract(const Duration(days: 7, hours: 8)),
    ),
  ];
}
