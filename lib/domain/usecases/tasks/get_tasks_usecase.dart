import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/domain/repositories/task_repository.dart';

class GetTasksUseCase {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, List<Task>>> call(String userId) {
    return _repository.getTasks(userId);
  }
}
