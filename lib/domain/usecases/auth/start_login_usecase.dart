import 'package:dartz/dartz.dart';
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/domain/repositories/auth_repository.dart';

class StartLoginUseCase {
  const StartLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({
    required String email,
    required String password,
  }) {
    return _repository.startLogin(email: email, password: password);
  }
}
