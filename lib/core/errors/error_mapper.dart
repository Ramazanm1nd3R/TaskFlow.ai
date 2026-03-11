import 'package:dio/dio.dart';
import 'package:taskflow_ai/core/errors/failures.dart';

Failure mapToFailure(Object error) {
  if (error is DioException) {
    final message = error.response?.data is Map<String, dynamic>
        ? (error.response?.data['error'] as String? ??
            error.response?.data['message'] as String? ??
            'Server error')
        : 'Network error';
    return ServerFailure(message);
  }

  if (error is Failure) {
    return error;
  }

  return ServerFailure(error.toString());
}
