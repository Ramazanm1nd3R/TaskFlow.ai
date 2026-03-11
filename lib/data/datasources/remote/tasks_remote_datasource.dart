import 'package:dio/dio.dart';
import 'package:taskflow_ai/core/constants/api_constants.dart';
import 'package:taskflow_ai/core/errors/exceptions.dart';
import 'package:taskflow_ai/data/models/tasks/task_model.dart';

class TasksRemoteDataSource {
  const TasksRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TaskModel>> getTasks(String userId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.dashboardItems(userId),
    );
    final data = response.data ?? <String, dynamic>{};
    if (data['success'] != true) {
      throw ServerException(data['error'] as String? ?? 'Tasks fetch failed');
    }
    final items = (data['items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return items.map(TaskModel.fromJson).toList();
  }

  Future<void> createTask(String userId, Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.dashboardItems(userId),
      data: payload,
    );
    final data = response.data ?? <String, dynamic>{};
    if (data['success'] != true) {
      throw ServerException(data['error'] as String? ?? 'Task create failed');
    }
  }

  Future<void> updateTask(
    String userId,
    String taskId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.dashboardItem(userId, taskId),
      data: payload,
    );
    final data = response.data ?? <String, dynamic>{};
    if (data['success'] != true) {
      throw ServerException(data['error'] as String? ?? 'Task update failed');
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      ApiConstants.dashboardItem(userId, taskId),
    );
    final data = response.data ?? <String, dynamic>{};
    if (data['success'] != true) {
      throw ServerException(data['error'] as String? ?? 'Task delete failed');
    }
  }
}
