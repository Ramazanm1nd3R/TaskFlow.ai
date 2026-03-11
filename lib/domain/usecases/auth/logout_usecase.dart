import 'package:dartz/dartz.dart';
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call() => _repository.logout();
}
