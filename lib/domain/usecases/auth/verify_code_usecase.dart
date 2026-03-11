import 'package:dartz/dartz.dart';
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/domain/entities/session.dart';
import 'package:taskflow_ai/domain/repositories/auth_repository.dart';

class VerifyCodeUseCase {
  const VerifyCodeUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Session>> call(String code) {
    return _repository.verifyCode(code);
  }
}
