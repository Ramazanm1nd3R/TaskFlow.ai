import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/domain/repositories/task_repository.dart';

class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call({
    required String userId,
    required String title,
    required String category,
    required TaskPriority priority,
  }) {
    return _repository.createTask(
      userId: userId,
      title: title,
      category: category,
      priority: priority,
    );
  }
}
