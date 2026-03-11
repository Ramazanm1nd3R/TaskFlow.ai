import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskflow_ai/core/network/dio_client.dart';
import 'package:taskflow_ai/core/storage/secure_storage_service.dart';
import 'package:taskflow_ai/data/datasources/local/auth_local_datasource.dart';
import 'package:taskflow_ai/data/datasources/remote/auth_remote_datasource.dart';
import 'package:taskflow_ai/data/datasources/remote/tasks_remote_datasource.dart';
import 'package:taskflow_ai/data/repositories/auth_repository_impl.dart';
import 'package:taskflow_ai/data/repositories/task_repository_impl.dart';
import 'package:taskflow_ai/domain/repositories/auth_repository.dart';
import 'package:taskflow_ai/domain/repositories/task_repository.dart';
import 'package:taskflow_ai/domain/usecases/auth/logout_usecase.dart';
import 'package:taskflow_ai/domain/usecases/auth/resend_code_usecase.dart';
import 'package:taskflow_ai/domain/usecases/auth/restore_session_usecase.dart';
import 'package:taskflow_ai/domain/usecases/auth/start_login_usecase.dart';
import 'package:taskflow_ai/domain/usecases/auth/start_register_usecase.dart';
import 'package:taskflow_ai/domain/usecases/auth/verify_code_usecase.dart';
import 'package:taskflow_ai/domain/usecases/tasks/create_task_usecase.dart';
import 'package:taskflow_ai/domain/usecases/tasks/get_tasks_usecase.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(ref.watch(flutterSecureStorageProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(ref.watch(secureStorageServiceProvider)),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final tasksRemoteDataSourceProvider = Provider<TasksRemoteDataSource>(
  (ref) => TasksRemoteDataSource(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  ),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(ref.watch(tasksRemoteDataSourceProvider)),
);

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>(
  (ref) => RestoreSessionUseCase(ref.watch(authRepositoryProvider)),
);
final startLoginUseCaseProvider = Provider<StartLoginUseCase>(
  (ref) => StartLoginUseCase(ref.watch(authRepositoryProvider)),
);
final startRegisterUseCaseProvider = Provider<StartRegisterUseCase>(
  (ref) => StartRegisterUseCase(ref.watch(authRepositoryProvider)),
);
final verifyCodeUseCaseProvider = Provider<VerifyCodeUseCase>(
  (ref) => VerifyCodeUseCase(ref.watch(authRepositoryProvider)),
);
final resendCodeUseCaseProvider = Provider<ResendCodeUseCase>(
  (ref) => ResendCodeUseCase(ref.watch(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);
final getTasksUseCaseProvider = Provider<GetTasksUseCase>(
  (ref) => GetTasksUseCase(ref.watch(taskRepositoryProvider)),
);
final createTaskUseCaseProvider = Provider<CreateTaskUseCase>(
  (ref) => CreateTaskUseCase(ref.watch(taskRepositoryProvider)),
);
