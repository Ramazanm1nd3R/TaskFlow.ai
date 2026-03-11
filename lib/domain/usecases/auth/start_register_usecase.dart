import 'package:dartz/dartz.dart';
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/domain/repositories/auth_repository.dart';

class StartRegisterUseCase {
  const StartRegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    return _repository.startRegister(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }
}
