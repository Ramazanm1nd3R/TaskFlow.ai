import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:taskflow_ai/core/errors/error_mapper.dart';
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/data/datasources/remote/tasks_remote_datasource.dart';
import 'package:taskflow_ai/data/models/tasks/task_model.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remote);

  final TasksRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Task>>> getTasks(String userId) async {
    try {
      final items = await _remote.getTasks(userId);
      return Right(items);
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask({
    required String userId,
    required String title,
    required String category,
    required TaskPriority priority,
  }) async {
    try {
      final draft = TaskModel(
        id: '',
        title: title,
        category: category,
        status: TaskStatus.active,
        priority: priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _remote.createTask(userId, draft.toApiJson());
      final items = await _remote.getTasks(userId);
      return Right(items.first);
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask({
    required String userId,
    required Task task,
  }) async {
    try {
      final model = TaskModel(
        id: task.id,
        title: task.title,
        category: task.category,
        status: task.status,
        priority: task.priority,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );
      await _remote.updateTask(userId, task.id, model.toApiJson());
      final items = await _remote.getTasks(userId);
      return Right(items.firstWhere((item) => item.id == task.id));
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await _remote.deleteTask(userId, taskId);
      return const Right(null);
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }
}
