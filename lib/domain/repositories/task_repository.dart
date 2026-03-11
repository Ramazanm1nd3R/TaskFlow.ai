import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/domain/entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks(String userId);
  Future<Either<Failure, Task>> createTask({
    required String userId,
    required String title,
    required String category,
    required TaskPriority priority,
  });
  Future<Either<Failure, Task>> updateTask({
    required String userId,
    required Task task,
  });
  Future<Either<Failure, void>> deleteTask({
    required String userId,
    required String taskId,
  });
}
