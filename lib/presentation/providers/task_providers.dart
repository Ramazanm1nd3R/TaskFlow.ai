import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/core/constants/demo_data.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/presentation/providers/auth_providers.dart';

enum TaskListFilter { all, active, completed }

final taskSearchProvider = StateProvider<String>((ref) => '');
final taskFilterProvider = StateProvider<TaskListFilter>((ref) => TaskListFilter.all);
final taskCategoryProvider = StateProvider<String>((ref) => 'all');

class TasksController extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    ref.watch(authControllerProvider);
    return buildDemoTasks();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> createTask({
    required String title,
    required String category,
    required TaskPriority priority,
  }) async {
    final current = state.value ?? const <Task>[];
    final task = Task(
      id: 'demo-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      category: category,
      status: TaskStatus.active,
      priority: priority,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = AsyncData([task, ...current]);
  }

  Future<void> updateTask(Task task) async {
    final current = state.value ?? const <Task>[];
    state = AsyncData([
      for (final currentTask in current)
        if (currentTask.id == task.id) task.copyWith(updatedAt: DateTime.now()) else currentTask,
    ]);
  }

  Future<void> deleteTask(String taskId) async {
    final current = state.value ?? const <Task>[];
    state = AsyncData(current.where((task) => task.id != taskId).toList());
  }

  Future<void> toggleStatus(String taskId) async {
    final current = state.value ?? const <Task>[];
    state = AsyncData([
      for (final task in current)
        if (task.id == taskId)
          task.copyWith(
            status: task.isCompleted ? TaskStatus.active : TaskStatus.completed,
            updatedAt: DateTime.now(),
          )
        else
          task,
    ]);
  }
}

final tasksControllerProvider =
    AsyncNotifierProvider<TasksController, List<Task>>(TasksController.new);
