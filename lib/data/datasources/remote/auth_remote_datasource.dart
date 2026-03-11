import 'package:dio/dio.dart';
import 'package:taskflow_ai/core/constants/api_constants.dart';
import 'package:taskflow_ai/core/errors/exceptions.dart';
import 'package:taskflow_ai/data/models/auth/user_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data ?? <String, dynamic>{};
    if (data['success'] != true) {
      throw ServerException(data['error'] as String? ?? 'Login failed');
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    if (data['success'] != true) {
      throw ServerException(data['error'] as String? ?? 'Registration failed');
    }
    return data['userId'] as String;
  }

  Future<void> sendVerificationCode({
    required String email,
    required String code,
    required String type,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.sendVerificationCode,
      data: {'email': email, 'code': code, 'type': type},
    );
    final data = response.data ?? <String, dynamic>{};
    if (data['success'] != true) {
      throw ServerException(data['error'] as String? ?? 'Verification failed');
    }
  }

  Future<UserModel> getUser(String userId) async {
    final response = await _dio.get<Map<String, dynamic>>(ApiConstants.user(userId));
    final data = response.data ?? <String, dynamic>{};
    if (data['success'] != true) {
      throw ServerException(data['error'] as String? ?? 'User fetch failed');
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
